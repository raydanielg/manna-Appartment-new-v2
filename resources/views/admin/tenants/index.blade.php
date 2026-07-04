@extends('layouts.admin')

@section('title', 'Tenants - Manna Apartment')
@section('page_title', 'Tenants')

@section('content')
<div class="space-y-4">
    @if(session('success'))
    <div class="bg-emerald-50 text-emerald-700 px-4 py-3 rounded-lg text-sm border border-emerald-100">
        {{ session('success') }}
    </div>
    @endif

    <div class="bg-white rounded-xl border overflow-hidden">
        <div class="px-5 py-4 border-b flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <h3 class="text-sm font-semibold text-gray-900">All Tenants</h3>
            <form method="GET" class="flex items-center gap-2">
                <input type="text" name="search" value="{{ $search }}" placeholder="Search by name or phone..." class="rounded-lg border-gray-300 text-sm focus:border-emerald-500 focus:ring-emerald-500 w-64">
                <button type="submit" class="px-3 py-2 bg-emerald-600 text-white text-xs font-semibold rounded-lg hover:bg-emerald-700">Search</button>
            </form>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead><tr class="text-left text-xs text-gray-500 bg-gray-50/50">
                    <th class="px-5 py-2.5 font-medium">Tenant</th>
                    <th class="px-5 py-2.5 font-medium">Phone</th>
                    <th class="px-5 py-2.5 font-medium">Landlord / Organization</th>
                    <th class="px-5 py-2.5 font-medium">Unit</th>
                    <th class="px-5 py-2.5 font-medium">Status</th>
                    <th class="px-5 py-2.5 font-medium text-right">Actions</th>
                </tr></thead>
                <tbody>
                    @forelse($tenants as $tenant)
                    <tr class="border-t border-gray-100 hover:bg-gray-50/50 transition-colors">
                        <td class="px-5 py-2.5">
                            <div class="text-xs font-medium text-gray-900">{{ $tenant->user->full_name ?? 'N/A' }}</div>
                            <div class="text-[10px] text-gray-400">ID: {{ $tenant->id_number ?? '-' }}</div>
                        </td>
                        <td class="px-5 py-2.5 text-xs text-gray-500">{{ $tenant->user->phone ?? '-' }}</td>
                        <td class="px-5 py-2.5">
                            <div class="text-xs font-medium text-gray-900">{{ $tenant->organization->business_name ?? 'N/A' }}</div>
                            <div class="text-[10px] text-gray-400">Owner: {{ $tenant->organization->owner->full_name ?? '-' }}</div>
                        </td>
                        <td class="px-5 py-2.5 text-xs text-gray-700">{{ $tenant->unit->name ?? '-' }}</td>
                        <td class="px-5 py-2.5">
                            <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium {{ $tenant->status === 'active' ? 'bg-emerald-50 text-emerald-700 border border-emerald-100' : 'bg-gray-100 text-gray-700 border border-gray-200' }}">{{ ucfirst($tenant->status ?? 'pending') }}</span>
                        </td>
                        <td class="px-5 py-2.5 text-right">
                            <div class="flex items-center justify-end gap-3">
                                <a href="{{ route('admin.tenants.show', $tenant->id) }}" class="text-xs text-emerald-600 hover:text-emerald-700 font-medium">View</a>
                                <form action="{{ route('admin.tenants.destroy', $tenant->id) }}" method="POST" onsubmit="return confirm('Are you sure you want to remove this tenant?');" class="inline">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="text-xs text-red-600 hover:text-red-700 font-medium">Remove</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    @empty
                    <tr><td colspan="6" class="px-5 py-8 text-center text-gray-400 text-xs">No tenants found</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="px-5 py-3 border-t text-xs">
            {{ $tenants->links() }}
        </div>
    </div>
</div>
@endsection
