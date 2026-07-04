<?php

namespace App\Console\Commands;

use App\Jobs\SendRentReminderJob;
use App\Models\Contract;
use Illuminate\Console\Command;

class CheckRentDueCommand extends Command
{
    protected $signature = 'rent:check-due';
    protected $description = 'Check for rent due soon and send reminders';

    public function handle()
    {
        $contracts = Contract::where('status', 'active')
            ->where('end_date', '>=', now())
            ->get();

        foreach ($contracts as $contract) {
            SendRentReminderJob::dispatch($contract);
        }

        $this->info('Rent reminders dispatched: ' . $contracts->count());
    }
}
