<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Organization;
use App\Models\User;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class LandlordManagementController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $query = Organization::with(['owner'])->latest();

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('business_name', 'like', "%{$search}%")
                  ->orWhereHas('owner', function ($oq) use ($search) {
                      $oq->where('full_name', 'like', "%{$search}%")
                         ->orWhere('phone', 'like', "%{$search}%");
                  });
            });
        }

        return $this->paginated($query->paginate($request->get('per_page', 20)));
    }

    public function show($id)
    {
        $org = Organization::with(['owner', 'subscription', 'properties'])->findOrFail($id);
        return $this->success('Organization retrieved.', $org);
    }

    public function store(Request $request)
    {
        $request->validate([
            'full_name' => 'required|string|max:255',
            'phone' => 'required|string|unique:users,phone',
            'email' => 'nullable|email|unique:users,email',
            'business_name' => 'required|string|max:255',
            'password' => 'required|string|min:6',
        ]);

        $owner = User::create([
            'full_name' => $request->full_name,
            'phone' => $request->phone,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => 'landlord',
            'status' => 'active',
        ]);

        $organization = Organization::create([
            'owner_user_id' => $owner->id,
            'business_name' => $request->business_name,
            'kyc_status' => 'pending',
            'status' => 'active',
            'sms_balance' => 0,
        ]);

        $owner->update(['organization_id' => $organization->id]);

        return $this->success('Landlord created.', $organization->load('owner'), 201);
    }

    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:active,suspended,deactivated',
            'reason' => 'nullable|string',
        ]);

        $organization = Organization::findOrFail($id);
        $organization->update([
            'status' => $request->status,
            'suspension_reason' => $request->reason,
        ]);

        if ($organization->owner) {
            $organization->owner->update(['status' => $request->status === 'active' ? 'active' : 'suspended']);
        }

        return $this->success('Organization status updated.', $organization->load('owner'));
    }

    public function updateKycStatus(Request $request, $id)
    {
        $request->validate([
            'kyc_status' => 'required|in:pending,approved,rejected',
        ]);

        $organization = Organization::findOrFail($id);
        $organization->update(['kyc_status' => $request->kyc_status]);

        return $this->success('KYC status updated.', $organization->load('owner'));
    }

    public function destroy($id)
    {
        $organization = Organization::findOrFail($id);
        if ($organization->owner) {
            $organization->owner->delete();
        }
        $organization->delete();
        return $this->success('Landlord deleted.');
    }
}
