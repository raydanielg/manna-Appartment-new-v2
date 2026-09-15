<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
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

        $candidates = $this->phoneCandidates($request->phone);
        $user = User::whereIn('phone', $candidates)->first();

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

        $userData = $user->only(['id', 'full_name', 'phone', 'email', 'role', 'organization_id', 'status', 'must_change_password']);
        $userData['avatar'] = $user->avatar ? Storage::url($user->avatar) : null;
        $userData['organization'] = $user->organization ? [
            'business_name' => $user->organization->business_name,
            'kyc_status' => $user->organization->kyc_status,
            'status' => $user->organization->status,
            'suspension_reason' => $user->organization->suspension_reason,
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

    private function phoneCandidates(string $phone): array
    {
        $raw = $phone;
        $digits = preg_replace('/\D/', '', $phone);

        $candidates = [$raw, $digits, ltrim($raw, '+')];

        if (str_starts_with($digits, '0')) {
            $candidates[] = '255' . substr($digits, 1);
        }

        if (strlen($digits) === 9) {
            $candidates[] = '255' . $digits;
        }

        if (str_starts_with($digits, '255')) {
            $candidates[] = '0' . substr($digits, 3);
        }

        return array_values(array_unique(array_filter($candidates)));
    }
}
