<?php

namespace App\Services;

use App\Models\Contract;
use App\Models\Payment;
use Illuminate\Support\Facades\DB;

class FinanceReportService
{
    public function incomeSummary(?string $organizationId = null): array
    {
        $query = Payment::where('status', 'confirmed');
        if ($organizationId) {
            $query->where('organization_id', $organizationId);
        }

        return [
            'total_income' => $query->sum('amount'),
            'total_payments' => $query->count(),
        ];
    }

    public function outstandingBalances(?string $organizationId = null): array
    {
        $query = Contract::where('status', 'active');
        if ($organizationId) {
            $query->where('organization_id', $organizationId);
        }

        return $query->with(['tenant.user', 'payments'])->get()->map(function ($contract) {
            $paid = $contract->payments->where('status', 'confirmed')->sum('amount');
            return [
                'tenant' => $contract->tenant->user->full_name ?? null,
                'expected' => $contract->rent_amount,
                'paid' => $paid,
                'balance' => max(0, $contract->rent_amount - $paid),
            ];
        })->toArray();
    }
}
