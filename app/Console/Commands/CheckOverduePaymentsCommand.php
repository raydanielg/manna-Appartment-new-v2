<?php

namespace App\Console\Commands;

use App\Models\Contract;
use App\Models\Organization;
use App\Models\Payment;
use App\Services\SmsService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class CheckOverduePaymentsCommand extends Command
{
    protected $signature = 'payments:check-overdue';
    protected $description = 'Flag overdue payments and send SMS reminders to tenants';

    public function handle()
    {
        $contracts = Contract::where('status', 'active')
            ->with(['tenant.user', 'tenant.unit.property', 'organization'])
            ->get();

        $overdue = 0;
        $sent = 0;
        $skipped = 0;

        foreach ($contracts as $contract) {
            $tenant = $contract->tenant;
            if (!$tenant || !$tenant->user) {
                continue;
            }

            $paid = Payment::where('contract_id', $contract->id)
                ->where('status', 'confirmed')
                ->sum('amount');

            $rentAmount = (float) ($contract->rent_amount ?? 0);
            $balance = $rentAmount - (float) $paid;

            if ($balance <= 0) {
                continue;
            }

            $overdue++;

            $organization = $contract->organization ?? $tenant->organization;
            if (!$organization) {
                continue;
            }

            if ($organization->sms_balance <= 0) {
                $skipped++;
                Log::warning("SMS skipped for tenant {$tenant->user->phone}: insufficient balance for org {$organization->id}");
                continue;
            }

            $tenantName = $tenant->user->full_name ?? 'Mteja';
            $propertyName = $tenant->unit?->property?->name ?? 'jengo lako';
            $unitName = $tenant->unit?->name ?? '';

            $message = "Habari {$tenantName}, kodi yako ya TZS {$this->formatAmount($balance)} kwenye {$propertyName}";
            if ($unitName) {
                $message .= " (Unit: {$unitName})";
            }
            $message .= " haijalipwa bado. Tafadhali lipa ndani ya siku 3 zijazo ili kuepuka hatua za kisheria. Asante - Manna Apartment.";

            app(SmsService::class)->send(
                $tenant->user->phone,
                $message,
                'overdue_reminder',
                $organization->id
            );

            $organization->decrement('sms_balance', 1);
            $sent++;
        }

        $this->info("Overdue tenants: {$overdue} | SMS sent: {$sent} | Skipped (no balance): {$skipped}");
    }

    private function formatAmount(float $amount): string
    {
        return number_format($amount, 0, '.', ',');
    }
}
