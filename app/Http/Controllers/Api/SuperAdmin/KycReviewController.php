<?php

namespace App\Http\Controllers\Api\SuperAdmin;

use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use App\Models\DeviceToken;
use App\Models\KycDocument;
use App\Models\Organization;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

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

        if ($organization && $organization->owner_user_id) {
            $this->notifyKycDecision($organization->owner_user_id, $request->status);
        }

        return $this->success('KYC review updated.', $kyc);
    }

    private function notifyKycDecision($userId, $status)
    {
        $title = 'KYC ' . ucfirst($status);
        $body = $status === 'approved'
            ? 'Congratulations! Your KYC has been approved. You can now access your dashboard.'
            : 'Your KYC was rejected. Please check your documents and resubmit.';

        AppNotification::create([
            'user_id' => $userId,
            'title' => $title,
            'body' => $body,
            'type' => 'kyc_' . $status,
            'data' => ['type' => 'kyc', 'status' => $status],
            'sent_at' => now(),
        ]);

        $serverKey = config('services.fcm.server_key');
        if (empty($serverKey)) {
            return;
        }

        $tokens = DeviceToken::where('user_id', $userId)
            ->where('platform', 'android')
            ->pluck('token')
            ->unique()
            ->values()
            ->toArray();

        if (empty($tokens)) {
            return;
        }

        try {
            Http::withHeaders([
                'Authorization' => 'key=' . $serverKey,
                'Content-Type' => 'application/json',
            ])->post('https://fcm.googleapis.com/fcm/send', [
                'registration_ids' => $tokens,
                'notification' => [
                    'title' => $title,
                    'body' => $body,
                    'sound' => 'default',
                ],
                'data' => [
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                    'type' => 'kyc',
                    'status' => $status,
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('FCM KYC notification failed: ' . $e->getMessage());
        }
    }
}
