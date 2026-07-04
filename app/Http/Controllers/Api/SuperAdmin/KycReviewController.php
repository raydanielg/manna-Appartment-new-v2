<?php

namespace App\Http\Controllers\Api\SuperAdmin;

use App\Http\Controllers\Controller;
use App\Models\KycDocument;
use App\Models\Organization;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class KycReviewController extends Controller
{
    use ApiResponse;

    public function pending(Request $request)
    {
        $query = KycDocument::with('organization')->where('status', 'pending')->latest();
        return $this->paginated($query->paginate($request->get('per_page', 20)));
    }

    public function review(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:approved,rejected',
            'review_notes' => 'nullable|string',
        ]);

        $kyc = KycDocument::findOrFail($id);
        $kyc->update([
            'status' => $request->status,
            'review_notes' => $request->review_notes,
            'reviewed_by' => Auth::id(),
            'reviewed_at' => now(),
        ]);

        $organization = Organization::find($kyc->organization_id);
        if ($organization) {
            $organization->update(['kyc_status' => $request->status]);
        }

        return $this->success('KYC review updated.', $kyc);
    }
}
