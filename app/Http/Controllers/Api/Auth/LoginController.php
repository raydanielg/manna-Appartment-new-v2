<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class LoginController extends Controller
{
    use ApiResponse;

    public function login(Request $request)
    {
        $request->validate([
            'phone' => 'required|string',
            'password' => 'required|string',
            'platform' => 'required|in:web,mobile',
        ]);

        $user = User::where('phone', $request->phone)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'phone' => ['Invalid phone number or password.'],
            ]);
        }

        if ($user->status !== 'active') {
            return $this->error('Account is inactive or suspended.', null, 403);
        }

        $webOnlyRoles = ['super_admin', 'staff'];
        $mobileOnlyRoles = ['landlord', 'tenant'];

        if (in_array($user->role, $webOnlyRoles) && $request->platform !== 'web') {
            return $this->error('This account must be accessed via the Web Admin Panel.', null, 403);
        }

        if (in_array($user->role, $mobileOnlyRoles) && $request->platform !== 'mobile') {
            return $this->error('This account must be accessed via the Mobile App.', null, 403);
        }

        $tokenName = $request->platform . '_token';
        $abilities = $this->getAbilities($user);
        $token = $user->createToken($tokenName, $abilities)->plainTextToken;

        $userData = $user->only(['id', 'full_name', 'phone', 'role', 'organization_id', 'status', 'must_change_password']);
        $userData['organization'] = $user->organization ? [
            'business_name' => $user->organization->business_name,
            'kyc_status' => $user->organization->kyc_status,
            'status' => $user->organization->status,
        ] : null;

        return $this->success('Login successful.', [
            'user' => $userData,
            'access_token' => $token,
            'token' => $token,
        ]);
    }

    private function getAbilities(User $user)
    {
        switch ($user->role) {
            case 'super_admin':
                return ['*'];
            case 'staff':
                $permission = $user->staffPermission;
                return $permission ? array_keys($permission->permissions_json ?? []) : ['staff:basic'];
            case 'landlord':
                return ['landlord:*'];
            case 'tenant':
                return ['tenant:*'];
            default:
                return [];
        }
    }
}
