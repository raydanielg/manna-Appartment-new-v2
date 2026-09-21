<?php

namespace App\Http\Controllers\Api\Tenant;

use App\Http\Controllers\Controller;
use App\Services\ContractPdfService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
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

    public function sign(Request $request)
    {
        $request->validate([
            'signature' => 'required|image|mimes:png,jpeg|max:2048',
        ]);

        $user = Auth::user();
        $tenant = $user->tenant;

        if (!$tenant) {
            return $this->error('Tenant record not found.', null, 404);
        }

        $contract = $tenant->contracts()->latest()->first();

        if (!$contract) {
            return $this->error('No contract found.', null, 404);
        }

        if ($contract->status !== 'active') {
            return $this->error('This contract is not active and cannot be signed.', null, 409);
        }

        if ($contract->tenant_signed_at) {
            return $this->error('You have already signed this contract.', null, 409);
        }

        $file = $request->file('signature');
        $path = $file->store('signatures', 'public');

        $contract->update([
            'tenant_signature_path' => $path,
            'tenant_signed_at' => now(),
        ]);

        return $this->success('Contract signed. Waiting for landlord countersignature.', [
            'contract' => $contract->load('unit.property'),
            'awaiting_landlord' => true,
        ]);
    }
}
