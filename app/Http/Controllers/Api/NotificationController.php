<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use App\Models\DeviceToken;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $notifications = AppNotification::where('user_id', Auth::id())
            ->latest()
            ->paginate($request->input('per_page', 20));

        return $this->success('Notifications retrieved.', $notifications);
    }

    public function unreadCount()
    {
        $count = AppNotification::where('user_id', Auth::id())
            ->whereNull('read_at')
            ->count();

        return $this->success('Unread count.', ['count' => $count]);
    }

    public function markAsRead($id)
    {
        $notification = AppNotification::where('user_id', Auth::id())->findOrFail($id);
        $notification->update(['read_at' => now()]);

        return $this->success('Notification marked as read.', $notification);
    }

    public function markAllAsRead()
    {
        AppNotification::where('user_id', Auth::id())
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return $this->success('All notifications marked as read.');
    }

    public function registerToken(Request $request)
    {
        $request->validate([
            'token' => 'required|string',
            'platform' => 'nullable|string|in:android,ios',
            'device_name' => 'nullable|string',
        ]);

        $token = DeviceToken::updateOrCreate(
            ['token' => $request->token],
            [
                'user_id' => Auth::id(),
                'platform' => $request->platform ?? 'android',
                'device_name' => $request->device_name,
                'last_used_at' => now(),
            ]
        );

        return $this->success('Device token registered.', $token);
    }
}
