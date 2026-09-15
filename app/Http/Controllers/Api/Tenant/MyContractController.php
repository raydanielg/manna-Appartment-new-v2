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

        if ($contract->signed_at) {
            return $this->error('This contract has already been signed.', null, 409);
        }

        $file = $request->file('signature');
        $path = $file->store('signatures', 'public');

        $contract->update([
            'signature_path' => $path,
            'signed_at' => now(),
        ]);

        $pdfUrl = app(ContractPdfService::class)->generate($contract);

        return $this->success('Contract signed.', [
            'contract' => $contract->load('unit.property'),
            'pdf_url' => $pdfUrl,
        ]);
    }
}
