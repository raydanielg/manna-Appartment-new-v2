@extends('layouts.admin')

@section('title', 'KYC Reviews - Manna Apartment')
@section('page_title', 'KYC Reviews')

@section('content')
<div class="bg-white rounded-lg border shadow-sm overflow-hidden">
    <div class="px-6 py-4 border-b flex items-center justify-between">
        <h3 class="font-bold text-gray-800">KYC Submissions</h3>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead>
                <tr class="text-left text-xs font-bold text-gray-500 bg-gray-50 uppercase tracking-wider">
                    <th class="px-6 py-3">Organization</th>
                    <th class="px-6 py-3">ID Number</th>
                    <th class="px-6 py-3">Status</th>
                    <th class="px-6 py-3">Submitted</th>
                    <th class="px-6 py-3 text-right">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
                @forelse($documents as $doc)
                <tr class="hover:bg-gray-50 transition-colors">
                    <td class="px-6 py-4">
                        <span class="font-bold text-gray-900">{{ $doc->organization->business_name ?? 'N/A' }}</span>
                        <div class="text-xs text-gray-500">{{ $doc->organization->owner->phone ?? '' }}</div>
                    </td>
                    <td class="px-6 py-4 text-gray-700 font-mono">{{ $doc->id_number }}</td>
                    <td class="px-6 py-4">
                        <span class="inline-flex px-2 py-1 text-[10px] font-bold rounded-md uppercase tracking-wide
                            {{ $doc->status === 'approved' ? 'bg-green-100 text-green-700' : ($doc->status === 'pending' ? 'bg-yellow-100 text-yellow-700' : 'bg-red-100 text-red-700') }}">
                            {{ $doc->status }}
                        </span>
                    </td>
                    <td class="px-6 py-4 text-gray-500 text-xs">{{ $doc->created_at->format('d M Y, H:i') }}</td>
                    <td class="px-6 py-4 text-right">
                        <div class="flex items-center justify-end gap-2">
                            <button onclick="openKycModal({{ json_encode($doc->load('organization')) }})" class="text-blue-600 hover:text-blue-800 font-bold text-xs uppercase underline">View Docs</button>
                            @if($doc->status === 'pending')
                            <button onclick="reviewKyc('{{ route('admin.kyc.review', $doc->id) }}', 'approved')" class="bg-blue-600 text-white px-3 py-1 rounded text-xs font-bold hover:bg-blue-700">Approve</button>
                            <button onclick="reviewKyc('{{ route('admin.kyc.review', $doc->id) }}', 'rejected')" class="bg-red-600 text-white px-3 py-1 rounded text-xs font-bold hover:bg-red-700">Reject</button>
                            @endif
                        </div>
                    </td>
                </tr>
                @empty
                <tr><td colspan="5" class="px-6 py-10 text-center text-gray-400 italic">No documents found</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
    @if($documents->hasPages())
    <div class="px-6 py-4 border-t bg-gray-50">
        {{ $documents->links() }}
    </div>
    @endif
</div>

{{-- Simple Preview Modal --}}
<div id="kycModal" class="fixed inset-0 z-50 hidden items-center justify-center p-4 bg-black/60">
    <div class="bg-white rounded-xl shadow-xl max-w-4xl w-full max-h-[90vh] overflow-hidden flex flex-col">
        <div class="px-6 py-4 border-b flex items-center justify-between">
            <h3 class="font-bold text-gray-900">Document Review: <span id="modal-org-name" class="text-blue-600"></span></h3>
            <button onclick="closeKycModal()" class="text-gray-400 hover:text-gray-600 text-2xl">&times;</button>
        </div>
        
        <div class="flex-1 overflow-y-auto p-6">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6" id="kycModalContent">
            </div>
        </div>

        <div class="px-6 py-4 border-t bg-gray-50 flex items-center justify-between">
            <span class="text-sm font-bold text-gray-700 uppercase">ID: <span id="modal-id-number"></span></span>
            <div id="modal-actions" class="flex gap-2">
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
function reviewKyc(url, status) {
    const title = status === 'approved' ? 'Approve documents?' : 'Reject documents?';
    Swal.fire({
        title: title,
        text: status === 'rejected' ? 'Enter reason for rejection:' : 'Grant full access to the landlord.',
        input: status === 'rejected' ? 'textarea' : null,
        showCancelButton: true,
        confirmButtonText: 'Confirm',
        confirmButtonColor: status === 'approved' ? '#2563eb' : '#dc2626',
        preConfirm: (notes) => {
            if (status === 'rejected' && !notes) {
                Swal.showValidationMessage('Reason is required');
                return false;
            }
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = url;
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
    const orgName = document.getElementById('modal-org-name');
    const idNum = document.getElementById('modal-id-number');
    const actions = document.getElementById('modal-actions');
    const baseUrl = '{{ url('storage') }}';

    orgName.textContent = doc.organization.business_name;
    idNum.textContent = doc.id_number;

    const fields = [
        { label: 'Front of ID', path: doc.id_photo_front },
        { label: 'Back of ID', path: doc.id_photo_back },
        { label: 'Selfie', path: doc.selfie_photo },
        { label: 'Ownership Proof', path: doc.ownership_proof },
    ];

    content.innerHTML = fields.map(f => {
        if (!f.path) return '';
        const isPdf = f.path.toLowerCase().endsWith('.pdf');
        return `
            <div class="border rounded-lg p-3 bg-gray-50">
                <div class="text-xs font-bold text-gray-500 uppercase mb-2">${f.label}</div>
                ${isPdf ? `
                    <div class="h-40 flex items-center justify-center border-2 border-dashed rounded bg-white">
                        <a href="${baseUrl}/${f.path}" target="_blank" class="text-blue-600 underline font-bold">View PDF File</a>
                    </div>
                ` : `
                    <a href="${baseUrl}/${f.path}" target="_blank" class="block border rounded overflow-hidden">
                        <img src="${baseUrl}/${f.path}" alt="${f.label}" class="w-full h-40 object-cover hover:opacity-90">
                    </a>
                `}
            </div>
        `;
    }).join('');

    if (doc.status === 'pending') {
        const reviewUrl = '{{ route('admin.kyc.review', ':id') }}'.replace(':id', doc.id);
        actions.innerHTML = `
            <button onclick="reviewKyc('${reviewUrl}', 'rejected')" class="text-red-600 font-bold px-4 py-2 hover:bg-red-50 rounded">Reject</button>
            <button onclick="reviewKyc('${reviewUrl}', 'approved')" class="bg-blue-600 text-white font-bold px-6 py-2 rounded hover:bg-blue-700 shadow-sm">Approve</button>
        `;
    } else {
        actions.innerHTML = '<span class="text-xs font-bold text-gray-400 uppercase tracking-widest italic">Review Completed</span>';
    }

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

