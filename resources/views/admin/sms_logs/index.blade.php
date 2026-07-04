@extends('layouts.admin')

@section('title', 'SMS Logs - Manna Apartment')
@section('page_title', 'SMS Logs')

@section('content')
<div class="grid grid-cols-2 lg:grid-cols-4 gap-3 mb-6">
    @foreach([
        ['label'=>'Total SMS','value'=>$stats['total'],'color'=>'emerald'],
        ['label'=>'Sent','value'=>$stats['sent'],'color'=>'sky'],
        ['label'=>'Queued','value'=>$stats['queued'],'color'=>'amber'],
        ['label'=>'Failed','value'=>$stats['failed'],'color'=>'red'],
    ] as $card)
    <div class="bg-white rounded-xl border p-4">
        <p class="text-xs text-gray-500 mb-1">{{ $card['label'] }}</p>
        <p class="text-2xl font-bold text-{{ $card['color'] }}-600">{{ number_format($card['value']) }}</p>
    </div>
    @endforeach
</div>

<div class="bg-white rounded-xl border overflow-hidden">
    <div class="px-5 py-4 border-b flex flex-col md:flex-row md:items-center justify-between gap-3">
        <h3 class="text-sm font-semibold text-gray-900">All SMS Logs</h3>
        <form method="GET" action="{{ route('admin.sms_logs') }}" class="flex items-center gap-2">
            <input type="text" name="search" value="{{ request('search') }}" placeholder="Search phone or message..." class="px-3 py-1.5 rounded-lg border border-gray-200 text-sm outline-none focus:border-emerald-500">
            <select name="status" class="px-3 py-1.5 rounded-lg border border-gray-200 text-sm bg-white outline-none focus:border-emerald-500">
                <option value="">All Status</option>
                <option value="sent" {{ request('status') === 'sent' ? 'selected' : '' }}>Sent</option>
                <option value="queued" {{ request('status') === 'queued' ? 'selected' : '' }}>Queued</option>
                <option value="failed" {{ request('status') === 'failed' ? 'selected' : '' }}>Failed</option>
            </select>
            <button type="submit" class="px-4 py-1.5 text-sm font-semibold text-white bg-emerald-600 hover:bg-emerald-700 rounded-lg transition-all">Filter</button>
        </form>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead><tr class="text-left text-xs text-gray-500 bg-gray-50/50">
                <th class="px-5 py-2.5 font-medium">Phone</th>
                <th class="px-5 py-2.5 font-medium">Organization</th>
                <th class="px-5 py-2.5 font-medium">Type</th>
                <th class="px-5 py-2.5 font-medium">Message</th>
                <th class="px-5 py-2.5 font-medium">Status</th>
                <th class="px-5 py-2.5 font-medium">Date</th>
            </tr></thead>
            <tbody>
                @forelse($logs as $log)
                <tr class="border-t border-gray-100 hover:bg-gray-50/50 transition-colors">
                    <td class="px-5 py-2.5 text-xs font-medium text-gray-900">+{{ $log->recipient_phone }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-500">{{ $log->organization->name ?? '-' }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-700">{{ $log->type }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-600 max-w-xs truncate">{{ $log->message }}</td>
                    <td class="px-5 py-2.5">
                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium
                            {{ $log->status === 'sent' ? 'bg-emerald-50 text-emerald-700 border border-emerald-100' : ($log->status === 'queued' ? 'bg-amber-50 text-amber-700 border border-amber-100' : 'bg-red-50 text-red-700 border border-red-100') }}">{{ ucfirst($log->status) }}</span>
                    </td>
                    <td class="px-5 py-2.5 text-xs text-gray-500">{{ $log->created_at->format('Y-m-d H:i') }}</td>
                </tr>
                @empty
                <tr><td colspan="6" class="px-5 py-8 text-center text-gray-400 text-xs">No SMS logs found</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
    <div class="px-5 py-3 border-t text-xs">
        {{ $logs->links() }}
    </div>
</div>
@endsection
