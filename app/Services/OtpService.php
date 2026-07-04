<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;

class OtpService
{
    public function generate(string $phone): string
    {
        $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        Cache::put('otp_' . $phone, $otp, now()->addMinutes(15));
        return $otp;
    }

    public function verify(string $phone, string $otp): bool
    {
        return Cache::get('otp_' . $phone) === $otp;
    }

    public function clear(string $phone): void
    {
        Cache::forget('otp_' . $phone);
    }
}
