@extends('layouts.admin')

@section('title', 'KYC Reviews - Manna Apartment')
@section('page_title', 'KYC Reviews')

@section('content')
<div class="bg-white rounded-xl border overflow-hidden">
    <div class="px-5 py-4 border-b flex items-center justify-between">
        <h3 class="text-sm font-semibold text-gray-900">KYC Documents</h3>
        <div class="flex items-center gap-2">
            <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium bg-amber-50 text-amber-700 border border-amber-100">Pending</span>
            <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium bg-emerald-50 text-emerald-700 border border-emerald-100">Approved</span>
            <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium bg-red-50 text-red-700 border border-red-100">Rejected</span>
        </div>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead><tr class="text-left text-xs text-gray-500 bg-gray-50/50">
                <th class="px-5 py-2.5 font-medium">Organization</th>
                <th class="px-5 py-2.5 font-medium">ID Number</th>
                <th class="px-5 py-2.5 font-medium">Status</th>
                <th class="px-5 py-2.5 font-medium">Reviewed By</th>
                <th class="px-5 py-2.5 font-medium">Submitted</th>
                <th class="px-5 py-2.5 font-medium">Actions</th>
            </tr></thead>
            <tbody>
                @forelse($documents as $doc)
                <tr class="border-t border-gray-100 hover:bg-gray-50/50 transition-colors">
                    <td class="px-5 py-2.5 text-xs text-gray-900">{{ $doc->organization->business_name ?? '-' }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-700">{{ $doc->id_number }}</td>
                    <td class="px-5 py-2.5">
                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium
                            {{ $doc->status === 'approved' ? 'bg-emerald-50 text-emerald-700 border border-emerald-100' : ($doc->status === 'pending' ? 'bg-amber-50 text-amber-700 border border-amber-100' : 'bg-red-50 text-red-700 border border-red-100') }}">{{ ucfirst($doc->status) }}</span>
                    </td>
                    <td class="px-5 py-2.5 text-xs text-gray-500">{{ $doc->reviewer->full_name ?? '-' }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-500">{{ $doc->created_at->format('Y-m-d') }}</td>
                    <td class="px-5 py-2.5">
                        <div class="flex items-center gap-2">
                            <button type="button" onclick="openKycModal({{ json_encode($doc) }})" class="px-2 py-1 rounded-md bg-gray-100 text-gray-600 hover:bg-gray-200 text-[10px] font-medium">View</button>
                            @if($doc->status !== 'approved')
                            <button type="button" onclick="reviewKyc('{{ route('admin.kyc.review', $doc->id) }}', 'approved')" class="px-2 py-1 rounded-md bg-emerald-600 text-white hover:bg-emerald-700 text-[10px] font-medium">Approve</button>
                            @endif
                            @if($doc->status !== 'rejected')
                            <button type="button" onclick="reviewKyc('{{ route('admin.kyc.review', $doc->id) }}', 'rejected')" class="px-2 py-1 rounded-md bg-red-600 text-white hover:bg-red-700 text-[10px] font-medium">Reject</button>
                            @endif
                        </div>
                    </td>
                </tr>
                @empty
                <tr><td colspan="6" class="px-5 py-8 text-center text-gray-400 text-xs">No KYC documents</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
    <div class="px-5 py-3 border-t text-xs">
        {{ $documents->links() }}
    </div>
</div>

<div id="kycModal" class="fixed inset-0 bg-black/50 z-50 hidden items-center justify-center p-4">
    <div class="bg-white rounded-xl shadow-xl max-w-3xl w-full max-h-[90vh] overflow-y-auto">
        <div class="px-5 py-4 border-b flex items-center justify-between">
            <h3 class="text-sm font-semibold text-gray-900">KYC Document Preview</h3>
            <button onclick="closeKycModal()" class="text-gray-400 hover:text-gray-600">&times;</button>
        </div>
        <div class="p-5 grid grid-cols-2 gap-4" id="kycModalContent">
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
function reviewKyc(url, status) {
    const title = status === 'approved' ? 'Approve KYC?' : 'Reject KYC?';
    const confirmText = status === 'approved' ? 'Approve' : 'Reject';
    const confirmColor = status === 'approved' ? '#059669' : '#dc2626';

    Swal.fire({
        title: title,
        input: 'textarea',
        inputLabel: 'Review notes (optional)',
        inputPlaceholder: 'Add any notes about this decision...',
        showCancelButton: true,
        confirmButtonText: confirmText,
        confirmButtonColor: confirmColor,
        cancelButtonText: 'Cancel',
        preConfirm: (notes) => {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = url;
            form.style.display = 'none';

            const csrf = document.createElement('input');
            csrf.name = '_token';
            csrf.value = document.querySelector('meta[name="csrf-token"]').content;
            form.appendChild(csrf);

            const statusInput = document.createElement('input');
            statusInput.name = 'status';
            statusInput.value = status;
            form.appendChild(statusInput);

            if (notes) {
                const notesInput = document.createElement('input');
                notesInput.name = 'review_notes';
                notesInput.value = notes;
                form.appendChild(notesInput);
            }

            document.body.appendChild(form);
            form.submit();
        }
    });
}

function openKycModal(doc) {
    const modal = document.getElementById('kycModal');
    const content = document.getElementById('kycModalContent');
    const baseUrl = '{{ url('storage') }}';

    const fields = [
        { label: 'ID Front', path: doc.id_photo_front },
        { label: 'ID Back', path: doc.id_photo_back },
        { label: 'Selfie', path: doc.selfie_photo },
        { label: 'Ownership Proof', path: doc.ownership_proof },
    ];

    content.innerHTML = fields.map(f => {
        if (!f.path) return '';
        return `
            <div class="col-span-2 sm:col-span-1">
                <p class="text-xs font-medium text-gray-700 mb-2">${f.label}</p>
                <a href="${baseUrl}/${f.path}" target="_blank" class="block border rounded-lg overflow-hidden hover:opacity-90">
                    <img src="${baseUrl}/${f.path}" alt="${f.label}" class="w-full h-48 object-cover">
                </a>
            </div>
        `;
    }).join('');

    modal.classList.remove('hidden');
    modal.classList.add('flex');
}

function closeKycModal() {
    const modal = document.getElementById('kycModal');
    modal.classList.add('hidden');
    modal.classList.remove('flex');
}
</script>
@endpush
