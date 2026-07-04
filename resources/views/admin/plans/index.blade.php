@extends('layouts.admin')

@section('title', 'Subscription Plans - Manna Apartment')
@section('page_title', 'Subscription Plans')

@section('content')
<div class="bg-white rounded-xl border overflow-hidden">
    <div class="px-5 py-4 border-b flex items-center justify-between">
        <h3 class="text-sm font-semibold text-gray-900">Plans</h3>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead><tr class="text-left text-xs text-gray-500 bg-gray-50/50">
                <th class="px-5 py-2.5 font-medium">Name</th>
                <th class="px-5 py-2.5 font-medium">Price</th>
                <th class="px-5 py-2.5 font-medium">Cycle</th>
                <th class="px-5 py-2.5 font-medium">Property Limit</th>
                <th class="px-5 py-2.5 font-medium">Unit Limit</th>
                <th class="px-5 py-2.5 font-medium">SMS Included</th>
                <th class="px-5 py-2.5 font-medium">Status</th>
                <th class="px-5 py-2.5 font-medium">Actions</th>
            </tr></thead>
            <tbody>
                @forelse($plans as $plan)
                <tr class="border-t border-gray-100 hover:bg-gray-50/50 transition-colors">
                    <td class="px-5 py-2.5 text-xs font-medium text-gray-900">{{ $plan->name }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-700">TZS {{ number_format($plan->price) }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-700">{{ ucfirst($plan->billing_cycle) }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-700">{{ $plan->property_limit ?: 'Unlimited' }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-700">{{ $plan->unit_limit ?: 'Unlimited' }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-700">{{ number_format($plan->sms_included) }}</td>
                    <td class="px-5 py-2.5">
                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium {{ $plan->status === 'active' ? 'bg-emerald-50 text-emerald-700 border border-emerald-100' : 'bg-gray-100 text-gray-700 border border-gray-200' }}">{{ ucfirst($plan->status) }}</span>
                    </td>
                    <td class="px-5 py-2.5">
                        <div class="flex items-center gap-2">
                            <button type="button" onclick="viewPlan({{ json_encode($plan) }})" class="px-2 py-1 rounded-md bg-gray-100 text-gray-600 hover:bg-gray-200 text-[10px] font-medium">View</button>
                            <button type="button" onclick="editPlan({{ json_encode($plan) }})" class="px-2 py-1 rounded-md bg-emerald-600 text-white hover:bg-emerald-700 text-[10px] font-medium">Edit</button>
                        </div>
                    </td>
                </tr>
                @empty
                <tr><td colspan="8" class="px-5 py-8 text-center text-gray-400 text-xs">No plans</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection

@push('scripts')
<script>
function viewPlan(plan) {
    const features = (plan.features_json || []).map(f => `<li class="text-xs text-gray-600 py-1 border-b border-gray-50 last:border-0">${f}</li>`).join('');
    Swal.fire({
        title: plan.name,
        html: `
            <div class="text-left space-y-2">
                <div class="grid grid-cols-2 gap-2 text-xs">
                    <div class="bg-gray-50 p-2 rounded"><span class="text-gray-500">Price</span><p class="font-semibold text-gray-800">TZS ${Number(plan.price).toLocaleString()}</p></div>
                    <div class="bg-gray-50 p-2 rounded"><span class="text-gray-500">Cycle</span><p class="font-semibold text-gray-800">${plan.billing_cycle}</p></div>
                    <div class="bg-gray-50 p-2 rounded"><span class="text-gray-500">Properties</span><p class="font-semibold text-gray-800">${plan.property_limit || 'Unlimited'}</p></div>
                    <div class="bg-gray-50 p-2 rounded"><span class="text-gray-500">Units</span><p class="font-semibold text-gray-800">${plan.unit_limit || 'Unlimited'}</p></div>
                    <div class="bg-gray-50 p-2 rounded"><span class="text-gray-500">SMS</span><p class="font-semibold text-gray-800">${Number(plan.sms_included).toLocaleString()}</p></div>
                    <div class="bg-gray-50 p-2 rounded"><span class="text-gray-500">Status</span><p class="font-semibold text-gray-800">${plan.status}</p></div>
                </div>
                <div>
                    <p class="text-xs font-semibold text-gray-700 mb-1">Features</p>
                    <ul class="bg-gray-50 p-2 rounded max-h-32 overflow-y-auto">${features || '<li class="text-xs text-gray-400 py-1">No features listed</li>'}</ul>
                </div>
            </div>
        `,
        showConfirmButton: false,
        showCloseButton: true,
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
                    <label class="block text-xs font-medium text-gray-700 mb-1">Name</label>
                    <input type="text" name="name" value="${plan.name}" class="w-full text-sm border rounded-lg px-3 py-2 outline-none focus:border-emerald-500">
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-medium text-gray-700 mb-1">Price</label>
                        <input type="number" name="price" value="${plan.price}" class="w-full text-sm border rounded-lg px-3 py-2 outline-none focus:border-emerald-500">
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-gray-700 mb-1">Cycle</label>
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
</script>
@endpush
