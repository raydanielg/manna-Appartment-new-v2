<?php

namespace App\Http\Controllers\Api\Landlord;

use App\Http\Controllers\Controller;
use App\Models\Contract;
use App\Models\Tenant;
use App\Models\Unit;
use App\Services\ContractPdfService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class ContractController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $query = Contract::with(['tenant.user', 'unit.property'])->latest();
        return $this->paginated($query->paginate($request->get('per_page', 20)));
    }

    public function store(Request $request)
    {
        $request->validate([
            'tenant_id' => 'required|uuid|exists:tenants,id',
            'unit_id' => 'required|uuid|exists:units,id',
            'duration_type' => 'nullable|in:3_months,6_months,12_months,lifetime,custom',
            'start_date' => 'required|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'rent_amount' => 'required|numeric|min:0',
            'deposit_amount' => 'nullable|numeric|min:0',
            'contract_type' => 'nullable|in:digital,manual',
        ]);

        $tenant = Tenant::findOrFail($request->tenant_id);
        $unit = Unit::findOrFail($request->unit_id);
        $unit->update(['status' => 'occupied']);

        $contract = Contract::create(array_merge(
            $request->only([
                'tenant_id', 'unit_id', 'duration_type', 'start_date', 'end_date', 'rent_amount', 'deposit_amount', 'contract_type',
            ]),
            [
                'duration_type' => $request->duration_type ?? 'custom',
                'status' => 'active',
            ]
        ));

        $tenant->update(['status' => 'active']);

        return $this->success('Contract created.', $contract->load(['tenant.user', 'unit.property']), 201);
    }

    public function show($id)
    {
        $contract = Contract::with(['tenant.user', 'unit.property', 'payments'])->findOrFail($id);
        return $this->success('Contract retrieved.', $contract);
    }

    public function update(Request $request, $id)
    {
        $contract = Contract::findOrFail($id);
        $contract->update($request->only([
            'duration_type', 'start_date', 'end_date', 'rent_amount', 'deposit_amount', 'status',
        ]));
        return $this->success('Contract updated.', $contract);
    }

    public function renew(Request $request, $id)
    {
        $request->validate([
            'end_date' => 'required|date|after:today',
            'duration_type' => 'nullable|in:3_months,6_months,12_months,lifetime,custom',
        ]);

        $contract = Contract::findOrFail($id);
        $contract->update([
            'end_date' => $request->end_date,
            'duration_type' => $request->duration_type ?? $contract->duration_type,
            'status' => 'active',
        ]);

        return $this->success('Contract renewed.', $contract);
    }

    public function terminate($id)
    {
        $contract = Contract::findOrFail($id);
        $contract->update(['status' => 'terminated']);

        if ($contract->unit) {
            $contract->unit->update(['status' => 'vacant']);
        }

        return $this->success('Contract terminated.', $contract);
    }

    public function pdf($id)
    {
        $contract = Contract::with(['tenant.user', 'unit.property'])->findOrFail($id);
        $url = app(ContractPdfService::class)->generate($contract);
        return $this->success('PDF generated.', ['pdf_url' => $url]);
    }

    public function sign(Request $request, $id)
    {
        $request->validate([
            'signature' => 'required|image|mimes:png,jpeg|max:2048',
        ]);

        $contract = Contract::with(['tenant.user', 'unit.property'])->findOrFail($id);
        $file = $request->file('signature');
        $path = $file->store('signatures', 'public');

        $contract->update([
            'signature_path' => $path,
            'signed_at' => now(),
        ]);

        $pdfUrl = app(ContractPdfService::class)->generate($contract);

        return $this->success('Contract signed.', [
            'contract' => $contract,
            'pdf_url' => $pdfUrl,
        ]);
    }

    public function downloadPdf($id)
    {
        $contract = Contract::findOrFail($id);
        if (!$contract->pdf_url || !Storage::disk('public')->exists("contracts/{$contract->id}.pdf")) {
            app(ContractPdfService::class)->generate($contract);
        }
        return response()->download(Storage::disk('public')->path("contracts/{$contract->id}.pdf"), "contract_{$contract->contract_number}.pdf");
    }
}
