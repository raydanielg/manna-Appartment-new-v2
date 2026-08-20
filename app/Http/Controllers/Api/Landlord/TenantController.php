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
        $query = Tenant::with(['user', 'unit.property'])->latest();
        return $this->paginated($query->paginate($request->get('per_page', 20)));
    }

    public function store(Request $request)
    {
        $request->validate([
            'full_name' => 'required|string|max:255',
            'phone' => 'required|string',
            'unit_id' => 'required|uuid|exists:units,id',
            'id_number' => 'nullable|string',
            'emergency_contact' => 'nullable|string',
            'moved_in_date' => 'required|date',
        ]);

        $user = User::withoutGlobalScope('organization')
            ->where('phone', $request->phone)
            ->first();

        $password = Str::random(8);

        if ($user) {
            // Check if this unit already has an active tenant
            $activeTenantInUnit = Tenant::where('unit_id', $request->unit_id)
                ->where('status', 'active')
                ->first();

            if ($activeTenantInUnit) {
                return $this->error('This unit already has an active tenant.', 422);
            }

            // Check if this user is already active in THIS specific unit
            $alreadyInThisUnit = Tenant::where('user_id', $user->id)
                ->where('unit_id', $request->unit_id)
                ->where('status', 'active')
                ->first();

            if ($alreadyInThisUnit) {
                return $this->error('This user is already an active tenant in this unit.', 422);
            }

            // If user belongs to another organization, we cannot reuse them due to global unique constraint on phone
            if ($user->organization_id && $user->organization_id !== Auth::user()->organization_id) {
                return $this->error('This phone number is already registered to another user/organization.', 422);
            }

            // Update user to ensure they have the tenant role and correct organization if it was null
            $user->update([
                'role' => 'tenant',
                'organization_id' => Auth::user()->organization_id,
            ]);
        } else {
            $user = User::create([
                'full_name' => $request->full_name,
                'phone' => $request->phone,
                'password' => Hash::make($password),
                'role' => 'tenant',
                'status' => 'active',
                'organization_id' => Auth::user()->organization_id,
                'must_change_password' => true,
            ]);
        }

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
        $appLink = config('app.app_download_url', 'https://play.google.com/store/apps/details?id=com.manna.apartment');
        $message = "Karibu Manna Apartment, {$user->full_name}!\n"
            . "Pakua App: {$appLink}\n"
            . "Namba ya kuingia: {$request->phone}\n"
            . "Nenosiri la muda: {$password}\n"
            . "Badilisha nenosiri baada ya kuingia.";

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
        $request->validate([
            'full_name' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:255',
            'email' => 'nullable|email|max:255',
            'id_number' => 'nullable|string|max:255',
            'emergency_contact' => 'nullable|string|max:255',
            'status' => 'nullable|in:active,moved_out',
        ]);

        $tenant = Tenant::findOrFail($id);
        $tenant->update($request->only(['id_number', 'emergency_contact', 'status']));

        if ($tenant->user) {
            $userData = [];
            if ($request->filled('full_name')) {
                $userData['full_name'] = $request->full_name;
            }
            if ($request->filled('phone')) {
                $userData['phone'] = $request->phone;
            }
            if ($request->filled('email')) {
                $userData['email'] = $request->email;
            }
            if (!empty($userData)) {
                $tenant->user->update($userData);
            }
        }

        return $this->success('Tenant updated.', $tenant->load(['user', 'unit.property']));
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

    public function sendCredentials($id)
    {
        $tenant = Tenant::with(['user', 'unit.property'])->findOrFail($id);
        $user = $tenant->user;

        if (!$user) {
            return $this->error('Tenant user not found.', 404);
        }

        $password = Str::random(8);
        $user->update([
            'password' => Hash::make($password),
            'must_change_password' => true,
            'status' => 'active',
        ]);

        $appLink = config('app.app_download_url', 'https://play.google.com/store/apps/details?id=com.manna.apartment');
        $message = "Manna Apartment - Vitambulisho vyako vya kuingia:\n"
            . "Pakua App: {$appLink}\n"
            . "Namba ya kuingia: {$user->phone}\n"
            . "Nenosiri la muda: {$password}\n"
            . "Badilisha nenosiri baada ya kuingia.";

        app(SmsService::class)->send(
            $user->phone,
            $message,
            'tenant_credentials',
            Auth::user()->organization_id
        );

        return $this->success('Credentials sent via SMS.', [
            'phone' => $user->phone,
        ]);
    }
}
