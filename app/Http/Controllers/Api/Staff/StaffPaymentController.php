<?php

namespace App\Http\Controllers\Api\Staff;

use App\Http\Controllers\Controller;
use App\Models\Contract;
use App\Models\Payment;
use App\Models\Tenant;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

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

        $payment = Payment::create(array_merge(
            $request->only([
                'contract_id', 'tenant_id', 'amount', 'method', 'reference_number', 'payment_date', 'month_covered',
            ]),
            ['recorded_by' => Auth::id(), 'status' => 'confirmed']
        ));

        return $this->success('Payment recorded.', $payment->load(['tenant.user', 'contract']), 201);
    }
}
