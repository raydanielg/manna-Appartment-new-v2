@extends('layouts.admin')

@section('title', 'KYC Reviews - Manna Apartment')
@section('page_title', 'KYC Reviews')

@section('content')
<div class="space-y-6">
    {{-- Stats Cards --}}
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div class="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm flex items-center gap-4">
            <div class="w-12 h-12 bg-amber-50 rounded-xl flex items-center justify-center text-amber-600">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </div>
            <div>
                <p class="text-xs font-bold text-gray-400 uppercase tracking-wider">Pending Review</p>
                <h4 class="text-2xl font-black text-gray-900">{{ $documents->where('status', 'pending')->count() }}</h4>
            </div>
        </div>
        <div class="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm flex items-center gap-4">
            <div class="w-12 h-12 bg-emerald-50 rounded-xl flex items-center justify-center text-emerald-600">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </div>
            <div>
                <p class="text-xs font-bold text-gray-400 uppercase tracking-wider">Approved</p>
                <h4 class="text-2xl font-black text-gray-900">{{ $documents->where('status', 'approved')->count() }}</h4>
            </div>
        </div>
        <div class="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm flex items-center gap-4">
            <div class="w-12 h-12 bg-red-50 rounded-xl flex items-center justify-center text-red-600">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </div>
            <div>
                <p class="text-xs font-bold text-gray-400 uppercase tracking-wider">Rejected</p>
                <h4 class="text-2xl font-black text-gray-900">{{ $documents->where('status', 'rejected')->count() }}</h4>
            </div>
        </div>
    </div>

    {{-- Documents Table --}}
    <div class="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        <div class="px-6 py-5 border-b border-gray-50 flex items-center justify-between">
            <h3 class="font-black text-gray-900 tracking-tight">KYC Submissions</h3>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full">
                <thead>
                    <tr class="text-left text-[11px] font-black text-gray-400 uppercase tracking-widest bg-gray-50/50">
                        <th class="px-6 py-4">Organization</th>
                        <th class="px-6 py-4">ID Details</th>
                        <th class="px-6 py-4">Status</th>
                        <th class="px-6 py-4">Submitted At</th>
                        <th class="px-6 py-4 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-50 text-sm">
                    @forelse($documents as $doc)
                    <tr class="hover:bg-blue-50/30 transition-colors group">
                        <td class="px-6 py-4">
                            <div class="flex items-center gap-3">
                                <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center text-blue-600 font-bold">
                                    {{ strtoupper(substr($doc->organization->business_name ?? '?', 0, 1)) }}
                                </div>
                                <div>
                                    <p class="font-bold text-gray-900">{{ $doc->organization->business_name ?? 'Unknown' }}</p>
                                    <p class="text-xs text-gray-500 font-medium">{{ $doc->organization->owner->phone ?? 'No Phone' }}</p>
                                </div>
                            </div>
                        </td>
                        <td class="px-6 py-4">
                            <div class="inline-flex items-center px-2 py-1 bg-gray-100 rounded text-xs font-black text-gray-600 uppercase tracking-tighter">
                                {{ $doc->id_number }}
                            </div>
                        </td>
                        <td class="px-6 py-4">
                            @if($doc->status === 'approved')
                                <span class="inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-wider bg-emerald-100 text-emerald-700">Approved</span>
                            @elseif($doc->status === 'pending')
                                <span class="inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-wider bg-amber-100 text-amber-700">Pending</span>
                            @else
                                <span class="inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-wider bg-red-100 text-red-700">Rejected</span>
                            @endif
                        </td>
                        <td class="px-6 py-4 text-xs font-bold text-gray-500">
                            {{ $doc->created_at->format('M d, Y') }}
                            <span class="block text-[10px] text-gray-300">{{ $doc->created_at->diffForHumans() }}</span>
                        </td>
                        <td class="px-6 py-4 text-right">
                            <div class="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                <button onclick="openKycModal({{ json_encode($doc) }})" class="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors" title="View Documents">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                                </button>
                                @if($doc->status === 'pending')
                                <button onclick="reviewKyc('{{ route('admin.kyc.review', $doc->id) }}', 'approved')" class="p-2 text-emerald-600 hover:bg-emerald-50 rounded-lg transition-colors" title="Approve">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                                </button>
                                <button onclick="reviewKyc('{{ route('admin.kyc.review', $doc->id) }}', 'rejected')" class="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors" title="Reject">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
                                </button>
                                @endif
                            </div>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="5" class="px-6 py-12 text-center">
                            <div class="flex flex-col items-center gap-3">
                                <div class="w-16 h-16 bg-gray-50 rounded-full flex items-center justify-center text-gray-200">
                                    <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
                                </div>
                                <p class="text-sm font-black text-gray-300 uppercase tracking-widest">No documents found</p>
                            </div>
                        </td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($documents->hasPages())
        <div class="px-6 py-4 bg-gray-50/50 border-t border-gray-100">
            {{ $documents->links() }}
        </div>
        @endif
    </div>
</div>

