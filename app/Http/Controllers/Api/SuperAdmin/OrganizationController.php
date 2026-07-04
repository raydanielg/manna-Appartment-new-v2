<?php

namespace App\Http\Controllers\Api\SuperAdmin;

use App\Http\Controllers\Controller;
use App\Models\Organization;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class OrganizationController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $query = Organization::with('owner')->latest();

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('kyc_status')) {
            $query->where('kyc_status', $request->kyc_status);
        }

        return $this->paginated($query->paginate($request->get('per_page', 20)));
    }

    public function show($id)
    {
        $organization = Organization::with(['owner', 'properties', 'tenants'])->findOrFail($id);
        return $this->success('Organization retrieved.', $organization);
    }

    public function suspend($id)
    {
        $organization = Organization::findOrFail($id);
        $organization->update(['status' => 'suspended']);
        return $this->success('Organization suspended.', $organization);
    }

    public function activate($id)
    {
        $organization = Organization::findOrFail($id);
        $organization->update(['status' => 'active']);
        return $this->success('Organization activated.', $organization);
    }
}
