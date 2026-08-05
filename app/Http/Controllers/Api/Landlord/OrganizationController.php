<?php

namespace App\Http\Controllers\Api\Landlord;

use App\Http\Controllers\Controller;
use App\Models\KycDocument;
use App\Models\Organization;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

class OrganizationController extends Controller
{
    use ApiResponse;

    public function show()
    {
        $user = Auth::user();
        $organization = Organization::find($user->organization_id);
        
        if (!$organization) {
            return $this->error('No organization found for this account.', null, 400);
        }
        return $this->success('Organization retrieved.', $organization);
    }

    public function store(Request $request)
    {
        $request->validate([
            'business_name' => 'required|string|max:255',
        ]);

        $user = Auth::user();
        
        // Check if organization actually exists in DB
        if ($user->organization_id && Organization::where('id', $user->organization_id)->exists()) {
            return $this->error('User already has an organization.', null, 400);
        }

        $organization = Organization::create([
            'business_name' => $request->business_name,
            'kyc_status' => 'pending',
            'sms_balance' => 0,
            'status' => 'active',
            'owner_user_id' => $user->id,
        ]);

        $user->update(['organization_id' => $organization->id]);

        return $this->success('Organization created successfully.', $organization, 201);
    }

    public function update(Request $request)
    {
        $user = Auth::user();
        $organization = Organization::find($user->organization_id);

        if (!$organization) {
            return $this->error('No organization found for this account.', null, 400);
        }
        $organization->update($request->only(['business_name']));
        return $this->success('Organization updated.', $organization);
    }

    public function usage()
    {
        $user = Auth::user();
        $organization = Organization::find($user->organization_id);
        if (!$organization) {
            return $this->error('No organization found for this account.', null, 400);
        }
        $plan = optional($organization->subscription)->plan;

        return $this->success('Usage retrieved.', [
            'properties_count' => $organization->properties()->count(),
            'units_count' => $organization->properties()->withCount('units')->get()->sum('units_count'),
            'tenants_count' => $organization->tenants()->count(),
            'sms_balance' => $organization->sms_balance,
            'plan' => $plan,
            'property_limit' => $plan ? $plan->property_limit : 0,
            'unit_limit' => $plan ? $plan->unit_limit : 0,
        ]);
    }

    public function submitKyc(Request $request)
    {
        $request->validate([
            'id_number' => 'required|string',
            'id_photo_front' => 'required|image|max:5120',
            'id_photo_back' => 'required|image|max:5120',
            'selfie_photo' => 'required|image|max:5120',
            'ownership_proof' => 'nullable|mimes:jpg,png,pdf|max:5120',
        ]);

        $user = Auth::user();
        $organization = Organization::find($user->organization_id);

        if (!$organization) {
            return $this->error('No organization found for this account.', null, 400);
        }

        try {
            $paths = [];
            foreach (['id_photo_front', 'id_photo_back', 'selfie_photo', 'ownership_proof'] as $field) {
                if ($request->hasFile($field)) {
                    $paths[$field] = Storage::disk('public')->put('kyc/' . $organization->id, $request->file($field));
                }
            }

            $kyc = KycDocument::updateOrCreate(
                ['organization_id' => $organization->id],
                array_merge($request->only(['id_number']), $paths, ['status' => 'pending'])
            );

            $organization->update(['kyc_status' => 'pending']);

            return $this->success('KYC submitted successfully.', $kyc, 201);
        } catch (\Exception $e) {
            Log::error('KYC submit failed', [
                'organization_id' => $organization->id,
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            return $this->error('Could not submit KYC. Please try again.', null, 500);
        }
    }

    public function kycStatus()
    {
        $user = Auth::user();
        $organization = Organization::find($user->organization_id);
        if (!$organization) {
            return $this->success('KYC status retrieved.', [
                'kyc_status' => 'pending',
                'documents' => null,
            ]);
        }
        $kyc = KycDocument::where('organization_id', $organization->id)->first();

        return $this->success('KYC status retrieved.', [
            'kyc_status' => $organization->kyc_status,
            'documents' => $kyc,
        ]);
    }
}
