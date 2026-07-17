<?php

namespace App\Http\Controllers\Api\Landlord;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\Tenant;
use App\Services\PaymentService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $query = Payment::with(['tenant.user', 'contract'])->latest();
        return $this->paginated($query->paginate($request->get('per_page', 20)));
    }

    public function previewOverpayment(Request $request)
    {
        $request->validate([
            'contract_id' => 'required|uuid|exists:contracts,id',
            'amount' => 'required|numeric|min:0',
            'payment_date' => 'nullable|date',
            'month_covered' => 'nullable|string|max:255',
        ]);

        $service = app(PaymentService::class);
        $calc = $service->previewCoverage(
            $request->contract_id,
            (float) $request->amount,
            $request->payment_date,
            $request->month_covered,
        );

        return $this->success('Overpayment preview.', $calc);
    }

    public function store(Request $request)
    {
        $request->validate([
            'contract_id' => 'required|uuid|exists:contracts,id',
            'tenant_id' => 'required|uuid|exists:tenants,id',
            'payment_type' => 'required|in:rent,water,electricity,other',
            'amount' => 'required|numeric|min:0',
            'method' => 'required|string|max:255',
            'reference_number' => 'nullable|string|max:255',
            'payment_date' => 'nullable|date',
            'month_covered' => 'nullable|string|max:255',
            'notes' => 'nullable|string',
        ]);

        $service = app(PaymentService::class);
        $payment = $service->record($request->only([
            'contract_id', 'tenant_id', 'payment_type', 'amount', 'method',
            'reference_number', 'payment_date', 'month_covered', 'notes',
        ]));

        $calc = $service->calculateCoverage(
            (float) $payment->amount,
            (float) $payment->contract->rent_amount,
            \Carbon\Carbon::parse($payment->payment_date),
            $payment->month_covered,
        );

        return $this->success('Payment recorded.', [
            'payment' => $payment->load(['tenant.user', 'contract.unit']),
            'overpayment' => $calc,
        ], 201);
    }

    public function show($id)
    {
        $payment = Payment::with(['tenant.user', 'contract.unit'])->findOrFail($id);
        return $this->success('Payment retrieved.', $payment);
    }

    public function update(Request $request, $id)
    {
        $payment = Payment::findOrFail($id);
        $request->validate([
            'payment_type' => 'nullable|in:rent,water,electricity,other',
            'amount' => 'nullable|numeric|min:0',
            'method' => 'nullable|string|max:255',
            'reference_number' => 'nullable|string|max:255',
            'payment_date' => 'nullable|date',
            'month_covered' => 'nullable|string|max:255',
            'notes' => 'nullable|string',
        ]);

        $payment->update($request->only([
            'payment_type', 'amount', 'method', 'reference_number', 'payment_date', 'month_covered', 'notes',
        ]));

        return $this->success('Payment updated.', $payment->load(['tenant.user', 'contract.unit']));
    }

    public function destroy($id)
    {
        $payment = Payment::findOrFail($id);
        $payment->delete();
        return $this->success('Payment deleted.');
    }

    public function tenantPayments(Request $request, $tenantId)
    {
        Tenant::findOrFail($tenantId);
        $payments = Payment::where('tenant_id', $tenantId)->latest()->paginate($request->get('per_page', 20));
        return $this->paginated($payments);
    }
}
