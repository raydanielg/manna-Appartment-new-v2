<?php

namespace App\Http\Controllers\Api\Staff;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Services\PaymentService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class StaffPaymentController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $payments = Payment::with(['tenant.user', 'contract'])->latest()->paginate($request->get('per_page', 20));
        return $this->paginated($payments);
    }

    public function store(Request $request)
    {
        $request->validate([
            'contract_id' => 'required|uuid|exists:contracts,id',
            'tenant_id' => 'required|uuid|exists:tenants,id',
            'amount' => 'required|numeric|min:0',
            'method' => 'required|string|max:255',
            'reference_number' => 'nullable|string|max:255',
            'payment_date' => 'required|date',
            'month_covered' => 'required|string|max:255',
        ]);

        $service = app(PaymentService::class);
        $payment = $service->record($request->only([
            'contract_id', 'tenant_id', 'amount', 'method',
            'reference_number', 'payment_date', 'month_covered',
        ]));

        $calc = $service->calculateCoverage(
            (float) $payment->amount,
            (float) $payment->contract->rent_amount,
            \Carbon\Carbon::parse($payment->payment_date),
            $payment->month_covered,
        );

        return $this->success('Payment recorded.', [
            'payment' => $payment->load(['tenant.user', 'contract']),
            'overpayment' => $calc,
        ], 201);
    }
}
