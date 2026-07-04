<?php

namespace App\Http\Controllers\Api\Landlord;

use App\Http\Controllers\Controller;
use App\Models\Contract;
use App\Models\Payment;
use App\Models\Tenant;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PaymentController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $query = Payment::with(['tenant.user', 'contract'])->latest();
        return $this->paginated($query->paginate($request->get('per_page', 20)));
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
            'notes' => 'nullable|string',
        ]);

        $payment = Payment::create(array_merge(
            $request->only([
                'contract_id', 'tenant_id', 'amount', 'method', 'reference_number', 'payment_date', 'month_covered', 'notes',
            ]),
            ['recorded_by' => Auth::id(), 'status' => 'confirmed']
        ));

        return $this->success('Payment recorded.', $payment->load(['tenant.user', 'contract']), 201);
    }

    public function tenantPayments(Request $request, $tenantId)
    {
        Tenant::findOrFail($tenantId);
        $payments = Payment::where('tenant_id', $tenantId)->latest()->paginate($request->get('per_page', 20));
        return $this->paginated($payments);
    }
}
