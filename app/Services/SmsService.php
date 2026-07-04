<?php

namespace App\Services;

use App\Models\SmsLog;
use Illuminate\Support\Facades\Http;

class SmsService
{
    public function send(string $phone, string $message, string $type = 'general', ?string $organizationId = null): SmsLog
    {
        $log = SmsLog::create([
            'organization_id' => $organizationId,
            'recipient_phone' => $phone,
            'message' => $message,
            'type' => $type,
            'status' => 'queued',
        ]);

        // TODO: integrate Beem / Africa's Talking
        $log->update(['status' => 'sent', 'sent_at' => now()]);

        return $log;
    }
}