{{-- Document Preview Modal --}}
<div id="kycModal" class="fixed inset-0 z-[100] hidden items-center justify-center p-4 bg-gray-900/60 backdrop-blur-md">
    <div class="bg-white rounded-[2.5rem] shadow-2xl max-w-5xl w-full max-h-[90vh] overflow-hidden flex flex-col" style="animation: scaleIn 0.3s cubic-bezier(0.16, 1, 0.3, 1) both;">
        <div class="px-8 py-6 border-b border-gray-100 flex items-center justify-between">
            <div>
                <h3 class="text-xl font-black text-gray-900 tracking-tight">Document Verification</h3>
                <p id="modal-org-name" class="text-sm text-blue-600 font-bold uppercase tracking-wider"></p>
            </div>
            <button onclick="closeKycModal()" class="w-10 h-10 flex items-center justify-center rounded-xl bg-gray-50 text-gray-400 hover:text-gray-900 hover:bg-gray-100 transition-all">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M6 18L18 6M6 6l12 12"/></svg>
            </button>
        </div>
        
        <div class="flex-1 overflow-y-auto p-8 custom-scrollbar">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-8" id="kycModalContent">
                {{-- Dynamic content --}}
            </div>
        </div>

        <div class="px-8 py-6 bg-gray-50 border-t border-gray-100 flex items-center justify-between gap-4">
            <div class="flex items-center gap-2">
                <span class="text-xs font-black text-gray-400 uppercase tracking-widest">ID Number:</span>
                <span id="modal-id-number" class="text-sm font-black text-gray-900 bg-white px-3 py-1 rounded-lg border border-gray-200"></span>
            </div>
            <div class="flex items-center gap-3" id="modal-actions">
                {{-- Action buttons will be added here --}}
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
function reviewKyc(url, status) {
    const title = status === 'approved' ? 'Approve Verification?' : 'Reject Verification?';
    const confirmText = status === 'approved' ? 'Yes, Approve' : 'Yes, Reject';
    const confirmColor = status === 'approved' ? '#2563eb' : '#dc2626';

    Swal.fire({
        title: title,
        text: status === 'rejected' ? 'Please provide a reason for rejection.' : 'The landlord will be notified and granted access.',
        input: status === 'rejected' ? 'textarea' : null,
        inputLabel: status === 'rejected' ? 'Rejection Reason' : null,
        inputPlaceholder: 'Type reason here...',
        showCancelButton: true,
        confirmButtonText: confirmText,
        confirmButtonColor: confirmColor,
        cancelButtonText: 'Cancel',
        cancelButtonColor: '#f3f4f6',
        customClass: {
            popup: 'rounded-[2rem]',
            confirmButton: 'rounded-xl font-bold px-6 py-3',
            cancelButton: 'rounded-xl font-bold px-6 py-3 text-gray-600',
        },
        preConfirm: (notes) => {
            if (status === 'rejected' && !notes) {
                Swal.showValidationMessage('Rejection reason is required');
                return false;
            }
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
    const orgName = document.getElementById('modal-org-name');
    const idNum = document.getElementById('modal-id-number');
    const actions = document.getElementById('modal-actions');
    const baseUrl = '{{ url('storage') }}';

    orgName.textContent = doc.organization.business_name;
    idNum.textContent = doc.id_number;

    const fields = [
        { label: 'Front of ID', path: doc.id_photo_front, icon: '🪪' },
        { label: 'Back of ID', path: doc.id_photo_back, icon: '🪪' },
        { label: 'Owner Selfie', path: doc.selfie_photo, icon: '🤳' },
        { label: 'Ownership Proof', path: doc.ownership_proof, icon: '📄' },
    ];

    content.innerHTML = fields.map(f => {
        if (!f.path) return '';
        const isPdf = f.path.toLowerCase().endsWith('.pdf');
        return `
            <div class="space-y-3">
                <div class="flex items-center gap-2">
                    <span class="text-xl">${f.icon}</span>
                    <h5 class="text-xs font-black text-gray-400 uppercase tracking-widest">${f.label}</h5>
                </div>
                ${isPdf ? `
                    <div class="aspect-video bg-gray-50 rounded-3xl border-2 border-dashed border-gray-200 flex flex-col items-center justify-center gap-4">
                        <svg class="w-12 h-12 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"/></svg>
                        <a href="${baseUrl}/${f.path}" target="_blank" class="px-6 py-2 bg-white border border-gray-200 rounded-xl text-xs font-black text-blue-600 hover:shadow-md transition-all uppercase tracking-tighter">View PDF Document</a>
                    </div>
                ` : `
                    <a href="${baseUrl}/${f.path}" target="_blank" class="block group relative aspect-video rounded-3xl overflow-hidden border-2 border-gray-100 shadow-sm hover:shadow-xl transition-all duration-500">
                        <img src="${baseUrl}/${f.path}" alt="${f.label}" class="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110">
                        <div class="absolute inset-0 bg-blue-900/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                            <div class="w-12 h-12 bg-white rounded-full flex items-center justify-center text-blue-600 shadow-xl">
                                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM10 7v3m0 0v3m0-3h3m-3 0H7"/></svg>
                            </div>
                        </div>
                    </a>
                `}
            </div>
        `;
    }).join('');

    if (doc.status === 'pending') {
        const reviewUrl = '{{ route('admin.kyc.review', ':id') }}'.replace(':id', doc.id);
        actions.innerHTML = `
            <button onclick="reviewKyc('${reviewUrl}', 'rejected')" class="px-6 py-3 bg-white border border-red-100 text-red-600 rounded-2xl text-sm font-black uppercase tracking-tight hover:bg-red-50 transition-all">Reject Submission</button>
            <button onclick="reviewKyc('${reviewUrl}', 'approved')" class="px-8 py-3 bg-blue-600 text-white rounded-2xl text-sm font-black uppercase tracking-tight shadow-lg shadow-blue-200 hover:bg-blue-700 hover:-translate-y-0.5 transition-all">Approve Documents</button>
        `;
    } else {
        actions.innerHTML = '<span class="text-xs font-black text-gray-400 uppercase tracking-widest italic">Decision already recorded</span>';
    }

    modal.classList.remove('hidden');
    modal.classList.add('flex');
    document.body.style.overflow = 'hidden';
}

function closeKycModal() {
    const modal = document.getElementById('kycModal');
    modal.classList.add('hidden');
    modal.classList.remove('flex');
    document.body.style.overflow = 'auto';
}
</script>
@endpush

