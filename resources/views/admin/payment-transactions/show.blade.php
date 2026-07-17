@extends('layouts.admin')

@section('title', 'Transaction Details - Manna Apartment')
@section('page_title', 'Transaction Receipt')

@section('content')
<div class="max-w-2xl mx-auto space-y-6">

    <div class="flex items-center justify-between">
        <a href="{{ route('admin.payment-transactions') }}" class="inline-flex items-center gap-2 text-sm font-semibold text-gray-500 hover:text-emerald-600 transition-colors">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
            Back to Transactions
        </a>
        <button onclick="window.print()" class="inline-flex items-center gap-2 px-4 py-2 bg-emerald-600 text-white text-sm font-bold rounded-lg hover:bg-emerald-700 transition-colors">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2V9a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/></svg>
            Print Receipt
        </button>
    </div>

    {{-- Receipt Card --}}
    <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
        {{-- Header --}}
        <div class="bg-emerald-900 text-white px-8 py-6 text-center">
            <div class="text-lg font-extrabold tracking-wider">MANNA APARTMENT</div>
            <div class="text-xs text-emerald-300/60 mt-1">Snippe Payment Receipt</div>
            <div class="mt-3 inline-block">
                @if ($transaction->status === 'completed')
                    <span class="px-4 py-1 rounded-full text-xs font-extrabold bg-green-500/20 text-green-400">COMPLETED</span>
                @elseif ($transaction->status === 'pending')
                    <span class="px-4 py-1 rounded-full text-xs font-extrabold bg-amber-500/20 text-amber-400">PENDING</span>
                @elseif ($transaction->status === 'failed')
                    <span class="px-4 py-1 rounded-full text-xs font-extrabold bg-red-500/20 text-red-400">FAILED</span>
                @else
                    <span class="px-4 py-1 rounded-full text-xs font-extrabold bg-gray-500/20 text-gray-300">{{ strtoupper($transaction->status) }}</span>
                @endif
            </div>
        </div>

        {{-- Body --}}
        <div class="px-8 py-6 space-y-1">
            <div class="flex justify-between py-2 border-b border-gray-50">
                <span class="text-sm text-gray-500">Transaction ID</span>
                <span class="text-sm font-bold text-gray-800 font-mono">{{ $transaction->id }}</span>
            </div>
            <div class="flex justify-between py-2 border-b border-gray-50">
                <span class="text-sm text-gray-500">Provider Reference</span>
                <span class="text-sm font-bold text-gray-800 font-mono">{{ $transaction->provider_reference ?? '—' }}</span>
            </div>
            <div class="flex justify-between py-2 border-b border-gray-50">
                <span class="text-sm text-gray-500">Organization</span>
                <span class="text-sm font-bold text-gray-800">{{ $transaction->organization?->name ?? '—' }}</span>
            </div>
            <div class="flex justify-between py-2 border-b border-gray-50">
                <span class="text-sm text-gray-500">User</span>
                <span class="text-sm font-bold text-gray-800">{{ $transaction->user?->full_name ?? $transaction->user?->email ?? '—' }}</span>
            </div>
            <div class="flex justify-between py-2 border-b border-gray-50">
                <span class="text-sm text-gray-500">Type</span>
                <span class="text-sm font-bold text-gray-800 uppercase">{{ $transaction->type }}</span>
            </div>
            <div class="flex justify-between py-2 border-b border-gray-50">
                <span class="text-sm text-gray-500">Amount</span>
                <span class="text-sm font-bold text-gray-800">{{ $transaction->currency }} {{ number_format((float)$transaction->amount, 0) }}</span>
            </div>
            <div class="flex justify-between py-2 border-b border-gray-50">
                <span class="text-sm text-gray-500">Payment Method</span>
                <span class="text-sm font-bold text-gray-800 capitalize">{{ str_replace('_', ' ', $transaction->payment_method ?? '—') }}</span>
            </div>
            <div class="flex justify-between py-2 border-b border-gray-50">
                <span class="text-sm text-gray-500">Phone</span>
                <span class="text-sm font-bold text-gray-800 font-mono">{{ $transaction->phone ?? '—' }}</span>
            </div>
            <div class="flex justify-between py-2 border-b border-gray-50">
                <span class="text-sm text-gray-500">Provider</span>
                <span class="text-sm font-bold text-gray-800 capitalize">{{ $transaction->provider }}</span>
            </div>
            <div class="flex justify-between py-2 border-b border-gray-50">
                <span class="text-sm text-gray-500">Created At</span>
                <span class="text-sm font-bold text-gray-800">{{ $transaction->created_at->format('d M Y, H:i') }}</span>
            </div>
            <div class="flex justify-between py-2 border-b border-gray-50">
                <span class="text-sm text-gray-500">Paid At</span>
                <span class="text-sm font-bold text-gray-800">{{ $transaction->paid_at ? $transaction->paid_at->format('d M Y, H:i') : '—' }}</span>
            </div>

            {{-- Total --}}
            <div class="flex justify-between py-4 mt-2 border-t-2 border-gray-100">
                <span class="text-base font-extrabold text-emerald-900">TOTAL AMOUNT</span>
                <span class="text-xl font-extrabold text-emerald-600">{{ $transaction->currency }} {{ number_format((float)$transaction->amount, 0) }}</span>
            </div>

            {{-- Footer --}}
            <div class="text-center pt-4 border-t border-gray-50">
                <p class="text-xs text-gray-400 italic">This is a computer generated receipt.</p>
                <p class="text-sm text-gray-500 font-semibold mt-1">Thank you for your payment!</p>
            </div>
        </div>
    </div>

    {{-- Payload --}}
    @if ($transaction->payload)
    <div class="bg-gray-900 rounded-xl border border-gray-100 shadow-sm overflow-hidden">
        <div class="px-5 py-3 border-b border-gray-800">
            <h3 class="font-bold text-gray-300 text-sm">Raw Payload from Snippe</h3>
        </div>
        <div class="p-5">
            <pre class="text-xs text-green-400 font-mono overflow-x-auto max-h-96">{{ json_encode($transaction->payload, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) }}</pre>
        </div>
    </div>
    @endif

</div>
@endsection
