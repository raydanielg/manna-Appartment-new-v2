<?php

namespace App\Http\Controllers\Api\Landlord;

use App\Http\Controllers\Controller;
use App\Models\SmsLog;
use App\Models\Tenant;
use App\Services\SmsService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class SmsController extends Controller
{
    use ApiResponse;

    public function send(Request $request)
    {
        $request->validate([
            'recipient_phone' => 'required|string',
            'message' => 'required|string',
            'type' => 'required|string|max:255',
        ]);

        $organization = Auth::user()->organization;

        if ($organization->sms_balance <= 0) {
            return $this->error('Insufficient SMS balance. Please top up.', null, 403);
        }

        $sms = SmsLog::create([
            'recipient_phone' => $request->recipient_phone,
            'message' => $request->message,
            'type' => $request->type,
            'organization_id' => $organization->id,
            'status' => 'queued',
        ]);

        app(SmsService::class)->send($request->recipient_phone, $request->message, $request->type, $organization->id);

        return $this->success('SMS queued successfully.', $sms, 201);
    }

    public function broadcast(Request $request)
    {
        $request->validate([
            'recipient_type' => 'required|in:all_tenants,active_tenants,overdue_tenants,custom_numbers',
            'message' => 'required|string',
            'custom_numbers' => 'nullable|array',
            'custom_numbers.*' => 'string',
        ]);

        $organization = Auth::user()->organization;
        $user = Auth::user();

        if ($organization->sms_balance <= 0) {
            return $this->error('Insufficient SMS balance. Please top up.', null, 403);
        }

        $recipientType = $request->recipient_type;
        $message = $request->message;
        $phones = [];

        if ($recipientType === 'custom_numbers') {
            $phones = $request->input('custom_numbers', []);
        } else {
            $query = Tenant::with(['user', 'payments'])->where('organization_id', $organization->id);
            if ($recipientType === 'active_tenants') {
                $query->where('status', 'active');
            } elseif ($recipientType === 'overdue_tenants') {
                $query->where('status', 'active');
            }
            $tenants = $query->get();
            if ($recipientType === 'overdue_tenants') {
                $tenants = $tenants->filter(function ($tenant) {
                    $rent = $tenant->unit?->rent_amount ?? 0;
                    $paid = $tenant->payments->sum('amount');
                    return $rent > 0 && $paid < $rent;
                });
            }
            $phones = $tenants->map(fn ($t) => $t->user?->phone)->filter()->unique()->values()->toArray();
        }

        if (empty($phones)) {
            return $this->error('No recipients found for this group.', null, 422);
        }

        $messageLen = strlen($message);
        $smsPerMessage = $this->calcSmsCount($messageLen);
        $totalSmsNeeded = $smsPerMessage * count($phones);

        if ($organization->sms_balance < $totalSmsNeeded) {
            return $this->error("Insufficient SMS balance. Need {$totalSmsNeeded} SMS ({$smsPerMessage} x {$totalSmsNeeded} recipients), have {$organization->sms_balance}.", null, 403);
        }

        $smsService = app(SmsService::class);
        $sentCount = 0;
        foreach ($phones as $phone) {
            $smsService->send($phone, $message, 'broadcast', $organization->id);
            $sentCount++;
        }

        $organization->decrement('sms_balance', $totalSmsNeeded);

        return $this->success("Broadcast sent to {$sentCount} recipients.", [
            'sent_count' => $sentCount,
            'sms_used' => $totalSmsNeeded,
            'sms_remaining' => $organization->fresh()->sms_balance,
        ]);
    }

    private function calcSmsCount(int $len): int
    {
        if ($len <= 160) return 1;
        if ($len <= 306) return 2;
        if ($len <= 459) return 3;
        if ($len <= 612) return 4;
        if ($len <= 765) return 5;
        return (intdiv($len - 765, 153)) + 6;
    }

    public function logs(Request $request)
    {
        $logs = SmsLog::latest()->paginate($request->get('per_page', 20));
        return $this->paginated($logs);
    }

    public function balance()
    {
        $organization = Auth::user()->organization;
        return $this->success('SMS balance retrieved.', ['sms_balance' => $organization->sms_balance]);
    }
}
