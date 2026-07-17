@extends('layouts.admin')

@section('title', 'Subscription Plans - Manna Apartment')
@section('page_title', 'Subscription Plans')

@section('content')
@if(session('success'))
<div class="mb-4 px-4 py-3 rounded-lg bg-emerald-50 border border-emerald-200 text-emerald-700 text-xs font-medium">
    {{ session('success') }}
</div>
@endif

<div class="flex items-center justify-between mb-5">
    <p class="text-xs text-gray-500">{{ $plans->count() }} plans total</p>
    <button type="button" onclick="addPlan()" class="inline-flex items-center gap-2 px-4 py-2 rounded-lg bg-emerald-600 text-white text-xs font-semibold hover:bg-emerald-700 transition-colors shadow-sm">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4"/></svg>
        Add Plan
    </button>
</div>

<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
    @forelse($plans as $plan)
    <div class="bg-white rounded-xl border overflow-hidden hover:shadow-lg transition-shadow flex flex-col">
        {{-- Card Header --}}
        <div class="px-5 py-4 border-b {{ $plan->status === 'active' ? 'bg-emerald-50/60' : 'bg-gray-50' }}">
            <div class="flex items-start justify-between">
                <div>
                    <h4 class="text-sm font-bold text-gray-900">{{ $plan->name }}</h4>
                    <span class="inline-flex items-center gap-1 mt-1">
                        <span class="w-1.5 h-1.5 rounded-full {{ $plan->status === 'active' ? 'bg-emerald-500' : 'bg-gray-400' }}"></span>
                        <span class="text-[10px] font-medium {{ $plan->status === 'active' ? 'text-emerald-600' : 'text-gray-400' }}">{{ ucfirst($plan->status) }}</span>
                    </span>
                </div>
                <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-semibold bg-white border {{ $plan->billing_cycle === 'trial' ? 'border-amber-200 text-amber-700' : 'border-blue-200 text-blue-700' }}">{{ ucfirst($plan->billing_cycle) }}</span>
            </div>
        </div>

        {{-- Price --}}
        <div class="px-5 py-4">
            <p class="text-3xl font-bold text-gray-900">TZS {{ number_format($plan->price) }}</p>
            <p class="text-[11px] text-gray-400 mt-0.5">{{ $plan->billing_cycle === 'trial' ? 'for 3 days' : 'per ' . $plan->billing_cycle }}</p>
        </div>

        {{-- Limits --}}
        <div class="px-5 pb-4 space-y-2.5 flex-1">
            <div class="flex items-center justify-between py-1.5 border-b border-gray-50">
                <div class="flex items-center gap-2">
                    <svg class="w-3.5 h-3.5 text-gray-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/></svg>
                    <span class="text-[11px] text-gray-500">Properties</span>
                </div>
                <span class="text-xs font-semibold text-gray-700">{{ $plan->property_limit ?: 'Unlimited' }}</span>
            </div>
            <div class="flex items-center justify-between py-1.5 border-b border-gray-50">
                <div class="flex items-center gap-2">
                    <svg class="w-3.5 h-3.5 text-gray-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"/></svg>
                    <span class="text-[11px] text-gray-500">Units</span>
                </div>
                <span class="text-xs font-semibold text-gray-700">{{ $plan->unit_limit ?: 'Unlimited' }}</span>
            </div>
            <div class="flex items-center justify-between py-1.5 border-b border-gray-50">
                <div class="flex items-center gap-2">
                    <svg class="w-3.5 h-3.5 text-gray-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 3v-3z"/></svg>
                    <span class="text-[11px] text-gray-500">SMS Included</span>
                </div>
                <span class="text-xs font-semibold text-gray-700">{{ number_format($plan->sms_included) }}</span>
            </div>

            @if(!empty($plan->features_json))
            <div class="pt-2">
                <p class="text-[10px] font-semibold text-gray-400 uppercase tracking-wide mb-1.5">Features</p>
                <ul class="space-y-1">
                    @foreach((array)$plan->features_json as $feature)
                    <li class="flex items-start gap-1.5 text-[11px] text-gray-600">
                        <svg class="w-3 h-3 text-emerald-500 mt-0.5 shrink-0" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/></svg>
                        {{ $feature }}
                    </li>
                    @endforeach
                </ul>
            </div>
            @endif
        </div>

        {{-- Actions --}}
        <div class="px-5 py-3 border-t bg-gray-50/50 flex items-center gap-2">
            <button type="button" onclick="editPlan({{ json_encode($plan) }})" class="flex-1 px-3 py-1.5 rounded-lg bg-white border border-gray-200 text-gray-600 hover:bg-gray-50 text-[11px] font-semibold transition-colors">Edit</button>
            <button type="button" onclick="deletePlan('{{ $plan->id }}', '{{ $plan->name }}')" class="px-3 py-1.5 rounded-lg bg-red-50 border border-red-100 text-red-600 hover:bg-red-100 text-[11px] font-semibold transition-colors">Delete</button>
        </div>
    </div>
    @empty
    <div class="col-span-full bg-white rounded-xl border p-12 text-center">
        <svg class="w-12 h-12 mx-auto text-gray-300 mb-3" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
        <p class="text-sm text-gray-400 mb-1">No plans yet</p>
        <p class="text-xs text-gray-400 mb-4">Create your first subscription plan</p>
        <button type="button" onclick="addPlan()" class="inline-flex items-center gap-2 px-4 py-2 rounded-lg bg-emerald-600 text-white text-xs font-semibold hover:bg-emerald-700 transition-colors">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4"/></svg>
            Add Plan
        </button>
    </div>
    @endforelse
