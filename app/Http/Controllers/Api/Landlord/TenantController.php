<?php

namespace App\Http\Controllers\Api\Landlord;

use App\Http\Controllers\Controller;
use App\Models\Tenant;
use App\Models\Unit;
use App\Models\User;
use App\Services\SmsService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class TenantController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $query = Tenant::with(['user', 'unit'])->latest();
        return $this->paginated($query->paginate($request->get('per_page', 20)));
    }

    public function store(Request $request)
    {
        $request->validate([
            'full_name' => 'required|string|max:255',
            'phone' => 'required|string|unique:users,phone',
            'unit_id' => 'required|uuid|exists:units,id',
            'id_number' => 'nullable|string',
            'emergency_contact' => 'nullable|string',
            'moved_in_date' => 'required|date',
        ]);

        $password = Str::random(8);

        $user = User::create([
            'full_name' => $request->full_name,
            'phone' => $request->phone,
            'password' => Hash::make($password),
            'role' => 'tenant',
            'status' => 'active',
            'must_change_password' => true,
        ]);

        $unit = Unit::findOrFail($request->unit_id);
        $unit->update(['status' => 'occupied']);

        $tenant = Tenant::create([
            'user_id' => $user->id,
            'unit_id' => $unit->id,
            'id_number' => $request->id_number,
            'emergency_contact' => $request->emergency_contact,
            'moved_in_date' => $request->moved_in_date,
            'status' => 'active',
        ]);

        $message = "Karibu Manna Apartment, {$user->full_name}!\n"
            . "Namba ya kuingia: {$request->phone}\n"
            . "Nenosiri lako la muda: {$password}\n"
            . "Tafadhali badilisha nenosiri lako ukiingia mara ya kwanza.";

        app(SmsService::class)->send(
            $request->phone,
            $message,
            'tenant_invite',
            Auth::user()->organization_id
        );

        return $this->success('Tenant created. Credentials sent via SMS.', [
            'tenant' => $tenant->load(['user', 'unit']),
        ], 201);
    }

    public function show($id)
    {
        $tenant = Tenant::with(['user', 'unit', 'contracts', 'payments'])->findOrFail($id);
        return $this->success('Tenant retrieved.', $tenant);
    }

    public function update(Request $request, $id)
    {
        $tenant = Tenant::findOrFail($id);
        $tenant->update($request->only(['id_number', 'emergency_contact', 'status']));
        return $this->success('Tenant updated.', $tenant);
    }

    public function moveOut($id)
    {
        $tenant = Tenant::findOrFail($id);
        $tenant->update([
            'status' => 'moved_out',
            'moved_out_date' => now(),
        ]);

        if ($tenant->unit) {
            $tenant->unit->update(['status' => 'vacant']);
        }

        return $this->success('Tenant moved out.', $tenant);
    }

    public function destroy($id)
    {
        $tenant = Tenant::findOrFail($id);
        $tenant->delete();
        return $this->success('Tenant deleted.');
    }
}
