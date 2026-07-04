<?php

namespace App\Http\Controllers\Api\Landlord;

use App\Http\Controllers\Controller;
use App\Models\Contract;
use App\Models\Payment;
use App\Models\Tenant;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class FinanceController extends Controller
{
    use ApiResponse;

    public function summary()
    {
        $totalIncome = Payment::where('status', 'confirmed')->sum('amount');
        $totalOutstanding = Contract::where('status', 'active')->sum('rent_amount') - $totalIncome;
        $totalContracts = Contract::where('status', 'active')->count();
        $totalPayments = Payment::where('status', 'confirmed')->count();

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
        )->where('status', 'confirmed')->groupBy('month')->orderBy('month', 'desc')->limit(12)->get();

        return $this->success('Income trend retrieved.', $trend);
    }

    public function outstandingBalances()
    {
        $balances = Tenant::with(['user', 'unit'])
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
        // TODO: implement CSV/PDF export
        return $this->success('Export generated.', ['download_url' => null]);
    }
}
