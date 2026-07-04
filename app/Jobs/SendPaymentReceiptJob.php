<?php

namespace App\Jobs;

use App\Models\Payment;
use App\Services\SmsService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SendPaymentReceiptJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $payment;

    public function __construct(Payment $payment)
    {
        $this->payment = $payment;
    }

    public function handle(SmsService $smsService)
    {
        $tenant = $this->payment->tenant->user ?? null;
        if ($tenant) {
            $message = "Payment of " . $this->payment->amount . " for " . $this->payment->month_covered . " received. Thank you.";
            $smsService->send($tenant->phone, $message, 'payment_receipt', $this->payment->organization_id);
        }
    }
}
