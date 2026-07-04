<?php

namespace App\Http\Controllers\Api\Staff;

use App\Http\Controllers\Controller;
use App\Models\Contract;
use App\Models\Payment;
use App\Models\Tenant;
use App\Models\Unit;
use App\Traits\ApiResponse;
use Illuminate\Support\Facades\Auth;

class StaffDashboardController extends Controller
{
    use ApiResponse;

    public function index()
    {
        $organization = Auth::user()->organization;

        return $this->success('Dashboard retrieved.', [
            'total_tenants' => Tenant::count(),
            'active_contracts' => Contract::where('status', 'active')->count(),
            'vacant_units' => Unit::where('status', 'vacant')->count(),
            'occupied_units' => Unit::where('status', 'occupied')->count(),
            'recent_payments' => Payment::where('status', 'confirmed')->latest()->limit(5)->get(),
        ]);
    }
}
