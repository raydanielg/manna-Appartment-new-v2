<?php

namespace App\Services;

use App\Models\Payment;
use Illuminate\Support\Facades\Auth;

class PaymentService
{
    public function record(array $data): Payment
    {
        return Payment::create(array_merge($data, [
            'recorded_by' => Auth::id(),
            'status' => 'confirmed',
        ]));
    }

    public function outstandingForContract(string $contractId): float
    {
        $contract = \App\Models\Contract::findOrFail($contractId);
        $paid = Payment::where('contract_id', $contractId)->where('status', 'confirmed')->sum('amount');
        return max(0, $contract->rent_amount - $paid);
    }
}
