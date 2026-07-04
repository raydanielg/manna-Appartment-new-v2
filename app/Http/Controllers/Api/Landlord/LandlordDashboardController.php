<?php

namespace App\Http\Controllers\Api\Landlord;

use App\Http\Controllers\Controller;
use App\Models\Contract;
use App\Models\MaintenanceRequest;
use App\Models\Payment;
use App\Models\Property;
use App\Models\Tenant;
use App\Traits\ApiResponse;
use Illuminate\Support\Facades\DB;

class LandlordDashboardController extends Controller
{
    use ApiResponse;

    public function index()
    {
        $propertiesCount = Property::count();
        $tenantsCount = Tenant::where('status', 'active')->count();

        $monthIncome = Payment::where('status', 'confirmed')
            ->whereMonth('payment_date', now()->month)
            ->whereYear('payment_date', now()->year)
            ->sum('amount');

        $totalIncome = Payment::where('status', 'confirmed')->sum('amount');
        $totalExpected = Contract::where('status', 'active')->sum('rent_amount');
        $outstanding = max(0, $totalExpected - $totalIncome);

        $monthlyIncome = Payment::select(
            DB::raw('DATE_FORMAT(payment_date, "%b") as month'),
            DB::raw('SUM(amount) as amount')
        )
            ->where('status', 'confirmed')
            ->where('payment_date', '>=', now()->subMonths(6)->startOfMonth())
            ->groupBy('month')
            ->orderBy('payment_date', 'asc')
            ->limit(6)
            ->get()
            ->map(fn ($r) => ['month' => $r->month, 'amount' => (float) $r->amount]);

        $recentPayments = Payment::with('tenant.user')
            ->where('status', 'confirmed')
            ->latest('payment_date')
            ->limit(3)
            ->get()
            ->map(fn ($p) => [
                'title' => ($p->tenant?->user?->full_name ?? 'Unknown') . ' paid',
                'subtitle' => number_format($p->amount, 0, '.', ',') . ' TZS',
                'status' => 'success',
            ]);

        $recentMaintenance = MaintenanceRequest::with('tenant.user')
            ->latest()
            ->limit(2)
            ->get()
            ->map(fn ($m) => [
                'title' => 'Maintenance request',
                'subtitle' => $m->tenant?->user?->full_name ?? 'Unknown',
                'status' => $m->status === 'resolved' ? 'success' : 'warning',
            ]);

        $recentActivity = $recentPayments->concat($recentMaintenance)
            ->sortByDesc(fn () => now())
            ->take(5)
            ->values();

        return $this->success('Dashboard data retrieved.', [
            'properties_count' => $propertiesCount,
            'tenants_count' => $tenantsCount,
            'month_income' => (float) $monthIncome,
            'outstanding' => (float) $outstanding,
            'monthly_income' => $monthlyIncome,
            'recent_activity' => $recentActivity,
        ]);
    }
}
