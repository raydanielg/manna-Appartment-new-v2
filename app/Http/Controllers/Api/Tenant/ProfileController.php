<?php

namespace App\Http\Controllers\Api\Tenant;

use App\Http\Controllers\Controller;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class ProfileController extends Controller
{
    use ApiResponse;

    public function show()
    {
        $user = Auth::user();
        return $this->success('Profile retrieved.', $user->load('tenant.unit'));
    }

    public function update(Request $request)
    {
        $user = Auth::user();
        $user->update($request->only(['full_name', 'email']));
        return $this->success('Profile updated.', $user);
    }

    public function changePassword(Request $request)
    {
        $request->validate([
            'current_password' => 'required|string',
            'new_password' => 'required|string|min:6',
        ]);

        $user = Auth::user();

        if (!Hash::check($request->current_password, $user->password)) {
            return $this->error('Current password is incorrect.', null, 422);
        }

        $user->update([
            'password' => Hash::make($request->new_password),
            'must_change_password' => false,
        ]);
        return $this->success('Password changed successfully.');
    }

    public function forceChangePassword(Request $request)
    {
        $request->validate([
            'new_password' => 'required|string|min:6|confirmed',
        ]);

        $user = Auth::user();

        $user->update([
            'password' => Hash::make($request->new_password),
            'must_change_password' => false,
        ]);

        return $this->success('Password set successfully. You can now continue.');
    }

    public function notifications()
    {
        // TODO: replace with actual notification table/query
        return $this->success('Notifications retrieved.', []);
    }
}
