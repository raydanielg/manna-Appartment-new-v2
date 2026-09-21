<?php

namespace App\Console\Commands;

use App\Jobs\SendRentReminderJob;
use App\Models\AppNotification;
use App\Models\Contract;
use App\Models\Payment;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Console\Command;

class CheckRentDueCommand extends Command
{
    protected $signature = 'rent:check-due';
    protected $description = 'Check for rent due soon and send reminders';

    /**
     * Days before the rent due date on which the landlord is notified.
     * Roughly "one month and fifteen days before".
     */
    private const LANDLORD_THRESHOLDS = [30, 15];

    public function handle()
    {
        $contracts = Contract::where('status', 'active')
            ->where('end_date', '>=', now())
            ->with(['tenant.user', 'unit.property', 'organization.owner'])
            ->get();

        $landlordNotified = 0;

        foreach ($contracts as $contract) {
            SendRentReminderJob::dispatch($contract);
            if ($this->notifyLandlord($contract)) {
                $landlordNotified++;
            }
        }

        $this->info('Rent reminders dispatched: ' . $contracts->count());
        $this->info('Landlord due-soon notifications: ' . $landlordNotified);
    }

    /**
     * Notify the landlord when a tenant's next rent due date is approaching
     * (one month and fifteen days before it lapses).
     */
    private function notifyLandlord(Contract $contract): bool
    {
        $dueDate = $this->nextDueDate($contract);
        if (!$dueDate) {
            return false;
        }

        $daysRemaining = (int) now()->startOfDay()->diffInDays($dueDate, false);
        if (!in_array($daysRemaining, self::LANDLORD_THRESHOLDS, true)) {
            return false;
        }

        $landlord = $contract->organization?->owner
            ?? User::where('organization_id', $contract->organization_id)
                ->where('role', 'landlord')
                ->first();

        if (!$landlord) {
            return false;
        }

        $alreadySent = AppNotification::where('user_id', $landlord->id)
            ->where('type', 'rent_due_landlord')
            ->whereJsonContains('data->contract_id', $contract->id)
            ->whereJsonContains('data->due_date', $dueDate->toDateString())
            ->exists();

        if ($alreadySent) {
            return false;
        }

        $tenantName = $contract->tenant?->user?->full_name ?? 'Tenant';
        $propertyName = $contract->unit?->property?->name ?? 'Property';
        $unitName = $contract->unit?->name ?? $contract->unit?->unit_number ?? 'Unit';

        AppNotification::create([
            'user_id' => $landlord->id,
            'type' => 'rent_due_landlord',
            'title' => 'Rent due soon',
            'body' => "{$tenantName}'s rent at {$propertyName}, {$unitName} is due on {$dueDate->format('d M Y')} (in {$daysRemaining} days).",
            'data' => [
                'contract_id' => $contract->id,
                'due_date' => $dueDate->toDateString(),
                'days_remaining' => $daysRemaining,
            ],
            'sent_at' => now(),
        ]);

        return true;
    }

    /**
     * Next expected rent due date: the overdue_date of the most recent payment,
     * falling back to the contract start date.
     */
    private function nextDueDate(Contract $contract): ?Carbon
    {
        $latest = Payment::where('contract_id', $contract->id)
            ->whereNotNull('overdue_date')
            ->orderByDesc('payment_date')
            ->value('overdue_date');

        if ($latest) {
            return Carbon::parse($latest);
        }

        return $contract->start_date ? Carbon::parse($contract->start_date) : null;
    }
}
