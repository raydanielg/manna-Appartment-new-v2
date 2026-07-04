<?php

namespace App\Http\Controllers\Api\Tenant;

use App\Http\Controllers\Controller;
use App\Traits\ApiResponse;
use Illuminate\Support\Facades\Auth;

class MyContractController extends Controller
{
    use ApiResponse;

    public function show()
    {
        $user = Auth::user();
        $tenant = $user->tenant;

        if (!$tenant) {
            return $this->error('Tenant record not found.', null, 404);
        }

        $contract = $tenant->contracts()->with('unit.property')->latest()->first();
        return $this->success('Contract retrieved.', $contract);
    }

    public function pdf()
    {
        $user = Auth::user();
        $contract = $user->tenant->contracts()->latest()->first();

        if (!$contract) {
            return $this->error('No contract found.', null, 404);
        }

        return $this->success('PDF retrieved.', ['pdf_url' => $contract->pdf_url]);
    }
}
