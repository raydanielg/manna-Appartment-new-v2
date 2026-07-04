@extends('layouts.admin')

@section('title', 'Organization Details - Manna Apartment')
@section('page_title', 'Organization Details')

@section('content')
<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <div class="lg:col-span-2 space-y-6">
        <div class="bg-white rounded-xl border overflow-hidden">
            <div class="px-5 py-4 border-b flex items-center justify-between">
                <h3 class="text-sm font-semibold text-gray-900">Overview</h3>
                <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium {{ $organization->status === 'active' ? 'bg-emerald-50 text-emerald-700 border border-emerald-100' : 'bg-gray-100 text-gray-700 border border-gray-200' }}">{{ ucfirst($organization->status) }}</span>
            </div>
            <div class="p-5 grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
                <div class="bg-gray-50 rounded-lg p-3">
                    <p class="text-xs text-gray-500 mb-1">Business Name</p>
                    <p class="font-semibold text-gray-900">{{ $organization->business_name ?? '-' }}</p>
                </div>
                <div class="bg-gray-50 rounded-lg p-3">
                    <p class="text-xs text-gray-500 mb-1">Owner</p>
                    <p class="font-semibold text-gray-900">{{ $organization->owner->full_name ?? '-' }}</p>
                </div>
                <div class="bg-gray-50 rounded-lg p-3">
                    <p class="text-xs text-gray-500 mb-1">Phone</p>
                    <p class="font-semibold text-gray-900">{{ $organization->owner->phone ?? '-' }}</p>
                </div>
                <div class="bg-gray-50 rounded-lg p-3">
                    <p class="text-xs text-gray-500 mb-1">Email</p>
                    <p class="font-semibold text-gray-900">{{ $organization->owner->email ?? '-' }}</p>
                </div>
                <div class="bg-gray-50 rounded-lg p-3">
                    <p class="text-xs text-gray-500 mb-1">Properties</p>
                    <p class="font-semibold text-gray-900">{{ $organization->properties_count }}</p>
                </div>
                <div class="bg-gray-50 rounded-lg p-3">
                    <p class="text-xs text-gray-500 mb-1">Tenants</p>
                    <p class="font-semibold text-gray-900">{{ $organization->tenants_count }}</p>
                </div>
                <div class="bg-gray-50 rounded-lg p-3">
                    <p class="text-xs text-gray-500 mb-1">SMS Balance</p>
                    <p class="font-semibold text-gray-900">{{ number_format($organization->sms_balance) }}</p>
                </div>
                <div class="bg-gray-50 rounded-lg p-3">
                    <p class="text-xs text-gray-500 mb-1">Joined</p>
                    <p class="font-semibold text-gray-900">{{ $organization->created_at ? $organization->created_at->format('Y-m-d') : '-' }}</p>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-xl border overflow-hidden">
            <div class="px-5 py-4 border-b">
                <h3 class="text-sm font-semibold text-gray-900">KYC Documents</h3>
            </div>
            <div class="p-5">
                @forelse($organization->kycDocuments as $doc)
                <div class="border rounded-lg p-4 mb-3 last:mb-0">
                    <div class="flex items-center justify-between mb-2">
                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium
                            {{ $doc->status === 'approved' ? 'bg-emerald-50 text-emerald-700 border border-emerald-100' : ($doc->status === 'pending' ? 'bg-amber-50 text-amber-700 border border-amber-100' : 'bg-red-50 text-red-700 border border-red-100') }}">{{ ucfirst($doc->status) }}</span>
                        <span class="text-xs text-gray-500">ID: {{ $doc->id_number }}</span>
                    </div>
                    <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
                        @if($doc->id_photo_front)
                        <a href="{{ url('storage/' . $doc->id_photo_front) }}" target="_blank" class="block border rounded-lg overflow-hidden hover:opacity-90">
                            <img src="{{ url('storage/' . $doc->id_photo_front) }}" class="w-full h-24 object-cover" alt="ID Front">
                        </a>
                        @endif
                        @if($doc->id_photo_back)
                        <a href="{{ url('storage/' . $doc->id_photo_back) }}" target="_blank" class="block border rounded-lg overflow-hidden hover:opacity-90">
                            <img src="{{ url('storage/' . $doc->id_photo_back) }}" class="w-full h-24 object-cover" alt="ID Back">
                        </a>
                        @endif
                        @if($doc->selfie_photo)
                        <a href="{{ url('storage/' . $doc->selfie_photo) }}" target="_blank" class="block border rounded-lg overflow-hidden hover:opacity-90">
                            <img src="{{ url('storage/' . $doc->selfie_photo) }}" class="w-full h-24 object-cover" alt="Selfie">
                        </a>
                        @endif
                        @if($doc->ownership_proof)
                        <a href="{{ url('storage/' . $doc->ownership_proof) }}" target="_blank" class="block border rounded-lg overflow-hidden hover:opacity-90">
                            <img src="{{ url('storage/' . $doc->ownership_proof) }}" class="w-full h-24 object-cover" alt="Ownership Proof">
                        </a>
                        @endif
                    </div>
                    @if($doc->review_notes)
                    <p class="text-xs text-gray-500 mt-2">Notes: {{ $doc->review_notes }}</p>
                    @endif
                </div>
                @empty
                <p class="text-xs text-gray-400 text-center py-6">No KYC documents submitted</p>
                @endforelse
            </div>
        </div>
    </div>

    <div class="space-y-6">
        <div class="bg-white rounded-xl border overflow-hidden">
            <div class="px-5 py-4 border-b">
                <h3 class="text-sm font-semibold text-gray-900">Manage Status</h3>
            </div>
            <div class="p-5 space-y-3">
                <form method="POST" action="{{ route('admin.organizations.update-status', $organization->id) }}" class="space-y-3">
                    @csrf
                    @method('PATCH')
                    <div>
                        <label class="block text-xs font-medium text-gray-700 mb-1">Organization Status</label>
                        <select name="status" class="w-full px-3 py-2 border rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-emerald-500">
                            <option value="active" {{ $organization->status === 'active' ? 'selected' : '' }}>Active</option>
                            <option value="suspended" {{ $organization->status === 'suspended' ? 'selected' : '' }}>Suspended</option>
                            <option value="deactivated" {{ $organization->status === 'deactivated' ? 'selected' : '' }}>Deactivated</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-gray-700 mb-1">Reason (if suspending/deactivating)</label>
                        <textarea name="reason" rows="2" class="w-full px-3 py-2 border rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-emerald-500">{{ $organization->suspension_reason }}</textarea>
                    </div>
                    <button type="submit" class="w-full bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-semibold py-2 rounded-lg transition">Update Status</button>
                </form>
                @if($organization->suspension_reason)
                <div class="bg-amber-50 border border-amber-100 rounded-lg p-3 text-xs text-amber-800">
                    <strong>Suspension reason:</strong> {{ $organization->suspension_reason }}
                </div>
                @endif
                <form method="POST" action="{{ route('admin.organizations.update-kyc', $organization->id) }}" class="pt-2 border-t space-y-3">
                    @csrf
                    @method('PATCH')
                    <div>
                        <label class="block text-xs font-medium text-gray-700 mb-1">KYC Status</label>
                        <select name="kyc_status" class="w-full px-3 py-2 border rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-emerald-500">
                            <option value="pending" {{ $organization->kyc_status === 'pending' ? 'selected' : '' }}>Pending</option>
                            <option value="approved" {{ $organization->kyc_status === 'approved' ? 'selected' : '' }}>Approved</option>
                            <option value="rejected" {{ $organization->kyc_status === 'rejected' ? 'selected' : '' }}>Rejected</option>
                        </select>
                    </div>
                    <button type="submit" class="w-full bg-sky-600 hover:bg-sky-700 text-white text-xs font-semibold py-2 rounded-lg transition">Update KYC</button>
                </form>
            </div>
        </div>

        <div class="bg-white rounded-xl border overflow-hidden">
            <div class="px-5 py-4 border-b">
                <h3 class="text-sm font-semibold text-gray-900">Subscription</h3>
            </div>
            <div class="p-5">
                @if($organization->subscription)
                @php
                    $sub = $organization->subscription;
                    $active = $sub->status === 'active' && $sub->end_date && $sub->end_date->isFuture();
                @endphp
                <div class="space-y-3 text-sm">
                    <div class="bg-gray-50 rounded-lg p-3">
                        <p class="text-xs text-gray-500 mb-1">Plan</p>
                        <p class="font-semibold text-gray-900">{{ $sub->plan->name ?? '-' }}</p>
                    </div>
                    <div class="bg-gray-50 rounded-lg p-3">
                        <p class="text-xs text-gray-500 mb-1">Status</p>
                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium {{ $active ? 'bg-emerald-50 text-emerald-700 border border-emerald-100' : 'bg-red-50 text-red-700 border border-red-100' }}">{{ $active ? 'Active' : 'Inactive' }}</span>
                    </div>
                    <div class="bg-gray-50 rounded-lg p-3">
                        <p class="text-xs text-gray-500 mb-1">Amount</p>
                        <p class="font-semibold text-gray-900">TZS {{ number_format($sub->amount) }}</p>
                    </div>
                    <div class="bg-gray-50 rounded-lg p-3">
                        <p class="text-xs text-gray-500 mb-1">Period</p>
                        <p class="font-semibold text-gray-900">{{ $sub->start_date?->format('Y-m-d') }} - {{ $sub->end_date?->format('Y-m-d') }}</p>
                    </div>
                </div>
                @else
                <p class="text-xs text-gray-400 text-center py-4">No active subscription</p>
                @endif
            </div>
        </div>

        <div class="bg-white rounded-xl border overflow-hidden">
            <div class="px-5 py-4 border-b">
                <h3 class="text-sm font-semibold text-gray-900">Assign Plan</h3>
            </div>
            <div class="p-5">
                <form action="{{ route('admin.organizations.assign-plan', $organization->id) }}" method="POST" class="space-y-3">
                    @csrf
                    <div>
                        <label class="block text-xs font-medium text-gray-700 mb-1">Plan</label>
                        <select name="plan_id" class="w-full text-sm border rounded-lg px-3 py-2 outline-none focus:border-emerald-500">
                            @foreach($plans as $plan)
                            <option value="{{ $plan->id }}">{{ $plan->name }} - TZS {{ number_format($plan->price) }} / {{ $plan->billing_cycle }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-gray-700 mb-1">Start Date</label>
                        <input type="date" name="start_date" value="{{ now()->format('Y-m-d') }}" class="w-full text-sm border rounded-lg px-3 py-2 outline-none focus:border-emerald-500">
                    </div>
                    <button type="submit" class="w-full bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-medium py-2 rounded-lg transition-colors">Assign Plan</button>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection
