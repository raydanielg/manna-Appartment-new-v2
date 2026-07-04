<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Models\Organization;
use App\Models\User;
use App\Services\SmsService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class RegisterLandlordController extends Controller
{
    use ApiResponse;

    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'phone' => 'required|string|unique:users,phone',
            'password' => 'required|string|min:6',
            'email' => 'nullable|email|max:255',
            'business_name' => 'nullable|string|max:255',
        ]);

        $organization = Organization::create([
            'business_name' => $request->business_name,
            'kyc_status' => 'pending',
            'sms_balance' => 0,
            'status' => 'active',
        ]);

        $user = User::create([
            'full_name' => $request->name,
            'phone' => $request->phone,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => 'landlord',
            'organization_id' => $organization->id,
            'status' => 'active',
        ]);

        $organization->update(['owner_user_id' => $user->id]);

        $token = $user->createToken('mobile_token', ['landlord:*'])->plainTextToken;

        // Send welcome SMS
        app(SmsService::class)->send(
            $request->phone,
            "Karibu Manna Apartment, {$user->full_name}! Your landlord account has been created successfully. Manage your properties, tenants, and payments all in one place.",
            'welcome',
            $organization->id
        );

        $userData = $user->only(['id', 'full_name', 'phone', 'role', 'organization_id', 'status']);
        $userData['organization'] = [
            'business_name' => $organization->business_name,
            'kyc_status' => $organization->kyc_status,
            'status' => $organization->status,
        ];

        return $this->success('Landlord registered successfully.', [
            'user' => $userData,
            'access_token' => $token,
            'token' => $token,
        ], 201);
    }
}
