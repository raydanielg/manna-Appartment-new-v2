<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Contract;
use App\Models\KycDocument;
use App\Models\Organization;
use App\Models\Payment;
use App\Models\Property;
use App\Models\Tenant;
use App\Models\Unit;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function __construct()
    {
        $this->middleware(['auth']);
    }

    public function index(Request $request)
    {
        $stats = [
            'totalOrganizations' => Organization::count(),
            'activeOrganizations' => Organization::where('status', 'active')->count(),
            'pendingKyc' => KycDocument::where('status', 'pending')->count(),
            'totalProperties' => Property::count(),
            'totalUnits' => Unit::count(),
            'vacantUnits' => Unit::where('status', 'vacant')->count(),
            'occupiedUnits' => Unit::where('status', 'occupied')->count(),
            'totalTenants' => Tenant::count(),
            'activeContracts' => Contract::where('status', 'active')->count(),
            'totalRevenue' => Payment::where('status', 'confirmed')->sum('amount'),
        ];

        $dailyRevenue = [];
        $dailyLabels = [];
        for ($i = 13; $i >= 0; $i--) {
            $date = Carbon::now()->subDays($i);
            $dailyRevenue[] = Payment::where('status', 'confirmed')
                ->whereDate('payment_date', $date)
                ->sum('amount');
            $dailyLabels[] = $date->format('M d');
        }

        $recentPayments = Payment::with(['tenant.user', 'organization'])
            ->where('status', 'confirmed')
            ->latest()
            ->limit(10)
            ->get();

        $topOrganizations = Organization::withSum('payments', 'amount')
            ->orderByDesc('payments_sum_amount')
            ->limit(10)
            ->get();

        return view('admin.dashboard', compact('stats', 'dailyRevenue', 'dailyLabels', 'recentPayments', 'topOrganizations'));
    }
}
