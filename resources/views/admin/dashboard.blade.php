@extends('layouts.admin')

@section('title', 'Super Admin Dashboard - Manna Apartment')
@section('page_title', 'Dashboard Overview')

@section('content')
@php
$fmt = fn($n) => $n >= 1000000000 ? number_format($n/1000000000,2).'B' : ($n >= 1000000 ? number_format($n/1000000,2).'M' : ($n >= 1000 ? number_format($n/1000,1).'K' : number_format($n)));
@endphp

<div class="grid grid-cols-2 lg:grid-cols-4 gap-3 mb-6">
    @foreach([
        ['label'=>'Total Organizations','value'=>number_format($stats['totalOrganizations']),'change'=>'+'.$stats['pendingKyc'].' pending KYC','icon'=>'M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5','from'=>'emerald-600','to'=>'emerald-700','border'=>'emerald-500','text'=>'emerald-100','sub'=>'emerald-200'],
        ['label'=>'Total Revenue','value'=>'TZS '.$fmt($stats['totalRevenue']),'change'=>'Active orgs: '.$stats['activeOrganizations'],'icon'=>'M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z','from'=>'amber-400','to'=>'amber-500','border'=>'amber-300','text'=>'amber-50','sub'=>'amber-100'],
        ['label'=>'Properties','value'=>number_format($stats['totalProperties']),'change'=>'Units: '.$stats['totalUnits'],'icon'=>'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6','from'=>'sky-500','to'=>'sky-600','border'=>'sky-400','text'=>'sky-100','sub'=>'sky-200'],
        ['label'=>'Active Contracts','value'=>number_format($stats['activeContracts']),'change'=>'Tenants: '.$stats['totalTenants'],'icon'=>'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2','from'=>'violet-500','to'=>'violet-600','border'=>'violet-400','text'=>'violet-100','sub'=>'violet-200']
    ] as $card)
    <div class="bg-gradient-to-br from-{{ $card['from'] }} to-{{ $card['to'] }} rounded-xl border border-{{ $card['border'] }} p-4 text-white relative overflow-hidden hover:shadow-lg transition-shadow">
        <div class="absolute top-0 right-0 w-16 h-16 bg-white/10 rounded-full -mr-8 -mt-8"></div>
        <div class="relative z-10">
            <div class="flex items-start justify-between mb-2">
                <span class="text-[10px] font-medium {{ $card['text'] }}">{{ $card['label'] }}</span>
                <svg class="w-4 h-4 {{ $card['sub'] }}" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="{{ $card['icon'] }}"/></svg>
            </div>
            <p class="text-xl font-bold tracking-tight text-white">{{ $card['value'] }}</p>
            <p class="text-[10px] {{ $card['sub'] }} font-medium mt-1">{{ $card['change'] }}</p>
        </div>
    </div>
    @endforeach
</div>

