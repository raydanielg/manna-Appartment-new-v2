<?php

namespace App\Http\Controllers\Api\Landlord;

use App\Http\Controllers\Controller;
use App\Models\MaintenanceRequest;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class MaintenanceRequestController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $requests = MaintenanceRequest::with(['tenant.user', 'unit'])->latest()->paginate($request->get('per_page', 20));
        return $this->paginated($requests);
    }

    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:open,in_progress,resolved,cancelled',
            'landlord_notes' => 'nullable|string',
        ]);

        $maintenance = MaintenanceRequest::findOrFail($id);
        $maintenance->update([
            'status' => $request->status,
            'landlord_notes' => $request->landlord_notes,
            'resolved_at' => $request->status === 'resolved' ? now() : $maintenance->resolved_at,
        ]);

        return $this->success('Maintenance request updated.', $maintenance);
    }
}
