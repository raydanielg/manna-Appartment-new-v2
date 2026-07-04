<?php

namespace App\Http\Controllers\Api\Tenant;

use App\Http\Controllers\Controller;
use App\Models\Contract;
use App\Models\MaintenanceRequest;
use App\Models\Payment;
use App\Models\Tenant;
use App\Traits\ApiResponse;

class TenantDashboardController extends Controller
{
    use ApiResponse;

    public function index()
    {
        $userId = auth()->id();
        $tenant = Tenant::where('user_id', $userId)->first();

        if (!$tenant) {
            return $this->success('Dashboard data retrieved.', [
                'unit' => null,
                'contract' => null,
                'balance' => 0,
                'recent_payments' => [],
                'maintenance_requests' => [],
            ]);
        }

        $contract = Contract::where('tenant_id', $tenant->id)
            ->where('status', 'active')
            ->first();

        $totalPaid = Payment::where('tenant_id', $tenant->id)
            ->where('status', 'confirmed')
            ->sum('amount');

        $rentAmount = $contract?->rent_amount ?? 0;
        $balance = max(0, $rentAmount - $totalPaid);

        $recentPayments = Payment::where('tenant_id', $tenant->id)
            ->where('status', 'confirmed')
            ->latest('payment_date')
            ->limit(5)
            ->get()
            ->map(fn ($p) => [
                'amount' => (float) $p->amount,
                'date' => $p->payment_date?->format('M d, Y'),
                'method' => $p->method,
            ]);

        $maintenanceRequests = MaintenanceRequest::where('tenant_id', $tenant->id)
            ->latest()
            ->limit(5)
            ->get()
            ->map(fn ($m) => [
                'description' => $m->description,
                'status' => $m->status,
                'created_at' => $m->created_at?->format('M d, Y'),
            ]);

        return $this->success('Dashboard data retrieved.', [
            'unit' => $tenant->unit ? [
                'name' => $tenant->unit->name,
                'property' => $tenant->unit->property?->name,
            ] : null,
            'contract' => $contract ? [
                'rent_amount' => (float) $contract->rent_amount,
                'start_date' => $contract->start_date?->format('M d, Y'),
                'end_date' => $contract->end_date?->format('M d, Y'),
                'status' => $contract->status,
            ] : null,
            'balance' => (float) $balance,
            'total_paid' => (float) $totalPaid,
            'recent_payments' => $recentPayments,
            'maintenance_requests' => $maintenanceRequests,
        ]);
    }
}
