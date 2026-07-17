<?php

namespace App\Jobs;

use App\Models\Contract;
use App\Services\SmsService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

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
        $tenant = $this->contract->tenant;
        if (!$tenant || !$tenant->user) {
            return;
        }

        $organization = $this->contract->organization;
        if (!$organization) {
            return;
        }

        if ($organization->sms_balance <= 0) {
            Log::warning("Rent reminder skipped: insufficient SMS balance for org {$organization->id}");
            return;
        }

        $tenantName = $tenant->user->full_name ?? 'Mteja';
        $rentAmount = number_format((float) ($this->contract->rent_amount ?? 0), 0, '.', ',');
        $propertyName = $tenant->unit?->property?->name ?? 'jengo lako';
        $unitName = $tenant->unit?->name ?? '';

        $message = "Habari {$tenantName}, hii ni ukumbusho wa kodi yako ya mwezi ya TZS {$rentAmount} kwenye {$propertyName}";
        if ($unitName) {
            $message .= " (Unit: {$unitName})";
        }
        $message .= ". Tafadhali lipa mapema kabla ya tarehe 5 ili kuepuka usumbufu. Asante - Manna Apartment.";

        $smsService->send(
            $tenant->user->phone,
            $message,
            'rent_reminder',
            $organization->id
        );

        $organization->decrement('sms_balance', 1);
    }
}
