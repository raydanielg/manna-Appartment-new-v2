<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\OtpService;
use App\Services\SmsService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class ForgotPasswordController extends Controller
{
    public function showForgotForm()
    {
        return view('auth.forgot');
    }

    public function sendOtp(Request $request)
    {
        $request->validate(['phone' => 'required|string|exists:users,phone']);

        $user = User::where('phone', $request->phone)->first();
        $otp = app(OtpService::class)->generate($request->phone);

        app(SmsService::class)->send(
            $request->phone,
            "Your Manna Apartment password reset code is: {$otp}. It expires in 15 minutes.",
            'password_reset',
            $user->organization_id
        );

        if ($request->ajax() || $request->wantsJson()) {
            return response()->json(['message' => 'OTP sent to your phone number.', 'phone' => $request->phone]);
        }

        return redirect()->route('password.verify.form', ['phone' => $request->phone])
            ->with('success', 'OTP sent to your phone number.');
    }

    public function showVerifyForm(Request $request)
    {
        return view('auth.verify-otp', ['phone' => $request->phone]);
    }

    public function verifyOtp(Request $request)
    {
        $request->validate([
            'phone' => 'required|string|exists:users,phone',
            'otp' => 'required|string|size:6',
        ]);

        if (!app(OtpService::class)->verify($request->phone, $request->otp)) {
            if ($request->ajax() || $request->wantsJson()) {
                return response()->json(['message' => 'Invalid or expired OTP.'], 422);
            }
            return back()->withErrors(['otp' => 'Invalid or expired OTP.']);
        }

        if ($request->ajax() || $request->wantsJson()) {
            return response()->json(['message' => 'OTP verified. Set your new password.', 'phone' => $request->phone, 'otp' => $request->otp]);
        }

        return redirect()->route('password.reset.form', [
            'phone' => $request->phone,
            'otp' => $request->otp,
        ])->with('success', 'OTP verified. Set your new password.');
    }

    public function showResetForm(Request $request)
    {
        return view('auth.reset', ['phone' => $request->phone, 'otp' => $request->otp]);
    }

    public function resetPassword(Request $request)
    {
        $request->validate([
            'phone' => 'required|string|exists:users,phone',
            'otp' => 'required|string|size:6',
            'password' => 'required|string|min:6|confirmed',
        ]);

        if (!app(OtpService::class)->verify($request->phone, $request->otp)) {
            if ($request->ajax() || $request->wantsJson()) {
                return response()->json(['message' => 'Invalid or expired OTP.'], 422);
            }
            return back()->withErrors(['otp' => 'Invalid or expired OTP.']);
        }

        $user = User::where('phone', $request->phone)->first();
        $user->update(['password' => Hash::make($request->password)]);

        app(OtpService::class)->clear($request->phone);

        if ($request->ajax() || $request->wantsJson()) {
            return response()->json(['message' => 'Password reset successfully. Please log in.', 'redirect' => route('login')]);
        }

        return redirect()->route('login')->with('success', 'Password reset successfully. Please log in.');
    }
}
