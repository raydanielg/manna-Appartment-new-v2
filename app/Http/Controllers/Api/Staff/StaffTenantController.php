<?php

namespace App\Http\Controllers\Api\Staff;

use App\Http\Controllers\Controller;
use App\Models\Tenant;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class StaffTenantController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $tenants = Tenant::with(['user', 'unit'])->latest()->paginate($request->get('per_page', 20));
        return $this->paginated($tenants);
    }

    public function show($id)
    {
        $tenant = Tenant::with(['user', 'unit', 'contracts', 'payments'])->findOrFail($id);
        return $this->success('Tenant retrieved.', $tenant);
    }
}
