@extends('layouts.admin')

@section('title', 'Organizations - Manna Apartment')
@section('page_title', 'Organizations')

@section('content')
<div class="mb-6 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
    <div>
        <h3 class="text-sm font-semibold text-gray-900">All Organizations / Landlords</h3>
        <p class="text-xs text-gray-500">Manage owners, organizations and their status.</p>
    </div>
    <a href="{{ route('admin.organizations.create') }}" class="inline-flex items-center gap-2 px-4 py-2 bg-emerald-600 text-white rounded-lg text-xs font-semibold hover:bg-emerald-700 transition">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
        Add Owner / Landlord
    </a>
</div>

<div class="bg-white rounded-xl border p-4 mb-4">
    <form method="GET" action="{{ route('admin.organizations') }}" class="flex flex-col sm:flex-row gap-3">
        <input type="text" name="search" value="{{ request('search') }}" placeholder="Search by name, phone..." class="flex-1 min-w-0 px-3 py-2 border rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-emerald-500">
        <select name="status" class="px-3 py-2 border rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-emerald-500">
            <option value="">All Status</option>
            <option value="active" {{ request('status') === 'active' ? 'selected' : '' }}>Active</option>
            <option value="suspended" {{ request('status') === 'suspended' ? 'selected' : '' }}>Suspended</option>
            <option value="deactivated" {{ request('status') === 'deactivated' ? 'selected' : '' }}>Deactivated</option>
        </select>
        <select name="kyc_status" class="px-3 py-2 border rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-emerald-500">
            <option value="">All KYC</option>
            <option value="pending" {{ request('kyc_status') === 'pending' ? 'selected' : '' }}>Pending</option>
            <option value="approved" {{ request('kyc_status') === 'approved' ? 'selected' : '' }}>Approved</option>
            <option value="rejected" {{ request('kyc_status') === 'rejected' ? 'selected' : '' }}>Rejected</option>
        </select>
        <button type="submit" class="px-4 py-2 bg-gray-900 text-white rounded-lg text-xs font-semibold hover:bg-gray-800">Filter</button>
        <a href="{{ route('admin.organizations') }}" class="px-4 py-2 border rounded-lg text-xs font-semibold text-gray-600 hover:bg-gray-50 text-center">Reset</a>
    </form>
</div>

<div class="bg-white rounded-xl border overflow-hidden">
    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead><tr class="text-left text-xs text-gray-500 bg-gray-50/50">
                <th class="px-5 py-2.5 font-medium">Name</th>
                <th class="px-5 py-2.5 font-medium">Owner</th>
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
                    <td class="px-5 py-2.5 text-xs text-gray-700">{{ $org->owner->full_name ?? '-' }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-500">{{ $org->owner->phone ?? '-' }}</td>
                    <td class="px-5 py-2.5">
                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium {{ $org->status === 'active' ? 'bg-emerald-50 text-emerald-700 border border-emerald-100' : ($org->status === 'suspended' ? 'bg-amber-50 text-amber-700 border border-amber-100' : 'bg-gray-100 text-gray-700 border border-gray-200') }}">{{ ucfirst($org->status) }}</span>
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
                        <div class="flex items-center gap-2 flex-wrap">
                            <a href="{{ route('admin.organizations.show', $org->id) }}" class="px-2 py-1 rounded-md bg-gray-100 text-gray-600 hover:bg-gray-200 text-[10px] font-medium">View</a>
                            <button type="button" onclick="updateStatus('{{ route('admin.organizations.update-status', $org->id) }}', 'active')" class="px-2 py-1 rounded-md bg-emerald-600 text-white hover:bg-emerald-700 text-[10px] font-medium">Activate</button>
                            <button type="button" onclick="updateStatus('{{ route('admin.organizations.update-status', $org->id) }}', 'suspended')" class="px-2 py-1 rounded-md bg-amber-500 text-white hover:bg-amber-600 text-[10px] font-medium">Suspend</button>
                            <button type="button" onclick="updateStatus('{{ route('admin.organizations.update-status', $org->id) }}', 'deactivated')" class="px-2 py-1 rounded-md bg-gray-600 text-white hover:bg-gray-700 text-[10px] font-medium">Deactivate</button>
                            <button type="button" onclick="deleteOrganization('{{ route('admin.organizations.destroy', $org->id) }}')" class="px-2 py-1 rounded-md bg-red-600 text-white hover:bg-red-700 text-[10px] font-medium">Delete</button>
                        </div>
                    </td>
                </tr>
                @empty
                <tr><td colspan="9" class="px-5 py-8 text-center text-gray-400 text-xs">No organizations yet</td></tr>
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
function updateStatus(url, status) {
    if (status === 'active') {
        submitStatusForm(url, status, '');
        return;
    }
    const title = status === 'suspended' ? 'Suspend organization?' : 'Deactivate organization?';
    const text = 'The landlord will lose access to the app. You can add a reason below.';
    Swal.fire({
        title: title,
        text: text,
        icon: 'warning',
        input: 'textarea',
        inputPlaceholder: 'Reason (optional)',
        inputAttributes: { 'aria-label': 'Reason for this action' },
        showCancelButton: true,
        confirmButtonText: 'Yes, ' + status,
        confirmButtonColor: status === 'suspended' ? '#d97706' : '#4b5563',
        cancelButtonText: 'Cancel',
        customClass: {
            popup: 'rounded-2xl',
            confirmButton: 'rounded-lg px-4 py-2 text-sm font-semibold',
            cancelButton: 'rounded-lg px-4 py-2 text-sm font-semibold',
        }
    }).then((result) => {
        if (result.isConfirmed) {
            submitStatusForm(url, status, result.value || '');
        }
    });
}

function submitStatusForm(url, status, reason) {
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
    method.value = 'PATCH';
    form.appendChild(method);

    const statusInput = document.createElement('input');
    statusInput.name = 'status';
    statusInput.value = status;
    form.appendChild(statusInput);

    if (reason) {
        const reasonInput = document.createElement('input');
        reasonInput.name = 'reason';
        reasonInput.value = reason;
        form.appendChild(reasonInput);
    }

    document.body.appendChild(form);
    form.submit();
}

function deleteOrganization(url) {
    Swal.fire({
        title: 'Delete organization?',
        text: 'This action cannot be undone. The landlord account and all data will be removed.',
        icon: 'error',
        showCancelButton: true,
        confirmButtonText: 'Delete',
        confirmButtonColor: '#dc2626',
        cancelButtonText: 'Cancel',
        customClass: {
            popup: 'rounded-2xl',
            confirmButton: 'rounded-lg px-4 py-2 text-sm font-semibold',
            cancelButton: 'rounded-lg px-4 py-2 text-sm font-semibold',
        }
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
