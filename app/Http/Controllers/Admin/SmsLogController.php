<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\SmsLog;
use Illuminate\Http\Request;

class SmsLogController extends Controller
{
    public function __construct()
    {
        $this->middleware(['auth']);
    }

    public function index(Request $request)
    {
        $logs = SmsLog::with('organization')
            ->when($request->search, function ($query, $search) {
                $query->where('recipient_phone', 'like', "%{$search}%")
                    ->orWhere('message', 'like', "%{$search}%");
            })
            ->when($request->status, function ($query, $status) {
                $query->where('status', $status);
            })
            ->latest()
            ->paginate(20);

        $stats = [
            'total' => SmsLog::count(),
            'sent' => SmsLog::where('status', 'sent')->count(),
            'queued' => SmsLog::where('status', 'queued')->count(),
            'failed' => SmsLog::where('status', 'failed')->count(),
        ];

        return view('admin.sms_logs.index', compact('logs', 'stats'));
    }
}
