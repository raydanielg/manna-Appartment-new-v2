@extends('layouts.admin')

@section('title', 'Subscription Plans - Manna Apartment')
@section('page_title', 'Subscription Plans')

@section('content')
<div class="bg-white rounded-xl border overflow-hidden">
    <div class="px-5 py-4 border-b flex items-center justify-between">
        <h3 class="text-sm font-semibold text-gray-900">Plans</h3>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead><tr class="text-left text-xs text-gray-500 bg-gray-50/50">
                <th class="px-5 py-2.5 font-medium">Name</th>
                <th class="px-5 py-2.5 font-medium">Price</th>
                <th class="px-5 py-2.5 font-medium">Cycle</th>
                <th class="px-5 py-2.5 font-medium">Property Limit</th>
                <th class="px-5 py-2.5 font-medium">Unit Limit</th>
                <th class="px-5 py-2.5 font-medium">SMS Included</th>
            </tr></thead>
            <tbody>
                @forelse($plans as $plan)
                <tr class="border-t border-gray-100 hover:bg-gray-50/50 transition-colors">
                    <td class="px-5 py-2.5 text-xs font-medium text-gray-900">{{ $plan->name }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-700">TZS {{ number_format($plan->price) }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-700">{{ ucfirst($plan->billing_cycle) }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-700">{{ $plan->property_limit ?: 'Unlimited' }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-700">{{ $plan->unit_limit ?: 'Unlimited' }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-700">{{ number_format($plan->sms_included) }}</td>
                </tr>
                @empty
                <tr><td colspan="6" class="px-5 py-8 text-center text-gray-400 text-xs">No plans</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection
