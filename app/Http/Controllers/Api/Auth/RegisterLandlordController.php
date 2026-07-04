<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Models\Organization;
use App\Models\User;
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
            'full_name' => 'required|string|max:255',
            'phone' => 'required|string|unique:users,phone',
            'password' => 'required|string|min:6',
            'business_name' => 'nullable|string|max:255',
        ]);

        $organization = Organization::create([
            'business_name' => $request->business_name,
            'kyc_status' => 'pending',
            'sms_balance' => 0,
            'status' => 'active',
        ]);

        $user = User::create([
            'full_name' => $request->full_name,
            'phone' => $request->phone,
            'password' => Hash::make($request->password),
            'role' => 'landlord',
            'organization_id' => $organization->id,
            'status' => 'active',
        ]);

        $organization->update(['owner_user_id' => $user->id]);

        $token = $user->createToken('mobile_token', ['landlord:*'])->plainTextToken;

        return $this->success('Landlord registered successfully.', [
            'user' => $user->only(['id', 'full_name', 'phone', 'role', 'organization_id', 'status']),
            'token' => $token,
        ], 201);
    }
}
