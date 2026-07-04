<?php

namespace App\Http\Controllers\Api\Landlord;

use App\Http\Controllers\Controller;
use App\Models\Contract;
use App\Models\Tenant;
use App\Models\Unit;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

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
            'duration_type' => 'required|in:3_months,6_months,12_months,lifetime,custom',
            'start_date' => 'required|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'rent_amount' => 'required|numeric|min:0',
            'deposit_amount' => 'nullable|numeric|min:0',
        ]);

        $tenant = Tenant::findOrFail($request->tenant_id);
        $unit = Unit::findOrFail($request->unit_id);
        $unit->update(['status' => 'occupied']);

        $contract = Contract::create(array_merge(
            $request->only([
                'tenant_id', 'unit_id', 'duration_type', 'start_date', 'end_date', 'rent_amount', 'deposit_amount',
            ]),
            ['status' => 'active']
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
        // TODO: generate PDF using ContractPdfService
        return $this->success('PDF generated.', ['pdf_url' => $contract->pdf_url]);
    }
}
