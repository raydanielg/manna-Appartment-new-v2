@extends('layouts.admin')

@section('title', 'Organizations - Manna Apartment')
@section('page_title', 'Organizations')

@section('content')
<div class="bg-white rounded-xl border overflow-hidden">
    <div class="px-5 py-4 border-b flex items-center justify-between">
        <h3 class="text-sm font-semibold text-gray-900">All Organizations</h3>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead><tr class="text-left text-xs text-gray-500 bg-gray-50/50">
                <th class="px-5 py-2.5 font-medium">Name</th>
                <th class="px-5 py-2.5 font-medium">Phone</th>
                <th class="px-5 py-2.5 font-medium">Status</th>
                <th class="px-5 py-2.5 font-medium">KYC</th>
                <th class="px-5 py-2.5 font-medium">Subscription</th>
                <th class="px-5 py-2.5 font-medium">Properties</th>
                <th class="px-5 py-2.5 font-medium">Tenants</th>
                <th class="px-5 py-2.5 font-medium">Actions</th>
            </tr></thead>
            <tbody>
                @forelse($organizations as $org)
                @php
                    $sub = $org->subscription;
                    $subActive = $sub && $sub->status === 'active' && $sub->end_date && $sub->end_date->isFuture();
                @endphp
                <tr class="border-t border-gray-100 hover:bg-gray-50/50 transition-colors">
                    <td class="px-5 py-2.5 text-xs font-medium text-gray-900">{{ $org->business_name ?? '-' }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-500">{{ $org->owner->phone ?? '-' }}</td>
                    <td class="px-5 py-2.5">
                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium {{ $org->status === 'active' ? 'bg-emerald-50 text-emerald-700 border border-emerald-100' : 'bg-gray-100 text-gray-700 border border-gray-200' }}">{{ ucfirst($org->status) }}</span>
                    </td>
                    <td class="px-5 py-2.5">
                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium
                            {{ $org->kyc_status === 'approved' ? 'bg-emerald-50 text-emerald-700 border border-emerald-100' : ($org->kyc_status === 'pending' ? 'bg-amber-50 text-amber-700 border border-amber-100' : 'bg-red-50 text-red-700 border border-red-100') }}">{{ ucfirst($org->kyc_status) }}</span>
                    </td>
                    <td class="px-5 py-2.5">
                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium {{ $subActive ? 'bg-emerald-50 text-emerald-700 border border-emerald-100' : 'bg-red-50 text-red-700 border border-red-100' }}">
                            {{ $subActive ? 'Active' : 'Inactive' }}
                        </span>
                    </td>
                    <td class="px-5 py-2.5 text-xs text-gray-700">{{ $org->properties_count }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-700">{{ $org->tenants_count }}</td>
                    <td class="px-5 py-2.5">
                        <div class="flex items-center gap-2">
                            <a href="{{ route('admin.organizations.show', $org->id) }}" class="px-2 py-1 rounded-md bg-gray-100 text-gray-600 hover:bg-gray-200 text-[10px] font-medium">View</a>
                            <button type="button" onclick="deleteOrganization('{{ route('admin.organizations.destroy', $org->id) }}')" class="px-2 py-1 rounded-md bg-red-600 text-white hover:bg-red-700 text-[10px] font-medium">Delete</button>
                        </div>
                    </td>
                </tr>
                @empty
                <tr><td colspan="8" class="px-5 py-8 text-center text-gray-400 text-xs">No organizations yet</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
    <div class="px-5 py-3 border-t text-xs">
        {{ $organizations->links() }}
    </div>
</div>
@endsection

@push('scripts')
<script>
function deleteOrganization(url) {
    Swal.fire({
        title: 'Delete organization?',
        text: 'This action cannot be undone.',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonText: 'Delete',
        confirmButtonColor: '#dc2626',
        cancelButtonText: 'Cancel',
    }).then((result) => {
        if (result.isConfirmed) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = url;
            form.style.display = 'none';

            const csrf = document.createElement('input');
            csrf.name = '_token';
            csrf.value = document.querySelector('meta[name="csrf-token"]').content;
            form.appendChild(csrf);

            const method = document.createElement('input');
            method.name = '_method';
            method.value = 'DELETE';
            form.appendChild(method);

            document.body.appendChild(form);
            form.submit();
        }
    });
}
</script>
@endpush
