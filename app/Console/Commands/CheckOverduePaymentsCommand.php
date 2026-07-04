<?php

namespace App\Console\Commands;

use App\Models\Contract;
use App\Models\Payment;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class CheckOverduePaymentsCommand extends Command
{
    protected $signature = 'payments:check-overdue';
    protected $description = 'Flag overdue payments and notify tenants';

    public function handle()
    {
        $contracts = Contract::where('status', 'active')->get();
        $overdue = 0;

        foreach ($contracts as $contract) {
            $paid = Payment::where('contract_id', $contract->id)->where('status', 'confirmed')->sum('amount');
            if ($paid < $contract->rent_amount) {
                $overdue++;
                // TODO: dispatch overdue SMS notification
            }
        }

        $this->info('Overdue payments flagged: ' . $overdue);
    }
}
