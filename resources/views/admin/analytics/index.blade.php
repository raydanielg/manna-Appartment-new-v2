@extends('layouts.admin')

@section('title', 'Analytics - Manna Apartment')
@section('page_title', 'Analytics')

@section('content')
<div class="grid grid-cols-2 lg:grid-cols-4 gap-3 mb-6">
    @foreach([
        ['label'=>'Organizations','value'=>$stats['organizations'],'icon'=>'M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5'],
        ['label'=>'Properties','value'=>$stats['properties'],'icon'=>'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6'],
        ['label'=>'Tenants','value'=>$stats['tenants'],'icon'=>'M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z'],
        ['label'=>'SMS Sent','value'=>$stats['smsSent'],'icon'=>'M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z']
    ] as $card)
    <div class="bg-white rounded-xl border p-4 hover:shadow-lg transition-shadow">
        <div class="flex items-start justify-between mb-2">
            <span class="text-[10px] font-medium text-gray-500">{{ $card['label'] }}</span>
            <svg class="w-4 h-4 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="{{ $card['icon'] }}"/></svg>
        </div>
        <p class="text-xl font-bold tracking-tight text-gray-900">{{ number_format($card['value']) }}</p>
    </div>
    @endforeach
</div>

<div class="bg-white rounded-xl border p-5">
    <h3 class="text-sm font-semibold text-gray-900 mb-4">Platform Summary</h3>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
        <div class="flex justify-between py-2 border-b border-gray-100">
            <span class="text-gray-500">Total Payments Revenue</span>
            <span class="font-semibold text-gray-900">TZS {{ number_format($stats['payments']) }}</span>
        </div>
        <div class="flex justify-between py-2 border-b border-gray-100">
            <span class="text-gray-500">Total Units</span>
            <span class="font-semibold text-gray-900">{{ number_format($stats['units']) }}</span>
        </div>
        <div class="flex justify-between py-2 border-b border-gray-100">
            <span class="text-gray-500">Total Contracts</span>
            <span class="font-semibold text-gray-900">{{ number_format($stats['contracts']) }}</span>
        </div>
        <div class="flex justify-between py-2 border-b border-gray-100">
            <span class="text-gray-500">SMS Sent</span>
            <span class="font-semibold text-gray-900">{{ number_format($stats['smsSent']) }}</span>
        </div>
    </div>
</div>
@endsection
