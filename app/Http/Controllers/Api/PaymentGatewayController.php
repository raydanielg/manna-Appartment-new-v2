<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\Subscription;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class PaymentGatewayController extends Controller
{
    use ApiResponse;

    public function initiate(Request $request)
    {
        $request->validate([
            'type' => 'required|in:subscription,payment',
            'id' => 'required|uuid',
            'phone' => 'required|string',
        ]);

        $reference = Str::uuid();

        // TODO: integrate with actual payment provider (AzamPay, etc.)
        return $this->success('Payment initiated.', [
            'reference' => $reference,
            'amount' => 0,
            'status' => 'pending',
        ]);
    }

    public function callback(Request $request)
    {
        // TODO: verify provider signature and update records
        return $this->success('Callback received.', $request->all());
    }

    public function verify($ref)
    {
        // TODO: verify with provider
        return $this->success('Payment verified.', ['reference' => $ref, 'status' => 'success']);
    }
}
