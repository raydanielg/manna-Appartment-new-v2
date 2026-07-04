<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\OtpService;
use App\Services\SmsService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class ForgotPasswordController extends Controller
{
    use ApiResponse;

    public function forgot(Request $request)
    {
        $request->validate(['phone' => 'required|string']);

        $user = User::where('phone', $request->phone)->first();

        if (!$user) {
            throw ValidationException::withMessages([
                'phone' => ['Phone number not found. Please check your number or register first.'],
            ]);
        }

        // Rate limit: one OTP request per phone per minute
        $rateKey = 'otp_request_' . $request->phone;
        if (Cache::has($rateKey)) {
            return $this->error('Please wait before requesting a new OTP.', null, 429);
        }

        $otp = app(OtpService::class)->generate($request->phone);

        $sms = app(SmsService::class)->send(
            $request->phone,
            "Your Manna Apartment password reset code is: {$otp}. It expires in 15 minutes.",
            'password_reset',
            $user->organization_id
        );

        if ($sms->status !== 'sent') {
            // Clear the generated OTP so the user can retry
            app(OtpService::class)->clear($request->phone);
            return $this->error('Could not send OTP. Please check your SMS provider configuration and try again.', null, 500);
        }

        Cache::put($rateKey, true, now()->addSeconds(60));

        return $this->success('OTP sent to your phone.');
    }

    public function verifyOtp(Request $request)
    {
        $request->validate([
            'phone' => 'required|string',
            'otp' => 'required|string|size:6',
        ]);

        $valid = app(OtpService::class)->verify($request->phone, $request->otp);

        if (!$valid) {
            return $this->error('Invalid or expired OTP.', null, 422);
        }

        // Mark phone as verified for reset
        Cache::put('otp_verified_' . $request->phone, true, now()->addMinutes(15));

        return $this->success('OTP verified.');
    }

    public function reset(Request $request)
    {
        $request->validate([
            'phone' => 'required|string',
            'password' => 'required|string|min:6',
        ]);

        $verified = Cache::get('otp_verified_' . $request->phone);

        if (!$verified) {
            return $this->error('Phone number not verified. Please verify OTP first.', null, 422);
        }

        $user = User::where('phone', $request->phone)->first();

        if (!$user) {
            return $this->error('Phone number not found.', null, 404);
        }

        $user->update(['password' => Hash::make($request->password)]);

        app(OtpService::class)->clear($request->phone);
        Cache::forget('otp_verified_' . $request->phone);

        app(SmsService::class)->send(
            $request->phone,
            "Your Manna Apartment password has been reset successfully. If this wasn't you, please contact support immediately.",
            'password_reset_confirmation',
            $user->organization_id
        );

        return $this->success('Password reset successfully.');
    }
}