</div>
@endsection

@push('scripts')
<script>
function addPlan() {
    Swal.fire({
        title: 'Add New Plan',
        html: `
            <form id="planAddForm" method="POST" action="{{ route('admin.plans.store') }}" class="text-left space-y-3">
                <input type="hidden" name="_token" value="${document.querySelector('meta[name="csrf-token"]').content}">
                <div>
                    <label class="block text-xs font-medium text-gray-700 mb-1">Plan Name</label>
                    <input type="text" name="name" placeholder="e.g. Starter, Pro, Enterprise" class="w-full text-sm border rounded-lg px-3 py-2 outline-none focus:border-emerald-500" required>
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-medium text-gray-700 mb-1">Price (TZS)</label>
                        <input type="number" name="price" placeholder="0" class="w-full text-sm border rounded-lg px-3 py-2 outline-none focus:border-emerald-500" required>
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-gray-700 mb-1">Billing Cycle</label>
                        <select name="billing_cycle" class="w-full text-sm border rounded-lg px-3 py-2 outline-none focus:border-emerald-500">
                            <option value="monthly">Monthly</option>
                            <option value="yearly">Yearly</option>
                            <option value="trial">Trial</option>
                        </select>
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-medium text-gray-700 mb-1">Property Limit</label>
                        <input type="number" name="property_limit" value="0" class="w-full text-sm border rounded-lg px-3 py-2 outline-none focus:border-emerald-500" required>
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-gray-700 mb-1">Unit Limit</label>
                        <input type="number" name="unit_limit" value="0" class="w-full text-sm border rounded-lg px-3 py-2 outline-none focus:border-emerald-500" required>
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-medium text-gray-700 mb-1">SMS Included</label>
                        <input type="number" name="sms_included" value="0" class="w-full text-sm border rounded-lg px-3 py-2 outline-none focus:border-emerald-500" required>
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-gray-700 mb-1">Status</label>
                        <select name="status" class="w-full text-sm border rounded-lg px-3 py-2 outline-none focus:border-emerald-500">
                            <option value="active">Active</option>
                            <option value="inactive">Inactive</option>
                        </select>
                    </div>
                </div>
                <div>
                    <label class="block text-xs font-medium text-gray-700 mb-1">Features (comma separated)</label>
                    <input type="text" name="features_json" placeholder="e.g. Property management, SMS alerts, Analytics" class="w-full text-sm border rounded-lg px-3 py-2 outline-none focus:border-emerald-500">
                </div>
            </form>
        `,
        showCancelButton: true,
        confirmButtonText: 'Create Plan',
        confirmButtonColor: '#024938',
        cancelButtonText: 'Cancel',
        preConfirm: () => {
            document.getElementById('planAddForm').submit();
        }
    });
}

