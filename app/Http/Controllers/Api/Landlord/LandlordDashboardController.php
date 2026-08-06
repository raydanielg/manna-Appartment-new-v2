<?php

namespace App\Http\Controllers\Api\Landlord;

use App\Http\Controllers\Controller;
use App\Models\Contract;
use App\Models\MaintenanceRequest;
use App\Models\Payment;
use App\Models\Property;
use App\Models\Tenant;
use App\Traits\ApiResponse;

class LandlordDashboardController extends Controller
{
    use ApiResponse;

    public function index()
    {
        $propertiesCount = Property::count();
        $tenantsCount = Tenant::where('status', 'active')->count();
        $vacantUnitsCount = \App\Models\Unit::where('status', 'vacant')->count();

        $monthIncome = Payment::where('status', 'confirmed')
            ->whereMonth('payment_date', now()->month)
            ->whereYear('payment_date', now()->year)
            ->sum('amount');

        $totalIncome = Payment::where('status', 'confirmed')->sum('amount');
        $totalExpected = Contract::where('status', 'active')->sum('rent_amount');
        $outstanding = max(0, $totalExpected - $totalIncome);

        $monthlyIncome = collect();
        for ($i = 5; $i >= 0; $i--) {
            $date = now()->subMonths($i);
            $monthLabel = $date->format('M');

            $amount = Payment::where('status', 'confirmed')
                ->whereYear('payment_date', $date->year)
                ->whereMonth('payment_date', $date->month)
                ->sum('amount');

            $monthlyIncome->push([
                'month' => $monthLabel,
                'amount' => (float) $amount,
            ]);
        }

        $recentPayments = Payment::with(['tenant.user', 'tenant.unit'])
            ->where('status', 'confirmed')
            ->latest('payment_date')
            ->limit(3)
            ->get()
            ->map(fn ($p) => [
                'type' => 'payment',
                'title' => ($p->tenant?->user?->full_name ?? 'Unknown') . ' - ' . ($p->tenant?->unit?->name ?? 'N/A'),
                'subtitle' => number_format($p->amount, 0, '.', ',') . ' TZS (' . ($p->payment_type ?? 'Rent') . ')',
                'status' => 'success',
                'date' => $p->payment_date->format('d M, Y'),
            ]);

        $recentMaintenance = MaintenanceRequest::with(['tenant.user', 'unit'])
            ->latest()
            ->limit(2)
            ->get()
            ->map(fn ($m) => [
                'type' => 'maintenance',
                'title' => 'Maintenance: ' . ($m->unit?->name ?? 'N/A'),
                'subtitle' => $m->tenant?->user?->full_name ?? 'Unknown',
                'status' => $m->status === 'resolved' ? 'success' : ($m->status === 'pending' ? 'danger' : 'warning'),
                'date' => $m->created_at->format('d M, Y'),
            ]);

        $recentActivity = $recentPayments->concat($recentMaintenance)
            ->sortByDesc('date')
            ->take(5)
            ->values();

        return $this->success('Dashboard data retrieved.', [
            'properties_count' => $propertiesCount,
            'tenants_count' => $tenantsCount,
            'vacant_units_count' => $vacantUnitsCount,
            'month_income' => (float) $monthIncome,
            'outstanding' => (float) $outstanding,
            'monthly_income' => $monthlyIncome,
            'recent_activity' => $recentActivity,
        ]);
    }
}
