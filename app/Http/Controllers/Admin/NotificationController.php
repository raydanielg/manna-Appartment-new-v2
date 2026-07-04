<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use App\Models\DeviceToken;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class NotificationController extends Controller
{
    public function __construct()
    {
        $this->middleware(['auth']);
    }

    public function index(Request $request)
    {
        $notifications = AppNotification::with('user')
            ->where('type', 'broadcast')
            ->latest()
            ->paginate(15);

        return view('admin.notifications.index', compact('notifications'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'body' => 'required|string',
            'role' => 'required|in:all,landlord,tenant,super_admin',
        ]);

        $users = User::query();
        if ($request->role !== 'all') {
            $users->where('role', $request->role);
        }

        $users = $users->get();
        $now = now();
        $inserts = [];
        $notificationIds = [];

        foreach ($users as $user) {
            $inserts[] = [
                'id' => (string) \Illuminate\Support\Str::uuid(),
                'user_id' => $user->id,
                'title' => $request->title,
                'body' => $request->body,
                'type' => 'broadcast',
                'data' => json_encode(['role' => $request->role]),
                'sent_at' => $now,
                'created_at' => $now,
                'updated_at' => $now,
            ];

            if (count($inserts) >= 500) {
                AppNotification::insert($inserts);
                $inserts = [];
            }
        }

        if (count($inserts)) {
            AppNotification::insert($inserts);
        }

        $this->sendPushNotifications($request->title, $request->body, $request->role, $users->pluck('id')->toArray());

        return redirect()->route('admin.notifications.index')
            ->with('success', 'Notification sent to ' . $users->count() . ' user(s).');
    }

    private function sendPushNotifications(string $title, string $body, string $role, array $userIds)
    {
        $serverKey = config('services.fcm.server_key');
        if (empty($serverKey)) {
            return;
        }

        $tokens = DeviceToken::whereIn('user_id', $userIds)
            ->where('platform', 'android')
            ->pluck('token')
            ->unique()
            ->values()
            ->toArray();

        if (empty($tokens)) {
            return;
        }

        $chunks = array_chunk($tokens, 500);
        foreach ($chunks as $chunk) {
            try {
                $response = Http::withHeaders([
                    'Authorization' => 'key=' . $serverKey,
                    'Content-Type' => 'application/json',
                ])->post('https://fcm.googleapis.com/fcm/send', [
                    'registration_ids' => $chunk,
                    'notification' => [
                        'title' => $title,
                        'body' => $body,
                        'sound' => 'default',
                    ],
                    'data' => [
                        'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                        'type' => 'broadcast',
                    ],
                ]);

                Log::info('FCM broadcast response', ['status' => $response->status(), 'body' => $response->body()]);
            } catch (\Exception $e) {
                Log::error('FCM broadcast failed: ' . $e->getMessage());
            }
        }
    }

    public function destroy($id)
    {
        AppNotification::where('id', $id)->delete();
        return redirect()->route('admin.notifications.index')
            ->with('success', 'Notification deleted.');
    }
}