function editPlan(plan) {
    const features = (plan.features_json || []).join(', ');
    Swal.fire({
        title: 'Edit Plan',
        html: `
            <form id="planEditForm" method="POST" action="{{ url('admin/plans') }}/${plan.id}" class="text-left space-y-3">
                <input type="hidden" name="_token" value="${document.querySelector('meta[name="csrf-token"]').content}">
                <input type="hidden" name="_method" value="PUT">
                <div>
                    <label class="block text-xs font-medium text-gray-700 mb-1">Plan Name</label>
                    <input type="text" name="name" value="${plan.name}" class="w-full text-sm border rounded-lg px-3 py-2 outline-none focus:border-emerald-500">
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-medium text-gray-700 mb-1">Price (TZS)</label>
                        <input type="number" name="price" value="${plan.price}" class="w-full text-sm border rounded-lg px-3 py-2 outline-none focus:border-emerald-500">
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-gray-700 mb-1">Billing Cycle</label>
                        <select name="billing_cycle" class="w-full text-sm border rounded-lg px-3 py-2 outline-none focus:border-emerald-500">
                            <option value="monthly" ${plan.billing_cycle === 'monthly' ? 'selected' : ''}>Monthly</option>
                            <option value="yearly" ${plan.billing_cycle === 'yearly' ? 'selected' : ''}>Yearly</option>
                            <option value="trial" ${plan.billing_cycle === 'trial' ? 'selected' : ''}>Trial</option>
                        </select>
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-medium text-gray-700 mb-1">Property Limit</label>
                        <input type="number" name="property_limit" value="${plan.property_limit}" class="w-full text-sm border rounded-lg px-3 py-2 outline-none focus:border-emerald-500">
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-gray-700 mb-1">Unit Limit</label>
                        <input type="number" name="unit_limit" value="${plan.unit_limit}" class="w-full text-sm border rounded-lg px-3 py-2 outline-none focus:border-emerald-500">
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-medium text-gray-700 mb-1">SMS Included</label>
                        <input type="number" name="sms_included" value="${plan.sms_included}" class="w-full text-sm border rounded-lg px-3 py-2 outline-none focus:border-emerald-500">
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-gray-700 mb-1">Status</label>
                        <select name="status" class="w-full text-sm border rounded-lg px-3 py-2 outline-none focus:border-emerald-500">
                            <option value="active" ${plan.status === 'active' ? 'selected' : ''}>Active</option>
                            <option value="inactive" ${plan.status === 'inactive' ? 'selected' : ''}>Inactive</option>
                        </select>
                    </div>
                </div>
                <div>
                    <label class="block text-xs font-medium text-gray-700 mb-1">Features (comma separated)</label>
                    <input type="text" name="features_json" value="${features}" class="w-full text-sm border rounded-lg px-3 py-2 outline-none focus:border-emerald-500">
                </div>
            </form>
        `,
        showCancelButton: true,
        confirmButtonText: 'Save Changes',
        confirmButtonColor: '#024938',
        cancelButtonText: 'Cancel',
        preConfirm: () => {
            document.getElementById('planEditForm').submit();
        }
    });
}

function deletePlan(id, name) {
    Swal.fire({
        title: 'Delete Plan?',
        text: `Are you sure you want to delete "${name}"? This action cannot be undone.`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonText: 'Delete',
        confirmButtonColor: '#dc2626',
        cancelButtonText: 'Cancel',
        preConfirm: () => {
            fetch(`{{ url('admin/plans') }}/${id}`, {
                method: 'DELETE',
                headers: {
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content,
                    'Accept': 'application/json',
                },
            }).then(() => {
                window.location.reload();
            });
        }
    });
}
</script>
@endpush
