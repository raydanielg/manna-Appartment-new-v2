@extends('layouts.admin')

@section('title', 'Revenue - Manna Apartment')
@section('page_title', 'Revenue')

@section('content')
{{-- KPI Cards --}}
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
    {{-- Total Revenue --}}
    <div class="bg-white rounded-xl border p-5">
        <div class="flex items-center justify-between mb-2">
            <div class="w-10 h-10 rounded-xl bg-emerald-100 flex items-center justify-center">
                <svg class="w-5 h-5 text-emerald-600" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </div>
            <span class="text-[10px] font-semibold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-full">REVENUE</span>
        </div>
        <p class="text-2xl font-bold text-gray-900">TZS {{ number_format($totalRevenue) }}</p>
        <p class="text-[11px] text-gray-400 mt-1">From {{ $totalPayments }} payments</p>
    </div>

    {{-- Subscription Revenue --}}
    <div class="bg-white rounded-xl border p-5">
        <div class="flex items-center justify-between mb-2">
            <div class="w-10 h-10 rounded-xl bg-blue-100 flex items-center justify-center">
                <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
            </div>
            <span class="text-[10px] font-semibold text-blue-600 bg-blue-50 px-2 py-0.5 rounded-full">SUBS</span>
        </div>
        <p class="text-2xl font-bold text-gray-900">TZS {{ number_format($subscriptionRevenue) }}</p>
        <p class="text-[11px] text-gray-400 mt-1">From active subscriptions</p>
    </div>

    {{-- Active Subscriptions --}}
    <div class="bg-white rounded-xl border p-5">
        <div class="flex items-center justify-between mb-2">
            <div class="w-10 h-10 rounded-xl bg-amber-100 flex items-center justify-center">
                <svg class="w-5 h-5 text-amber-600" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z"/></svg>
            </div>
            <span class="text-[10px] font-semibold text-amber-600 bg-amber-50 px-2 py-0.5 rounded-full">ACTIVE</span>
        </div>
        <p class="text-2xl font-bold text-gray-900">{{ $activeSubs }}</p>
        <p class="text-[11px] text-gray-400 mt-1">Currently active plans</p>
    </div>

    {{-- Total Payments --}}
    <div class="bg-white rounded-xl border p-5">
        <div class="flex items-center justify-between mb-2">
            <div class="w-10 h-10 rounded-xl bg-purple-100 flex items-center justify-center">
                <svg class="w-5 h-5 text-purple-600" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z"/></svg>
            </div>
            <span class="text-[10px] font-semibold text-purple-600 bg-purple-50 px-2 py-0.5 rounded-full">PAYMENTS</span>
        </div>
        <p class="text-2xl font-bold text-gray-900">{{ $totalPayments }}</p>
        <p class="text-[11px] text-gray-400 mt-1">Confirmed transactions</p>
    </div>
</div>

{{-- Subscription Cards --}}
<div class="mb-6">
    <h3 class="text-sm font-semibold text-gray-900 mb-3">Subscriptions</h3>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        @forelse($subscriptions as $sub)
        <div class="bg-white rounded-xl border overflow-hidden hover:shadow-md transition-shadow">
            <div class="px-5 py-3 {{ $sub->status === 'active' ? 'bg-emerald-50' : 'bg-gray-50' }} border-b">
                <div class="flex items-center justify-between">
                    <div class="flex items-center gap-2">
                        <span class="w-2 h-2 rounded-full {{ $sub->status === 'active' ? 'bg-emerald-500' : 'bg-gray-400' }}"></span>
                        <span class="text-xs font-semibold {{ $sub->status === 'active' ? 'text-emerald-700' : 'text-gray-500' }}">{{ ucfirst($sub->status) }}</span>
                    </div>
                    <span class="text-[10px] text-gray-400">{{ $sub->created_at ? $sub->created_at->format('d M Y') : '-' }}</span>
                </div>
            </div>
            <div class="px-5 py-4">
                <div class="flex items-center justify-between mb-3">
                    <div>
                        <p class="text-sm font-bold text-gray-900">{{ $sub->plan->name ?? 'Unknown Plan' }}</p>
                        <p class="text-[11px] text-gray-500">{{ ucfirst($sub->plan->billing_cycle ?? 'monthly') }}</p>
                    </div>
                    <div class="text-right">
                        <p class="text-lg font-bold text-gray-900">TZS {{ number_format($sub->amount) }}</p>
                    </div>
                </div>
                <div class="space-y-2 pt-3 border-t border-gray-100">
                    <div class="flex items-center justify-between">
                        <span class="text-[11px] text-gray-400">Organization</span>
                        <span class="text-xs font-medium text-gray-700">{{ $sub->organization->business_name ?? '-' }}</span>
                    </div>
                    <div class="flex items-center justify-between">
                        <span class="text-[11px] text-gray-400">Owner</span>
                        <span class="text-xs font-medium text-gray-700">{{ $sub->organization->owner->full_name ?? '-' }}</span>
                    </div>
                    <div class="flex items-center justify-between">
                        <span class="text-[11px] text-gray-400">Period</span>
                        <span class="text-xs text-gray-600">{{ $sub->start_date ? $sub->start_date->format('d M Y') : '-' }} → {{ $sub->end_date ? $sub->end_date->format('d M Y') : '-' }}</span>
                    </div>
                    <div class="flex items-center justify-between">
                        <span class="text-[11px] text-gray-400">Payment Ref</span>
                        <span class="text-xs font-medium text-gray-700">{{ $sub->payment_reference ?? '-' }}</span>
                    </div>
                </div>
            </div>
        </div>
        @empty
        <div class="col-span-full bg-white rounded-xl border p-8 text-center text-gray-400 text-xs">No subscriptions yet</div>
        @endforelse
    </div>
    <div class="mt-4 text-xs">
        {{ $subscriptions->links() }}
    </div>
