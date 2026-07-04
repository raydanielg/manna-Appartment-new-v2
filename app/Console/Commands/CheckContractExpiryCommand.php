<?php

namespace App\Console\Commands;

use App\Models\Contract;
use Illuminate\Console\Command;

class CheckContractExpiryCommand extends Command
{
    protected $signature = 'contracts:check-expiry';
    protected $description = 'Check contracts expiring soon and notify parties';

    public function handle()
    {
        $thresholds = [30, 15, 7];

        foreach ($thresholds as $days) {
            $contracts = Contract::where('status', 'active')
                ->whereDate('end_date', now()->addDays($days))
                ->get();

            foreach ($contracts as $contract) {
                // TODO: send notification to landlord and tenant
            }
        }

        $this->info('Contract expiry checks completed.');
    }
}
