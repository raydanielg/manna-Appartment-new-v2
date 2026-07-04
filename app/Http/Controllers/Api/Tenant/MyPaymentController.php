<?php

namespace App\Http\Controllers\Api\Tenant;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class MyPaymentController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $user = Auth::user();
        $tenant = $user->tenant;

        if (!$tenant) {
            return $this->error('Tenant record not found.', null, 404);
        }

        $payments = Payment::where('tenant_id', $tenant->id)->latest()->paginate($request->get('per_page', 20));
        return $this->paginated($payments);
    }
}
