<?php

namespace App\Http\Controllers\Api\Landlord;

use App\Http\Controllers\Controller;
use App\Models\Contract;
use App\Models\Payment;
use App\Models\Tenant;
use App\Traits\ApiResponse;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class FinanceController extends Controller
{
    use ApiResponse;

    public function report(Request $request)
    {
        return match ($request->get('type', 'revenue')) {
            'lease' => $this->leaseReport($request),
            'expiry' => $this->expiryReport($request),
            'debts' => $this->debtReport($request),
            default => $this->revenueReport($request),
        };
    }

    private function revenueReport(Request $request)
    {
        $period = $request->get('period', 'monthly');
        $year = (int) $request->get('year', now()->year);
        $month = $request->filled('month') ? (int) $request->month : null;
        $propertyId = $request->get('property_id');
        $unitId = $request->get('unit_id');

        $query = Payment::query()
            ->where('status', 'confirmed')
            ->where('organization_id', Auth::user()->organization_id)
            ->when($propertyId, fn ($q) => $q->whereHas('contract.unit', fn ($u) => $u->where('property_id', $propertyId)))
            ->when($unitId, fn ($q) => $q->whereHas('contract', fn ($c) => $c->where('unit_id', $unitId)));

        $contractsQuery = Contract::query()
            ->where('organization_id', Auth::user()->organization_id)
            ->when($propertyId, fn ($q) => $q->whereHas('unit', fn ($u) => $u->where('property_id', $propertyId)))
            ->when($unitId, fn ($q) => $q->where('unit_id', $unitId));

        $range = $this->dateRange($period, $year, $month);

        $collected = (float) (clone $query)
            ->whereBetween('payment_date', [$range['start'], $range['end']])
            ->sum('amount');

        $expected = (float) (clone $contractsQuery)
            ->whereDate('start_date', '<=', $range['end'])
            ->whereDate('end_date', '>=', $range['start'])
            ->sum('rent_amount');

        $breakdown = $this->buildBreakdown($period, $year, $month, $query, $contractsQuery, $range);

        $collectionRate = $expected > 0 ? round(($collected / $expected) * 100, 1) : 0;

        return $this->success('Finance report retrieved.', [
            'period' => $period,
            'year' => $year,
            'month' => $month,
            'total_revenue' => $collected,
            'collected_revenue' => $collected,
            'expected_revenue' => $expected,
            'outstanding_revenue' => max(0, $expected - $collected),
            'collection_rate' => $collectionRate,
            'breakdown' => $breakdown,
            'chart_data' => $breakdown,
        ]);
    }

    private function leaseReport(Request $request)
    {
        $year = (int) $request->get('year', now()->year);
        $propertyId = $request->get('property_id');
        $orgId = Auth::user()->organization_id;

        $contracts = Contract::with(['tenant.user', 'unit.property'])
            ->where('organization_id', $orgId)
            ->where('status', 'active')
            ->when($propertyId, fn ($q) => $q->whereHas('unit', fn ($u) => $u->where('property_id', $propertyId)))
            ->whereDate('start_date', '<=', Carbon::createFromDate($year, 12, 31)->endOfYear())
            ->where(function ($q) use ($year) {
                $q->whereNull('end_date')->orWhereDate('end_date', '>=', Carbon::createFromDate($year, 1, 1)->startOfYear());
            })
            ->get();

        $totalExpected = 0.0;
        $totalCollected = 0.0;
        $leases = [];

        foreach ($contracts as $contract) {
            $expected = (float) $contract->rent_amount;
            $collected = (float) Payment::where('contract_id', $contract->id)
                ->where('organization_id', $orgId)
                ->where('status', 'confirmed')
                ->whereYear('payment_date', $year)
                ->sum('amount');
            $outstanding = max(0, $expected - $collected);

            $totalExpected += $expected;
            $totalCollected += $collected;

            $leases[] = [
                'contract_id' => $contract->id,
                'tenant_name' => $contract->tenant?->user?->full_name ?? 'Tenant',
                'property_name' => $contract->unit?->property?->name,
                'unit_name' => $contract->unit?->name,
                'expected' => $expected,
                'collected' => $collected,
                'outstanding' => $outstanding,
            ];
        }

        return $this->success('Lease report retrieved.', [
            'year' => $year,
            'expected' => $totalExpected,
            'collected' => $totalCollected,
            'outstanding' => max(0, $totalExpected - $totalCollected),
            'leases' => $leases,
        ]);
    }

    private function expiryReport(Request $request)
    {
        $daysAhead = (int) $request->get('days_ahead', 30);
        $propertyId = $request->get('property_id');
        $orgId = Auth::user()->organization_id;

        $base = Contract::with(['tenant.user', 'unit.property'])
            ->where('organization_id', $orgId)
            ->where('status', 'active')
            ->when($propertyId, fn ($q) => $q->whereHas('unit', fn ($u) => $u->where('property_id', $propertyId)));

        $expiring = (clone $base)
            ->whereDate('end_date', '>=', now()->toDateString())
            ->whereDate('end_date', '<=', now()->addDays($daysAhead)->toDateString())
            ->orderBy('end_date')
            ->get();

        $expired = (clone $base)
            ->whereDate('end_date', '<', now()->toDateString())
            ->orderByDesc('end_date')
            ->get();

        $map = fn ($contract) => [
            'contract_id' => $contract->id,
            'tenant_name' => $contract->tenant?->user?->full_name ?? 'Tenant',
            'property_name' => $contract->unit?->property?->name,
            'unit_name' => $contract->unit?->name,
            'end_date' => optional($contract->end_date)->toDateString(),
        ];

        return $this->success('Expiry report retrieved.', [
            'expiring' => $expiring->map($map)->values(),
            'expired' => $expired->map($map)->values(),
        ]);
    }

    private function debtReport(Request $request)
    {
        $propertyId = $request->get('property_id');
        $orgId = Auth::user()->organization_id;

        $tenants = Tenant::with(['user', 'unit.property'])
            ->where('organization_id', $orgId)
            ->whereHas('contracts', fn ($q) => $q->where('status', 'active'))
            ->when($propertyId, fn ($q) => $q->whereHas('unit', fn ($u) => $u->where('property_id', $propertyId)))
            ->get();

        $debts = [];
        $totalDebts = 0.0;

        foreach ($tenants as $tenant) {
            $contract = $tenant->contracts()->where('status', 'active')->latest()->first();
            if (!$contract) {
                continue;
            }

            $paid = (float) Payment::where('contract_id', $contract->id)
                ->where('organization_id', $orgId)
                ->where('status', 'confirmed')
                ->sum('amount');
            $outstanding = max(0, (float) $contract->rent_amount - $paid);

            if ($outstanding <= 0) {
                continue;
            }

            $totalDebts += $outstanding;
            $debts[] = [
                'tenant_id' => $tenant->id,
                'tenant_name' => $tenant->user?->full_name ?? 'Tenant',
                'property_name' => $tenant->unit?->property?->name,
                'unit_name' => $tenant->unit?->name,
                'amount' => $outstanding,
                'outstanding' => $outstanding,
            ];
        }

        return $this->success('Debt report retrieved.', [
            'debts' => $debts,
            'total_debts' => $totalDebts,
        ]);
    }

    private function dateRange(string $period, int $year, ?int $month): array
    {
        switch ($period) {
            case 'weekly':
                $start = now()->setISODate($year, $month ?? now()->weekOfYear)->startOfWeek();
                $end = $start->copy()->endOfWeek();
                break;
            case 'yearly':
                $start = Carbon::createFromDate($year, 1, 1)->startOfYear();
                $end = $start->copy()->endOfYear();
                break;
            case 'multi_year':
                $start = Carbon::createFromDate($year - 2, 1, 1)->startOfYear();
                $end = Carbon::createFromDate($year, 12, 31)->endOfYear();
                break;
            case 'monthly':
            default:
                $m = $month ?? now()->month;
                $start = Carbon::createFromDate($year, $m, 1)->startOfMonth();
                $end = $start->copy()->endOfMonth();
                break;
        }

        return ['start' => $start, 'end' => $end];
    }

    private function buildBreakdown(string $period, int $year, ?int $month, $paymentQuery, $contractQuery, array $range): array
    {
        $data = [];

        if ($period === 'monthly' || $period === 'weekly') {
            $days = max(1, $range['start']->diffInDays($range['end']) + 1);
            $groupFormat = $period === 'monthly' ? 'd' : 'd MMM';

            for ($i = 0; $i < $days; $i++) {
                $date = $range['start']->copy()->addDays($i);
                $collected = (float) (clone $paymentQuery)
                    ->whereDate('payment_date', $date)
                    ->sum('amount');
                $data[] = [
                    'label' => $date->format($groupFormat),
                    'date' => $date->toDateString(),
                    'amount' => $collected,
                    'revenue' => $collected,
                ];
            }
        } elseif ($period === 'yearly' || $period === 'multi_year') {
            $startYear = $period === 'multi_year' ? $year - 2 : $year;
            $endYear = $year;

            for ($y = $startYear; $y <= $endYear; $y++) {
                for ($m = 1; $m <= 12; $m++) {
                    $monthStart = Carbon::createFromDate($y, $m, 1)->startOfMonth();
                    $monthEnd = $monthStart->copy()->endOfMonth();
                    $collected = (float) (clone $paymentQuery)
                        ->whereBetween('payment_date', [$monthStart, $monthEnd])
                        ->sum('amount');
                    $data[] = [
                        'label' => $monthStart->format('M Y'),
                        'month' => $monthStart->format('Y-m'),
                        'amount' => $collected,
                        'revenue' => $collected,
                    ];
                }
            }
        }

        return $data;
    }

    public function summary()
    {
        $orgId = Auth::user()->organization_id;

        $totalIncome = Payment::where('organization_id', $orgId)->where('status', 'confirmed')->sum('amount');
        $totalOutstanding = Contract::where('organization_id', $orgId)->where('status', 'active')->sum('rent_amount') - $totalIncome;
        $totalContracts = Contract::where('organization_id', $orgId)->where('status', 'active')->count();
        $totalPayments = Payment::where('organization_id', $orgId)->where('status', 'confirmed')->count();

        return $this->success('Finance summary retrieved.', [
            'total_income' => $totalIncome,
            'total_outstanding' => max(0, $totalOutstanding),
            'active_contracts' => $totalContracts,
            'total_payments' => $totalPayments,
        ]);
    }

    public function incomeTrend(Request $request)
    {
        $trend = Payment::select(
            DB::raw('DATE_FORMAT(payment_date, "%Y-%m") as month'),
            DB::raw('SUM(amount) as total')
        )->where('organization_id', Auth::user()->organization_id)
            ->where('status', 'confirmed')->groupBy('month')->orderBy('month', 'desc')->limit(12)->get();

        return $this->success('Income trend retrieved.', $trend);
    }

    public function outstandingBalances()
    {
        $balances = Tenant::with(['user', 'unit'])
            ->where('organization_id', Auth::user()->organization_id)
            ->whereHas('contracts', function ($q) {
                $q->where('status', 'active');
            })
            ->withSum('payments', 'amount')
            ->get()
            ->map(function ($tenant) {
                $contract = $tenant->contracts()->where('status', 'active')->first();
                $expected = $contract ? $contract->rent_amount : 0;
                $paid = $tenant->payments_sum_amount ?? 0;
                return [
                    'tenant' => $tenant->user->full_name,
                    'unit' => $tenant->unit->name ?? null,
                    'expected' => $expected,
                    'paid' => $paid,
                    'balance' => max(0, $expected - $paid),
                ];
            });

        return $this->success('Outstanding balances retrieved.', $balances);
    }

    public function export(Request $request)
    {
        $period = $request->get('period', 'monthly');
        $year = (int) $request->get('year', now()->year);
        $month = $request->filled('month') ? (int) $request->month : null;
        $propertyId = $request->get('property_id');
        $unitId = $request->get('unit_id');
        $orgId = Auth::user()->organization_id;

        $range = $this->dateRange($period, $year, $month);

        $payments = Payment::query()
            ->with(['tenant.user', 'contract.unit.property'])
            ->where('status', 'confirmed')
            ->where('organization_id', $orgId)
            ->whereBetween('payment_date', [$range['start'], $range['end']])
            ->when($propertyId, fn ($q) => $q->whereHas('contract.unit', fn ($u) => $u->where('property_id', $propertyId)))
            ->when($unitId, fn ($q) => $q->whereHas('contract', fn ($c) => $c->where('unit_id', $unitId)))
            ->orderBy('payment_date')
            ->get();

        $filename = "revenue-report-{$range['start']->format('Ymd')}-{$range['end']->format('Ymd')}.csv";

        return response()->streamDownload(function () use ($payments) {
            $out = fopen('php://output', 'w');
            fputcsv($out, ['Date', 'Tenant', 'Property', 'Unit', 'Type', 'Method', 'Month Covered', 'Amount (TZS)', 'Reference']);

            $total = 0.0;
            foreach ($payments as $p) {
                $total += (float) $p->amount;
                fputcsv($out, [
                    optional($p->payment_date)->toDateString(),
                    $p->tenant?->user?->full_name ?? $p->tenant?->full_name ?? '-',
                    $p->contract?->unit?->property?->name ?? '-',
                    $p->contract?->unit?->name ?? $p->contract?->unit?->unit_number ?? '-',
                    $p->payment_type ?? '-',
                    $p->method ?? '-',
                    $p->month_covered ?? '-',
                    number_format((float) $p->amount, 2, '.', ''),
                    $p->reference_number ?? '-',
                ]);
            }

            fputcsv($out, []);
            fputcsv($out, ['', '', '', '', '', '', 'TOTAL', number_format($total, 2, '.', ''), '']);
            fclose($out);
        }, $filename, [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => "attachment; filename=\"{$filename}\"",
        ]);
    }
}