<div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
    <div class="lg:col-span-2 bg-white rounded-xl border p-5">
        <div class="flex items-center justify-between mb-4">
            <div>
                <h3 class="text-sm font-semibold text-gray-900">Revenue Overview</h3>
                <p class="text-xs text-gray-400">Last 14 days</p>
            </div>
        </div>
        @php $revMax = max($dailyRevenue) ?: 1; @endphp
        <div class="flex items-end gap-[4px] h-44">
            @foreach($dailyRevenue as $i => $rev)
            @php $pct = min(100, ($rev / $revMax) * 100); $isToday = $i === count($dailyRevenue)-1; @endphp
            <div class="flex-1 flex flex-col items-center gap-1 group cursor-pointer" title="{{ $dailyLabels[$i] }}: TZS {{ number_format($rev) }}">
                <div class="w-full bg-gray-50 rounded-t-md relative h-36 overflow-hidden">
                    <div class="absolute bottom-0 left-0 right-0 rounded-t-md transition-all duration-300 {{ $isToday ? 'bg-emerald-500' : 'bg-emerald-300 hover:bg-emerald-400' }}" style="height: {{ max($pct, 3) }}%"></div>
                </div>
                <span class="text-[9px] text-gray-400 font-medium">{{ \Carbon\Carbon::parse($dailyLabels[$i])->format('d') }}</span>
            </div>
            @endforeach
        </div>
    </div>

    <div class="bg-white rounded-xl border p-5">
        <h3 class="text-sm font-semibold text-gray-900 mb-4">Occupancy Overview</h3>
        <div class="space-y-3">
            <div class="flex items-center gap-3">
                <div class="w-8 h-8 rounded-lg bg-emerald-100 flex items-center justify-center shrink-0">
                    <svg class="w-4 h-4 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/></svg>
                </div>
                <div class="flex-1 min-w-0">
                    <div class="flex items-center justify-between mb-0.5">
                        <p class="text-xs font-medium text-gray-900">Occupied Units</p>
                        <p class="text-xs font-semibold text-gray-900">{{ number_format($stats['occupiedUnits']) }}</p>
                    </div>
                    <div class="w-full bg-gray-100 rounded-full h-1.5">
                        @php $total = $stats['totalUnits'] ?: 1; @endphp
                        <div class="bg-emerald-500 h-1.5 rounded-full" style="width: {{ ($stats['occupiedUnits'] / $total) * 100 }}%"></div>
                    </div>
                </div>
            </div>
            <div class="flex items-center gap-3">
                <div class="w-8 h-8 rounded-lg bg-gray-100 flex items-center justify-center shrink-0">
                    <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"/></svg>
                </div>
                <div class="flex-1 min-w-0">
                    <div class="flex items-center justify-between mb-0.5">
                        <p class="text-xs font-medium text-gray-900">Vacant Units</p>
                        <p class="text-xs font-semibold text-gray-900">{{ number_format($stats['vacantUnits']) }}</p>
                    </div>
                    <div class="w-full bg-gray-100 rounded-full h-1.5">
                        <div class="bg-gray-400 h-1.5 rounded-full" style="width: {{ ($stats['vacantUnits'] / $total) * 100 }}%"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
    <div class="bg-white rounded-xl border overflow-hidden">
        <div class="px-5 py-4 border-b flex items-center justify-between">
            <h3 class="text-sm font-semibold text-gray-900">Recent Payments</h3>
            <a href="{{ route('admin.revenue') }}" class="text-xs font-medium text-emerald-600 hover:text-emerald-700">View All</a>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead><tr class="text-left text-xs text-gray-500 bg-gray-50/50">
                    <th class="px-5 py-2.5 font-medium">Tenant</th>
                    <th class="px-5 py-2.5 font-medium">Amount</th>
                    <th class="px-5 py-2.5 font-medium">Date</th>
                </tr></thead>
                <tbody>
                    @forelse($recentPayments as $payment)
                    <tr class="border-t border-gray-100 hover:bg-gray-50/50 transition-colors">
                        <td class="px-5 py-2.5 text-xs text-gray-700">{{ $payment->tenant->user->full_name ?? 'Unknown' }}</td>
                        <td class="px-5 py-2.5 text-xs font-semibold text-gray-900">TZS {{ number_format($payment->amount) }}</td>
                        <td class="px-5 py-2.5 text-xs text-gray-500">{{ $payment->payment_date }}</td>
                    </tr>
                    @empty
                    <tr><td colspan="3" class="px-5 py-8 text-center text-gray-400 text-xs">No payments yet</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <div class="bg-white rounded-xl border overflow-hidden">
        <div class="px-5 py-4 border-b flex items-center justify-between">
            <h3 class="text-sm font-semibold text-gray-900">Top Organizations</h3>
            <a href="{{ route('admin.organizations') }}" class="text-xs font-medium text-emerald-600 hover:text-emerald-700">View All</a>
        </div>
        <div class="p-5 space-y-3">
            @forelse($topOrganizations as $org)
            <div class="flex items-center gap-3">
                <div class="w-8 h-8 rounded-full bg-emerald-100 flex items-center justify-center text-emerald-700 font-bold text-xs">
                    {{ strtoupper(substr($org->name ?? 'U', 0, 1)) }}
                </div>
                <div class="flex-1 min-w-0">
                    <p class="text-sm font-medium text-gray-900 truncate">{{ $org->name }}</p>
                    <p class="text-xs text-gray-400">{{ $org->phone ?? '' }}</p>
                </div>
                <div class="text-right">
                    <p class="text-sm font-bold text-gray-900">TZS {{ number_format($org->payments_sum_amount ?? 0) }}</p>
                </div>
            </div>
            @empty
            <p class="text-sm text-gray-400 text-center py-4">No organizations yet</p>
            @endforelse
        </div>
    </div>
</div>
@endsection
