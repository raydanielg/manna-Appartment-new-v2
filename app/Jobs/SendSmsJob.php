<?php

namespace App\Jobs;

use App\Services\SmsService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SendSmsJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $phone;
    public $message;
    public $type;
    public $organizationId;

    public function __construct(string $phone, string $message, string $type = 'general', ?string $organizationId = null)
    {
        $this->phone = $phone;
        $this->message = $message;
        $this->type = $type;
        $this->organizationId = $organizationId;
    }

    public function handle(SmsService $smsService)
    {
        $smsService->send($this->phone, $this->message, $this->type, $this->organizationId);
    }
}
