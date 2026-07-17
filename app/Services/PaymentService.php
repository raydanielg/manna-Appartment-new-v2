<?php

namespace App\Services;

use App\Models\Contract;
use App\Models\Payment;
use Carbon\Carbon;
use Illuminate\Support\Facades\Auth;

class PaymentService
{
    /**
     * Record a payment and auto-calculate overpayment coverage.
     */
    public function record(array $data): Payment
    {
        $contract = Contract::findOrFail($data['contract_id']);
        $rentAmount = (float) ($contract->rent_amount ?? 0);
        $amount = (float) ($data['amount'] ?? 0);
        $paymentDate = isset($data['payment_date']) ? Carbon::parse($data['payment_date']) : now();

        $calc = $this->calculateCoverage($amount, $rentAmount, $paymentDate, $data['month_covered'] ?? null);

        $payment = Payment::create(array_merge($data, [
            'recorded_by' => Auth::id(),
            'status' => 'confirmed',
            'payment_date' => $paymentDate->toDateString(),
            'month_covered' => $calc['month_covered'],
            'months_covered_count' => $calc['months_count'],
            'overdue_date' => $calc['overdue_date'],
        ]));

        return $payment;
    }

    /**
     * Calculate how many months a payment covers, the month_covered label,
     * and the next overdue date.
     *
     * @return array{months_count: int, month_covered: string, overdue_date: string|null, remainder: float, is_overpayment: bool}
     */
    public function calculateCoverage(float $amount, float $rentAmount, Carbon $paymentDate, ?string $providedMonth = null): array
    {
        if ($rentAmount <= 0) {
            return [
                'months_count' => 0,
                'month_covered' => $providedMonth ?? $paymentDate->format('F Y'),
                'overdue_date' => null,
                'remainder' => $amount,
                'is_overpayment' => false,
            ];
        }

        $monthsCount = (int) floor($amount / $rentAmount);
        $remainder = fmod($amount, $rentAmount);
        $isOverpayment = $monthsCount > 1;

        // Determine the starting month
        $startMonth = $providedMonth
            ? Carbon::parse('first day of ' . $providedMonth)
            : $paymentDate->copy()->startOfMonth();

        // Build month_covered label
        if ($monthsCount <= 1) {
            $monthCovered = $startMonth->format('F Y');
        } else {
            $endMonth = $startMonth->copy()->addMonths($monthsCount - 1);
            $monthCovered = $startMonth->format('F Y') . ' - ' . $endMonth->format('F Y');
        }

        // Overdue date = first day of the month after the last covered month
        $overdueDate = $startMonth->copy()->addMonths($monthsCount)->startOfMonth()->toDateString();

        return [
            'months_count' => $monthsCount,
            'month_covered' => $monthCovered,
            'overdue_date' => $overdueDate,
            'remainder' => round($remainder, 2),
            'is_overpayment' => $isOverpayment,
        ];
    }

    /**
     * Preview calculation without saving — used by the API to return
     * overpayment info to the mobile app before recording.
     */
    public function previewCoverage(string $contractId, float $amount, ?string $paymentDate = null, ?string $monthCovered = null): array
    {
        $contract = Contract::findOrFail($contractId);
        $rentAmount = (float) ($contract->rent_amount ?? 0);
        $date = $paymentDate ? Carbon::parse($paymentDate) : now();

        $calc = $this->calculateCoverage($amount, $rentAmount, $date, $monthCovered);

        return array_merge($calc, [
            'rent_amount' => $rentAmount,
            'amount' => $amount,
        ]);
    }

    public function outstandingForContract(string $contractId): float
    {
        $contract = Contract::findOrFail($contractId);
        $paid = Payment::where('contract_id', $contractId)->where('status', 'confirmed')->sum('amount');
        return max(0, (float) $contract->rent_amount - (float) $paid);
    }
}
