@extends('layouts.admin')

@section('title', 'Notifications - Manna Apartment')
@section('page_title', 'Notifications')

@section('content')
<div class="space-y-6">
    @if(session('success'))
    <div class="bg-emerald-50 text-emerald-700 px-4 py-3 rounded-lg text-sm border border-emerald-100">
        {{ session('success') }}
    </div>
    @endif

    <div class="bg-white rounded-xl border overflow-hidden">
        <div class="px-5 py-4 border-b">
            <h3 class="text-sm font-semibold text-gray-900">Send Notification</h3>
        </div>
        <div class="p-5">
            <form action="{{ route('admin.notifications.store') }}" method="POST" class="space-y-4">
                @csrf
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-xs font-medium text-gray-700 mb-1">Target Users</label>
                        <select name="role" class="w-full rounded-lg border-gray-300 text-sm focus:border-emerald-500 focus:ring-emerald-500">
                            <option value="all">All Users</option>
                            <option value="landlord">Landlords Only</option>
                            <option value="tenant">Tenants Only</option>
                            <option value="super_admin">Super Admins Only</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-gray-700 mb-1">Title</label>
                        <input type="text" name="title" required maxlength="255" class="w-full rounded-lg border-gray-300 text-sm focus:border-emerald-500 focus:ring-emerald-500" placeholder="e.g. System Update">
                    </div>
                </div>
                <div>
                    <label class="block text-xs font-medium text-gray-700 mb-1">Message</label>
                    <textarea name="body" required rows="4" class="w-full rounded-lg border-gray-300 text-sm focus:border-emerald-500 focus:ring-emerald-500" placeholder="Write your message..."></textarea>
                </div>
                <div class="flex justify-end">
                    <button type="submit" class="px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-semibold rounded-lg transition-colors">
                        Send to All
                    </button>
                </div>
            </form>
        </div>
    </div>

    <div class="bg-white rounded-xl border overflow-hidden">
        <div class="px-5 py-4 border-b flex items-center justify-between">
            <h3 class="text-sm font-semibold text-gray-900">Recent Broadcasts</h3>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead><tr class="text-left text-xs text-gray-500 bg-gray-50/50">
                    <th class="px-5 py-2.5 font-medium">Sent At</th>
                    <th class="px-5 py-2.5 font-medium">Title</th>
                    <th class="px-5 py-2.5 font-medium">Message</th>
                    <th class="px-5 py-2.5 font-medium">Target</th>
                    <th class="px-5 py-2.5 font-medium text-right">Action</th>
                </tr></thead>
                <tbody>
                    @forelse($notifications as $n)
                    <tr class="border-t border-gray-100 hover:bg-gray-50/50 transition-colors">
                        <td class="px-5 py-2.5 text-xs text-gray-500">{{ $n->sent_at?->format('M d, Y H:i') }}</td>
                        <td class="px-5 py-2.5 text-xs font-medium text-gray-900">{{ $n->title }}</td>
                        <td class="px-5 py-2.5 text-xs text-gray-700 max-w-xs truncate">{{ $n->body }}</td>
                        <td class="px-5 py-2.5 text-xs text-gray-700">{{ ucfirst($n->type) }}</td>
                        <td class="px-5 py-2.5 text-right">
                            <form action="{{ route('admin.notifications.destroy', $n->id) }}" method="POST" onsubmit="return confirm('Delete this notification?');" class="inline">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="text-xs text-red-600 hover:text-red-700 font-medium">Delete</button>
                            </form>
                        </td>
                    </tr>
                    @empty
                    <tr><td colspan="5" class="px-5 py-8 text-center text-gray-400 text-xs">No notifications yet</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="px-5 py-3 border-t text-xs">
            {{ $notifications->links() }}
        </div>
    </div>
</div>
@endsection
