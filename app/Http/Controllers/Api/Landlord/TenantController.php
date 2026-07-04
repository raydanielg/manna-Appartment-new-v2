<?php

namespace App\Http\Controllers\Api\Landlord;

use App\Http\Controllers\Controller;
use App\Models\AppNotification;
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

        $property = $unit->property;
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

        AppNotification::create([
            'user_id' => $user->id,
            'title' => 'Welcome to Manna Apartment',
            'body' => "You have been added as a tenant at {$property->name}. Unit: {$unit->name}. Login with your phone number and temporary password.",
            'type' => 'tenant_invite',
            'data' => [
                'property_id' => $property->id,
                'property_name' => $property->name,
                'property_address' => $property->address ?? $property->location,
                'unit_id' => $unit->id,
                'unit_name' => $unit->name,
                'phone' => $request->phone,
            ],
            'sent_at' => now(),
        ]);

        return $this->success('Tenant created. Credentials sent via SMS.', [
            'tenant' => $tenant->load(['user', 'unit']),
        ], 201);
    }

    public function show($id)
    {
        $tenant = Tenant::with(['user', 'unit.property', 'contracts', 'payments'])->findOrFail($id);

        $totalRent = $tenant->unit?->rent_amount ?? 0;
        $paid = $tenant->payments->sum('amount');
        $balanceDue = max(0, $totalRent - $paid);

        return $this->success('Tenant retrieved.', [
            'id' => $tenant->id,
            'full_name' => $tenant->user?->full_name,
            'phone' => $tenant->user?->phone,
            'email' => $tenant->user?->email,
            'status' => $tenant->status,
            'id_number' => $tenant->id_number,
            'emergency_contact' => $tenant->emergency_contact,
            'moved_in_date' => $tenant->moved_in_date,
            'moved_out_date' => $tenant->moved_out_date,
            'balance_due' => $balanceDue,
            'total_paid' => $paid,
            'rent_amount' => $totalRent,
            'unit' => $tenant->unit ? [
                'id' => $tenant->unit->id,
                'name' => $tenant->unit->name ?? $tenant->unit->unit_number,
                'rent_amount' => $tenant->unit->rent_amount,
                'property' => $tenant->unit->property ? [
                    'id' => $tenant->unit->property->id,
                    'name' => $tenant->unit->property->name,
                    'address' => $tenant->unit->property->address ?? $tenant->unit->property->location,
                ] : null,
            ] : null,
            'payments' => $tenant->payments->map(fn ($p) => [
                'id' => $p->id,
                'amount' => $p->amount,
                'payment_date' => $p->payment_date,
                'status' => $p->status,
                'reference' => $p->reference,
            ]),
            'contracts' => $tenant->contracts,
        ]);
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
