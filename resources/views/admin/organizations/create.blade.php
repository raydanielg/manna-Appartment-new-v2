@extends('layouts.admin')

@section('title', 'Add Landlord - Manna Apartment')
@section('page_title', 'Add Owner / Landlord')

@section('content')
<div class="max-w-2xl mx-auto bg-white rounded-xl border overflow-hidden">
    <div class="px-6 py-4 border-b">
        <h3 class="text-sm font-semibold text-gray-900">Create new landlord organization</h3>
    </div>
    <form method="POST" action="{{ route('admin.organizations.store') }}" class="p-6 space-y-4">
        @csrf
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
                <label class="block text-xs font-medium text-gray-700 mb-1">Full Name</label>
                <input type="text" name="full_name" required value="{{ old('full_name') }}" class="w-full px-3 py-2 border rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-emerald-500">
            </div>
            <div>
                <label class="block text-xs font-medium text-gray-700 mb-1">Phone</label>
                <input type="text" name="phone" required value="{{ old('phone') }}" class="w-full px-3 py-2 border rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-emerald-500">
            </div>
        </div>
        <div>
            <label class="block text-xs font-medium text-gray-700 mb-1">Email</label>
            <input type="email" name="email" value="{{ old('email') }}" class="w-full px-3 py-2 border rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-emerald-500">
        </div>
        <div>
            <label class="block text-xs font-medium text-gray-700 mb-1">Business Name</label>
            <input type="text" name="business_name" required value="{{ old('business_name') }}" class="w-full px-3 py-2 border rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-emerald-500">
        </div>
        <div>
            <label class="block text-xs font-medium text-gray-700 mb-1">Password</label>
            <input type="password" name="password" required class="w-full px-3 py-2 border rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-emerald-500">
        </div>
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
                <label class="block text-xs font-medium text-gray-700 mb-1">Subscription Plan (optional)</label>
                <select name="plan_id" class="w-full px-3 py-2 border rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-emerald-500">
                    <option value="">None</option>
                    @foreach($plans as $plan)
                    <option value="{{ $plan->id }}" {{ old('plan_id') == $plan->id ? 'selected' : '' }}>{{ $plan->name }} (TZS {{ number_format($plan->price) }} / {{ $plan->billing_cycle }})</option>
                    @endforeach
                </select>
            </div>
            <div>
                <label class="block text-xs font-medium text-gray-700 mb-1">Start Date</label>
                <input type="date" name="start_date" value="{{ old('start_date', now()->toDateString()) }}" class="w-full px-3 py-2 border rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-emerald-500">
            </div>
        </div>
        <div class="pt-4 flex items-center gap-3">
            <button type="submit" class="px-5 py-2 bg-emerald-600 text-white rounded-lg text-xs font-semibold hover:bg-emerald-700">Create Landlord</button>
            <a href="{{ route('admin.organizations') }}" class="px-5 py-2 border rounded-lg text-xs font-semibold text-gray-600 hover:bg-gray-50">Cancel</a>
        </div>
    </form>
</div>
@endsection
