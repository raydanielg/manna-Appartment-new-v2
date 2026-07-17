<?php

namespace App\Services;

use App\Models\Organization;
use App\Models\SmsLog;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

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

        try {
            $provider = config('sms.default_provider', 'nextsms');
            $sent = match ($provider) {
                'nextsms' => $this->sendViaNextSms($phone, $message),
                'beem' => $this->sendViaBeem($phone, $message),
                default => $this->sendViaNextSms($phone, $message),
            };

            if ($sent) {
                $log->update(['status' => 'sent', 'sent_at' => now()]);
            } else {
                $log->update(['status' => 'failed']);
            }
        } catch (\Exception $e) {
            Log::error('SMS send failed: ' . $e->getMessage(), [
                'phone' => $phone,
                'type' => $type,
                'provider' => config('sms.default_provider'),
            ]);
            $log->update(['status' => 'failed']);
        }

        return $log;
    }

    public function calcSmsCount(int $len): int
    {
        if ($len <= 160) return 1;
        if ($len <= 306) return 2;
        if ($len <= 459) return 3;
        if ($len <= 612) return 4;
        if ($len <= 765) return 5;
        return intdiv($len - 765, 153) + 6;
    }

    private function sendViaNextSms(string $phone, string $message): bool
    {
        $config = config('sms.providers.nextsms');
        $username = $config['username'] ?? '';
        $password = $config['password'] ?? '';
        $from = $config['from'] ?? 'MANNA';
        $url = $config['url'] ?? 'https://messaging-service.co.tz/api/sms/v1/text/single';

        if (empty($username) || empty($password)) {
            Log::warning('NextSMS credentials not configured.');
            return false;
        }

        $authToken = base64_encode("{$username}:{$password}");

        $response = Http::withHeaders([
            'Authorization' => "Basic {$authToken}",
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
        ])->post($url, [
            'from' => $from,
            'to' => $phone,
            'text' => $message,
        ]);

        if ($response->successful()) {
            Log::info("NextSMS sent to {$phone}: {$message}");
            return true;
        }

        Log::error('NextSMS API error: ' . $response->body(), [
            'phone' => $phone,
            'status' => $response->status(),
        ]);
        return false;
    }

    private function sendViaBeem(string $phone, string $message): bool
    {
        $config = config('sms.providers.beem');
        $apiKey = $config['api_key'] ?? '';
        $secretKey = $config['secret_key'] ?? '';
        $baseUrl = $config['base_url'] ?? 'https://apisms.beem.africa/v1/send';

        if (empty($apiKey) || empty($secretKey)) {
            Log::warning('Beem SMS credentials not configured.');
            return false;
        }

        $authToken = base64_encode("{$apiKey}:{$secretKey}");

        $response = Http::withHeaders([
            'Authorization' => "Basic {$authToken}",
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
        ])->post($baseUrl, [
            'sender_id' => config('sms.sender_id', 'MANNA'),
            'mobile' => $phone,
            'message' => $message,
        ]);

        if ($response->successful()) {
            Log::info("Beem SMS sent to {$phone}: {$message}");
            return true;
        }

        Log::error('Beem SMS API error: ' . $response->body(), [
            'phone' => $phone,
            'status' => $response->status(),
        ]);
        return false;
    }
}
