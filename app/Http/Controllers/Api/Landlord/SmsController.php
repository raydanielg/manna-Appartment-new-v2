<?php

namespace App\Http\Controllers\Api\Landlord;

use App\Http\Controllers\Controller;
use App\Models\SmsLog;
use App\Models\Tenant;
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
            'status' => 'queued',
        ]);

        // TODO: dispatch SendSmsJob
        $organization->decrement('sms_balance');
        $sms->update(['status' => 'sent', 'sent_at' => now()]);

        return $this->success('SMS queued successfully.', $sms, 201);
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
