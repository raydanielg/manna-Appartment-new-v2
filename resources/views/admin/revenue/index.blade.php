@extends('layouts.admin')

@section('title', 'Revenue - Manna Apartment')
@section('page_title', 'Revenue')

@section('content')
<div class="bg-white rounded-xl border overflow-hidden mb-6">
    <div class="px-5 py-4 border-b">
        <h3 class="text-sm font-semibold text-gray-900">Payments</h3>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead><tr class="text-left text-xs text-gray-500 bg-gray-50/50">
                <th class="px-5 py-2.5 font-medium">Tenant</th>
                <th class="px-5 py-2.5 font-medium">Organization</th>
                <th class="px-5 py-2.5 font-medium">Amount</th>
                <th class="px-5 py-2.5 font-medium">Month</th>
                <th class="px-5 py-2.5 font-medium">Date</th>
            </tr></thead>
            <tbody>
                @forelse($payments as $payment)
                <tr class="border-t border-gray-100 hover:bg-gray-50/50 transition-colors">
                    <td class="px-5 py-2.5 text-xs text-gray-900">{{ $payment->tenant->user->full_name ?? '-' }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-500">{{ $payment->organization->name ?? '-' }}</td>
                    <td class="px-5 py-2.5 text-xs font-semibold text-gray-900">TZS {{ number_format($payment->amount) }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-700">{{ $payment->month_covered }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-500">{{ $payment->payment_date }}</td>
                </tr>
                @empty
                <tr><td colspan="5" class="px-5 py-8 text-center text-gray-400 text-xs">No payments</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
    <div class="px-5 py-3 border-t text-xs">
        {{ $payments->links() }}
    </div>
</div>

<div class="bg-white rounded-xl border overflow-hidden">
    <div class="px-5 py-4 border-b">
        <h3 class="text-sm font-semibold text-gray-900">Subscriptions</h3>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead><tr class="text-left text-xs text-gray-500 bg-gray-50/50">
                <th class="px-5 py-2.5 font-medium">Organization</th>
                <th class="px-5 py-2.5 font-medium">Plan</th>
                <th class="px-5 py-2.5 font-medium">Amount</th>
                <th class="px-5 py-2.5 font-medium">Start</th>
                <th class="px-5 py-2.5 font-medium">End</th>
                <th class="px-5 py-2.5 font-medium">Status</th>
            </tr></thead>
            <tbody>
                @forelse($subscriptions as $sub)
                <tr class="border-t border-gray-100 hover:bg-gray-50/50 transition-colors">
                    <td class="px-5 py-2.5 text-xs text-gray-900">{{ $sub->organization->name ?? '-' }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-700">{{ $sub->plan->name ?? '-' }}</td>
                    <td class="px-5 py-2.5 text-xs font-semibold text-gray-900">TZS {{ number_format($sub->amount) }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-500">{{ $sub->start_date }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-500">{{ $sub->end_date }}</td>
                    <td class="px-5 py-2.5">
                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium {{ $sub->status === 'active' ? 'bg-emerald-50 text-emerald-700 border border-emerald-100' : 'bg-red-50 text-red-700 border border-red-100' }}">{{ ucfirst($sub->status) }}</span>
                    </td>
                </tr>
                @empty
                <tr><td colspan="6" class="px-5 py-8 text-center text-gray-400 text-xs">No subscriptions</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
    <div class="px-5 py-3 border-t text-xs">
        {{ $subscriptions->links() }}
    </div>
</div>
@endsection