</div>

{{-- Payment History --}}
<div class="bg-white rounded-xl border overflow-hidden">
    <div class="px-5 py-4 border-b">
        <div class="flex items-center justify-between flex-wrap gap-3">
            <div>
                <h3 class="text-sm font-semibold text-gray-900">Payment History</h3>
                <p class="text-[11px] text-gray-400 mt-0.5">Tenant rent payments collected via Snippe</p>
            </div>
            {{-- Filter Buttons --}}
            <div class="flex items-center gap-1.5">
                <a href="{{ route('admin.revenue', ['payment_status' => 'all']) }}" class="px-3 py-1.5 rounded-lg text-[11px] font-semibold transition-colors {{ request('payment_status', 'all') === 'all' || !request('payment_status') ? 'bg-emerald-600 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200' }}">All</a>
                <a href="{{ route('admin.revenue', ['payment_status' => 'confirmed']) }}" class="px-3 py-1.5 rounded-lg text-[11px] font-semibold transition-colors {{ request('payment_status') === 'confirmed' ? 'bg-emerald-600 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200' }}">Confirmed</a>
                <a href="{{ route('admin.revenue', ['payment_status' => 'pending']) }}" class="px-3 py-1.5 rounded-lg text-[11px] font-semibold transition-colors {{ request('payment_status') === 'pending' ? 'bg-emerald-600 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200' }}">Pending</a>
                <a href="{{ route('admin.revenue', ['payment_status' => 'failed']) }}" class="px-3 py-1.5 rounded-lg text-[11px] font-semibold transition-colors {{ request('payment_status') === 'failed' ? 'bg-emerald-600 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200' }}">Failed</a>
            </div>
        </div>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead><tr class="text-left text-xs text-gray-500 bg-gray-50/50">
                <th class="px-5 py-2.5 font-medium">Tenant</th>
                <th class="px-5 py-2.5 font-medium">Organization</th>
                <th class="px-5 py-2.5 font-medium">Amount</th>
                <th class="px-5 py-2.5 font-medium">Method</th>
                <th class="px-5 py-2.5 font-medium">Month</th>
                <th class="px-5 py-2.5 font-medium">Date</th>
                <th class="px-5 py-2.5 font-medium">Status</th>
            </tr></thead>
            <tbody>
                @forelse($payments as $payment)
                <tr class="border-t border-gray-100 hover:bg-gray-50/50 transition-colors">
                    <td class="px-5 py-2.5 text-xs text-gray-900 font-medium">{{ $payment->tenant->user->full_name ?? '-' }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-500">{{ $payment->organization->business_name ?? '-' }}</td>
                    <td class="px-5 py-2.5 text-xs font-semibold text-gray-900">TZS {{ number_format($payment->amount) }}</td>
                    <td class="px-5 py-2.5">
                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium bg-blue-50 text-blue-700 border border-blue-100">{{ ucfirst($payment->method ?? 'snippe') }}</span>
                    </td>
                    <td class="px-5 py-2.5 text-xs text-gray-700">{{ $payment->month_covered }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-500">{{ $payment->payment_date }}</td>
                    <td class="px-5 py-2.5">
                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium {{ $payment->status === 'confirmed' ? 'bg-emerald-50 text-emerald-700 border border-emerald-100' : ($payment->status === 'pending' ? 'bg-amber-50 text-amber-700 border border-amber-100' : 'bg-red-50 text-red-700 border border-red-100') }}">{{ ucfirst($payment->status) }}</span>
                    </td>
                </tr>
                @empty
                <tr><td colspan="7" class="px-5 py-8 text-center text-gray-400 text-xs">No payments found</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
    <div class="px-5 py-3 border-t text-xs">
        {{ $payments->links() }}
    </div>
</div>
@endsection
