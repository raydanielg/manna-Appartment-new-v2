<?php

namespace App\Jobs;

use App\Models\Contract;
use App\Services\SmsService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SendRentReminderJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $contract;

    public function __construct(Contract $contract)
    {
        $this->contract = $contract;
    }

    public function handle(SmsService $smsService)
    {
        $tenant = $this->contract->tenant->user ?? null;
        if ($tenant) {
            $message = "Reminder: Your rent of " . $this->contract->rent_amount . " is due soon.";
            $smsService->send($tenant->phone, $message, 'rent_reminder', $this->contract->organization_id);
        }
    }
}
