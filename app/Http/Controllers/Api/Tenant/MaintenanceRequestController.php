<?php

namespace App\Http\Controllers\Api\Tenant;

use App\Http\Controllers\Controller;
use App\Models\MaintenanceRequest;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class MaintenanceRequestController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $user = Auth::user();
        $tenant = $user->tenant;

        if (!$tenant) {
            return $this->error('Tenant record not found.', null, 404);
        }

        $requests = MaintenanceRequest::where('tenant_id', $tenant->id)->latest()->paginate($request->get('per_page', 20));
        return $this->paginated($requests);
    }

    public function store(Request $request)
    {
        $user = Auth::user();
        $tenant = $user->tenant;

        if (!$tenant || !$tenant->unit) {
            return $this->error('No unit assigned.', null, 404);
        }

        $request->validate(['description' => 'required|string']);

        $maintenance = MaintenanceRequest::create([
            'tenant_id' => $tenant->id,
            'unit_id' => $tenant->unit_id,
            'description' => $request->description,
            'status' => 'open',
        ]);

        return $this->success('Maintenance request submitted.', $maintenance, 201);
    }
}
