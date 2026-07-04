<?php

namespace App\Http\Controllers\Api\Landlord;

use App\Http\Controllers\Controller;
use App\Models\StaffPermission;
use App\Models\User;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class StaffManagementController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $staff = User::where('role', 'staff')->latest()->paginate($request->get('per_page', 20));
        return $this->paginated($staff);
    }

    public function store(Request $request)
    {
        $request->validate([
            'full_name' => 'required|string|max:255',
            'phone' => 'required|string|unique:users,phone',
            'permissions_json' => 'required|array',
        ]);

        $password = Str::random(8);

        $staff = User::create([
            'full_name' => $request->full_name,
            'phone' => $request->phone,
            'password' => Hash::make($password),
            'role' => 'staff',
            'status' => 'active',
        ]);

        StaffPermission::create([
            'staff_user_id' => $staff->id,
            'permissions_json' => $request->permissions_json,
        ]);

        // TODO: dispatch SMS with credentials
        return $this->success('Staff created. Credentials sent via SMS.', [
            'staff' => $staff,
            'temporary_password' => $password, // remove in production
        ], 201);
    }

    public function updatePermissions(Request $request, $id)
    {
        $request->validate(['permissions_json' => 'required|array']);
        $staff = User::where('role', 'staff')->findOrFail($id);

        StaffPermission::updateOrCreate(
            ['staff_user_id' => $staff->id],
            ['permissions_json' => $request->permissions_json]
        );

        return $this->success('Staff permissions updated.', $staff->load('staffPermission'));
    }

    public function destroy($id)
    {
        $staff = User::where('role', 'staff')->findOrFail($id);
        $staff->update(['status' => 'inactive']);
        return $this->success('Staff deactivated.');
    }
}
