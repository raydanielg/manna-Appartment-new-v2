@extends('layouts.admin')

@section('title', 'Tenant Details - Manna Apartment')
@section('page_title', 'Tenant Details')

@section('content')
<div class="max-w-3xl mx-auto space-y-4">
    <a href="{{ route('admin.tenants.index') }}" class="text-xs text-emerald-600 hover:text-emerald-700 font-medium">&larr; Back to Tenants</a>

    <div class="bg-white rounded-xl border overflow-hidden">
        <div class="px-5 py-4 border-b">
            <h3 class="text-sm font-semibold text-gray-900">{{ $tenant->user->full_name ?? 'Tenant' }}</h3>
        </div>
        <div class="p-5 space-y-3 text-sm">
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                    <span class="text-xs text-gray-500">Phone</span>
                    <p class="font-medium text-gray-900">{{ $tenant->user->phone ?? '-' }}</p>
                </div>
                <div>
                    <span class="text-xs text-gray-500">Email</span>
                    <p class="font-medium text-gray-900">{{ $tenant->user->email ?? '-' }}</p>
                </div>
                <div>
                    <span class="text-xs text-gray-500">Landlord / Organization</span>
                    <p class="font-medium text-gray-900">{{ $tenant->organization->business_name ?? '-' }}</p>
                </div>
                <div>
                    <span class="text-xs text-gray-500">Organization Owner</span>
                    <p class="font-medium text-gray-900">{{ $tenant->organization->owner->full_name ?? '-' }}</p>
                </div>
                <div>
                    <span class="text-xs text-gray-500">Unit</span>
                    <p class="font-medium text-gray-900">{{ $tenant->unit->name ?? '-' }}</p>
                </div>
                <div>
                    <span class="text-xs text-gray-500">Status</span>
                    <p class="font-medium text-gray-900">{{ ucfirst($tenant->status ?? '-') }}</p>
                </div>
                <div>
                    <span class="text-xs text-gray-500">Moved In</span>
                    <p class="font-medium text-gray-900">{{ $tenant->moved_in_date?->format('M d, Y') ?? '-' }}</p>
                </div>
                <div>
                    <span class="text-xs text-gray-500">Moved Out</span>
                    <p class="font-medium text-gray-900">{{ $tenant->moved_out_date?->format('M d, Y') ?? '-' }}</p>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
