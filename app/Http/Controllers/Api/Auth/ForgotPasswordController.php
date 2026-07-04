<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
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
            return $this->error('Phone number not found.', null, 404);
        }

        $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        Cache::put('otp_' . $request->phone, $otp, now()->addMinutes(15));

        // TODO: dispatch SendSmsJob with OTP
        return $this->success('OTP sent to your phone.', ['otp' => $otp]); // remove otp in production
    }

    public function verifyOtp(Request $request)
    {
        $request->validate([
            'phone' => 'required|string',
            'otp' => 'required|string|size:6',
        ]);

        $cached = Cache::get('otp_' . $request->phone);

        if ($cached !== $request->otp) {
            return $this->error('Invalid or expired OTP.', null, 422);
        }

        return $this->success('OTP verified.');
    }

    public function reset(Request $request)
    {
        $request->validate([
            'phone' => 'required|string',
            'otp' => 'required|string|size:6',
            'new_password' => 'required|string|min:6',
        ]);

        $cached = Cache::get('otp_' . $request->phone);

        if ($cached !== $request->otp) {
            return $this->error('Invalid or expired OTP.', null, 422);
        }

        $user = User::where('phone', $request->phone)->first();

        if (!$user) {
            return $this->error('Phone number not found.', null, 404);
        }

        $user->update(['password' => Hash::make($request->new_password)]);
        Cache::forget('otp_' . $request->phone);

        return $this->success('Password reset successfully.');
    }
}
