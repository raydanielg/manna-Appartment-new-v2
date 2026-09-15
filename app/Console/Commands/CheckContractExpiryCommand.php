<?php

namespace App\Console\Commands;

use App\Models\AppNotification;
use App\Models\Contract;
use App\Models\User;
use App\Services\SmsService;
use Illuminate\Console\Command;

class CheckContractExpiryCommand extends Command
{
    protected $signature = 'contracts:check-expiry';
    protected $description = 'Check contracts expiring soon and notify parties';

    public function handle()
    {
        $landlordThresholds = [60, 30, 15];
        $tenantThresholds = [60, 30, 15];

        $this->notifyLandlords($landlordThresholds);
        $this->notifyTenants($tenantThresholds);

        $this->info('Contract expiry checks completed.');
    }

    private function notifyLandlords(array $thresholds)
    {
        foreach ($thresholds as $days) {
            $contracts = Contract::where('status', 'active')
                ->whereDate('end_date', now()->addDays($days))
                ->with(['tenant.user', 'unit.property', 'organization.owner'])
                ->get();

            foreach ($contracts as $contract) {
                $landlord = $contract->organization?->owner;

                if (!$landlord) {
                    $landlord = User::where('organization_id', $contract->organization_id)
                        ->where('role', 'landlord')
                        ->first();
                }

                if (!$landlord) {
                    continue;
                }

                $propertyName = $contract->unit?->property?->name ?? 'Property';
                $unitName = $contract->unit?->name ?? 'Unit';
                $tenantName = $contract->tenant?->user?->full_name ?? 'Tenant';

                if ($this->alreadyNotified($landlord->id, 'contract_expiry_landlord', $contract->id, $days)) {
                    continue;
                }

                $title = 'Contract expiring soon';
                $body = "{$tenantName}'s contract at {$propertyName}, {$unitName} will expire in {$days} day" . ($days > 1 ? 's' : '') . ' on ' . $contract->end_date->format('d M Y') . '.';

                AppNotification::create([
                    'user_id' => $landlord->id,
                    'type' => 'contract_expiry_landlord',
                    'title' => $title,
                    'body' => $body,
                    'data' => [
                        'contract_id' => $contract->id,
                        'days_remaining' => $days,
                    ],
                    'sent_at' => now(),
                ]);
            }
        }
    }

    /**
     * Whether a reminder for this exact (user, type, contract, threshold) was already
     * sent — a plain firstOrCreate() can't be used here because Laravel's query builder
     * flattens a nested-array where() value and only binds the first scalar against the
     * whole JSON `data` column, so it would never actually match an existing row.
     */
    private function alreadyNotified(string $userId, string $type, string $contractId, int $days): bool
    {
        return AppNotification::where('user_id', $userId)
            ->where('type', $type)
            ->whereJsonContains('data->contract_id', $contractId)
            ->whereJsonContains('data->days_remaining', $days)
            ->exists();
    }

    private function notifyTenants(array $thresholds)
    {
        $smsService = app(SmsService::class);

        foreach ($thresholds as $days) {
            $contracts = Contract::where('status', 'active')
                ->whereDate('end_date', now()->addDays($days))
                ->with(['tenant.user', 'unit.property'])
                ->get();

            foreach ($contracts as $contract) {
                $tenantUser = $contract->tenant?->user;

                if (!$tenantUser || !$tenantUser->phone) {
                    continue;
                }

                if ($this->alreadyNotified($tenantUser->id, 'contract_expiry_tenant', $contract->id, $days)) {
                    continue;
                }

                $propertyName = $contract->unit?->property?->name ?? 'Property';
                $unitName = $contract->unit?->name ?? 'Unit';

                $message = "Habari {$tenantUser->full_name}, mkataba wako wa {$propertyName}, {$unitName} unakaribia kumalizika muda wa siku {$days} ({$contract->end_date->format('d M Y')}). Tafadhali wasiliana na landlord kuhusu urefu wake.";

                $smsService->send(
                    $tenantUser->phone,
                    $message,
                    'contract_expiry_reminder',
                    $contract->organization_id
                );

                AppNotification::create([
                    'user_id' => $tenantUser->id,
                    'type' => 'contract_expiry_tenant',
                    'title' => 'Mkataba unakaribia kumalizika',
                    'body' => $message,
                    'data' => [
                        'contract_id' => $contract->id,
                        'days_remaining' => $days,
                    ],
                    'sent_at' => now(),
                ]);
            }
        }
    }
}
