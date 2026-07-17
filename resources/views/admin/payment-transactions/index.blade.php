@extends('layouts.admin')

@section('title', 'Payment Transactions - Manna Apartment')
@section('page_title', 'Snippe Payment Transactions')

@push('scripts')
<script>
function viewReceipt(data) {
    const statusColors = {
        completed: '#10b981',
        pending: '#f59e0b',
        failed: '#ef4444',
        expired: '#6b7280',
    };
    const statusColor = statusColors[data.status] || '#6b7280';
    const paidAt = data.paid_at ? new Date(data.paid_at).toLocaleString('en-GB', { day:'2-digit', month:'short', year:'numeric', hour:'2-digit', minute:'2-digit' }) : '—';
    const createdAt = new Date(data.created_at).toLocaleString('en-GB', { day:'2-digit', month:'short', year:'numeric', hour:'2-digit', minute:'2-digit' });

    Swal.fire({
        title: '<span style="font-size:18px;font-weight:800;color:#024938">Payment Receipt</span>',
        html: `
            <div style="text-align:left;font-family:'Nunito',sans-serif;max-width:480px;margin:0 auto">
                <div style="background:#024938;color:#fff;padding:20px;border-radius:8px 8px 0 0;text-align:center">
                    <div style="font-size:16px;font-weight:800;letter-spacing:1px">MANNA APARTMENT</div>
                    <div style="font-size:11px;color:rgba(255,255,255,0.6);margin-top:4px">Snippe Payment Receipt</div>
                    <div style="margin-top:10px;display:inline-block;padding:4px 14px;border-radius:4px;background:${statusColor}22;color:${statusColor};font-size:11px;font-weight:800">${data.status.toUpperCase()}</div>
                </div>
                <div style="border:1px solid #e2e8f0;border-top:none;border-radius:0 0 8px 8px;padding:20px">
                    <div style="display:flex;justify-content:space-between;padding:5px 0">
                        <span style="color:#64748b;font-size:12px">Transaction ID</span>
                        <span style="font-weight:700;font-size:12px">${data.id}</span>
                    </div>
                    <div style="display:flex;justify-content:space-between;padding:5px 0">
                        <span style="color:#64748b;font-size:12px">Provider Reference</span>
                        <span style="font-weight:700;font-size:12px">${data.provider_reference || '—'}</span>
                    </div>
                    <hr style="border:none;border-top:1px solid #e2e8f0;margin:8px 0">
                    <div style="display:flex;justify-content:space-between;padding:5px 0">
                        <span style="color:#64748b;font-size:12px">Organization</span>
                        <span style="font-weight:700;font-size:12px">${data.org}</span>
                    </div>
                    <div style="display:flex;justify-content:space-between;padding:5px 0">
                        <span style="color:#64748b;font-size:12px">User</span>
                        <span style="font-weight:700;font-size:12px">${data.user}</span>
                    </div>
                    <div style="display:flex;justify-content:space-between;padding:5px 0">
                        <span style="color:#64748b;font-size:12px">Type</span>
                        <span style="font-weight:700;font-size:12px;text-transform:uppercase">${data.type}</span>
                    </div>
                    <hr style="border:none;border-top:1px solid #e2e8f0;margin:8px 0">
                    <div style="display:flex;justify-content:space-between;padding:5px 0">
                        <span style="color:#64748b;font-size:12px">Amount</span>
                        <span style="font-weight:700;font-size:12px">${data.currency} ${data.amount}</span>
                    </div>
                    <div style="display:flex;justify-content:space-between;padding:5px 0">
                        <span style="color:#64748b;font-size:12px">Payment Method</span>
                        <span style="font-weight:700;font-size:12px;text-transform:capitalize">${data.method || '—'}</span>
                    </div>
                    <div style="display:flex;justify-content:space-between;padding:5px 0">
                        <span style="color:#64748b;font-size:12px">Phone</span>
                        <span style="font-weight:700;font-size:12px">${data.phone || '—'}</span>
                    </div>
                    <div style="display:flex;justify-content:space-between;padding:5px 0">
                        <span style="color:#64748b;font-size:12px">Provider</span>
                        <span style="font-weight:700;font-size:12px;text-transform:capitalize">${data.provider}</span>
                    </div>
                    <hr style="border:none;border-top:1px solid #e2e8f0;margin:8px 0">
                    <div style="display:flex;justify-content:space-between;padding:5px 0">
                        <span style="color:#64748b;font-size:12px">Created</span>
                        <span style="font-weight:700;font-size:12px">${createdAt}</span>
                    </div>
                    <div style="display:flex;justify-content:space-between;padding:5px 0">
                        <span style="color:#64748b;font-size:12px">Paid At</span>
                        <span style="font-weight:700;font-size:12px">${paidAt}</span>
                    </div>
                    <hr style="border:none;border-top:1px solid #e2e8f0;margin:8px 0">
                    <div style="display:flex;justify-content:space-between;padding:8px 0">
                        <span style="font-weight:800;font-size:14px;color:#024938">TOTAL</span>
                        <span style="font-weight:800;font-size:16px;color:#024938">${data.currency} ${data.amount}</span>
                    </div>
                    <hr style="border:none;border-top:1px solid #e2e8f0;margin:8px 0">
                    <div style="text-align:center;margin-top:8px">
                        <div style="font-size:10px;color:#94a3b8;font-style:italic">This is a computer generated receipt.</div>
                        <div style="font-size:11px;color:#64748b;font-weight:600;margin-top:4px">Thank you for your payment!</div>
                    </div>
                </div>
            </div>
        `,
        showConfirmButton: true,
        confirmButtonText: 'Close',
        confirmButtonColor: '#024938',
        width: 560,
        showCloseButton: true,
    });
}

function togglePayload(id) {
    const el = document.getElementById('payload-' + id);
    el.classList.toggle('hidden');
}
</script>
@endpush

@section('content')
<div class="space-y-6">

    {{-- KPI Cards --}}
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div class="bg-white rounded-xl border border-gray-100 p-5 shadow-sm">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-xs font-semibold text-gray-400 uppercase tracking-wide">Total Transactions</p>
                    <p class="text-2xl font-extrabold text-gray-800 mt-1">{{ number_format($totalTransactions) }}</p>
                </div>
                <div class="w-12 h-12 rounded-xl bg-blue-50 flex items-center justify-center">
                    <svg class="w-6 h-6 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"/></svg>
                </div>
            </div>
            <p class="text-xs text-gray-400 mt-2">{{ $subscriptionCount }} subscription payments</p>
        </div>

        <div class="bg-white rounded-xl border border-gray-100 p-5 shadow-sm">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-xs font-semibold text-gray-400 uppercase tracking-wide">Completed</p>
                    <p class="text-2xl font-extrabold text-green-600 mt-1">{{ number_format($completedCount) }}</p>
                </div>
                <div class="w-12 h-12 rounded-xl bg-green-50 flex items-center justify-center">
                    <svg class="w-6 h-6 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                </div>
            </div>
            <p class="text-xs text-gray-400 mt-2">Successful payments</p>
        </div>

        <div class="bg-white rounded-xl border border-gray-100 p-5 shadow-sm">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-xs font-semibold text-gray-400 uppercase tracking-wide">Pending</p>
                    <p class="text-2xl font-extrabold text-amber-600 mt-1">{{ number_format($pendingCount) }}</p>
                </div>
                <div class="w-12 h-12 rounded-xl bg-amber-50 flex items-center justify-center">
                    <svg class="w-6 h-6 text-amber-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                </div>
            </div>
            <p class="text-xs text-gray-400 mt-2">Awaiting confirmation</p>
        </div>

        <div class="bg-white rounded-xl border border-gray-100 p-5 shadow-sm">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-xs font-semibold text-gray-400 uppercase tracking-wide">Total Volume</p>
                    <p class="text-2xl font-extrabold text-emerald-600 mt-1">TZS {{ number_format($completedVolume, 0) }}</p>
                </div>
                <div class="w-12 h-12 rounded-xl bg-emerald-50 flex items-center justify-center">
                    <svg class="w-6 h-6 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"/></svg>
                </div>
            </div>
            <p class="text-xs text-gray-400 mt-2">{{ $failedCount }} failed transactions</p>
        </div>
    </div>

    {{-- Filters --}}
    <div class="bg-white rounded-xl border border-gray-100 p-4 shadow-sm">
        <form method="GET" action="{{ route('admin.payment-transactions') }}" class="flex flex-wrap items-end gap-3">
            <div class="flex-1 min-w-[200px]">
                <label class="block text-xs font-semibold text-gray-500 mb-1">Search</label>
                <input type="text" name="search" value="{{ request('search') }}" placeholder="Reference, phone, org name..." class="w-full px-3 py-2 text-sm rounded-lg border border-gray-200 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 outline-none">
            </div>
            <div>
                <label class="block text-xs font-semibold text-gray-500 mb-1">Status</label>
                <select name="status" class="px-3 py-2 text-sm rounded-lg border border-gray-200 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 outline-none">
                    <option value="all" {{ request('status') === 'all' || !request('status') ? 'selected' : '' }}>All Status</option>
                    <option value="completed" {{ request('status') === 'completed' ? 'selected' : '' }}>Completed</option>
                    <option value="pending" {{ request('status') === 'pending' ? 'selected' : '' }}>Pending</option>
                    <option value="failed" {{ request('status') === 'failed' ? 'selected' : '' }}>Failed</option>
                </select>
            </div>
            <div>
                <label class="block text-xs font-semibold text-gray-500 mb-1">Type</label>
                <select name="type" class="px-3 py-2 text-sm rounded-lg border border-gray-200 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 outline-none">
                    <option value="all" {{ request('type') === 'all' || !request('type') ? 'selected' : '' }}>All Types</option>
                    <option value="subscription" {{ request('type') === 'subscription' ? 'selected' : '' }}>Subscription</option>
                    <option value="tenant_payment" {{ request('type') === 'tenant_payment' ? 'selected' : '' }}>Tenant Payment</option>
                </select>
            </div>
            <button type="submit" class="px-4 py-2 bg-emerald-600 text-white text-sm font-bold rounded-lg hover:bg-emerald-700 transition-colors">
                Filter
            </button>
            <a href="{{ route('admin.payment-transactions') }}" class="px-4 py-2 bg-gray-100 text-gray-600 text-sm font-bold rounded-lg hover:bg-gray-200 transition-colors">
                Reset
            </a>
        </form>
    </div>

    {{-- Transactions Table --}}
    <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
        <div class="px-5 py-4 border-b border-gray-100 flex items-center justify-between">
            <h2 class="font-bold text-gray-800">All Payment Transactions</h2>
            <span class="text-xs text-gray-400">{{ $transactions->total() }} transactions</span>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead>
                    <tr class="bg-gray-50 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide">
                        <th class="px-5 py-3">Transaction ID</th>
                        <th class="px-5 py-3">Organization</th>
                        <th class="px-5 py-3">Type</th>
                        <th class="px-5 py-3">Amount</th>
                        <th class="px-5 py-3">Method</th>
                        <th class="px-5 py-3">Phone</th>
                        <th class="px-5 py-3">Status</th>
                        <th class="px-5 py-3">Date</th>
                        <th class="px-5 py-3">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-50">
                    @forelse ($transactions as $tx)
                    <tr class="hover:bg-gray-50 transition-colors">
                        <td class="px-5 py-3">
                            <div class="font-mono text-xs text-gray-600">{{ \Illuminate\Support\Str::limit($tx->id, 12, '...') }}</div>
                            @if ($tx->provider_reference)
                                <div class="font-mono text-[10px] text-gray-400">{{ \Illuminate\Support\Str::limit($tx->provider_reference, 16, '...') }}</div>
                            @endif
                        </td>
                        <td class="px-5 py-3">
                            <div class="font-semibold text-gray-700">{{ $tx->organization?->name ?? '—' }}</div>
                            <div class="text-xs text-gray-400">{{ $tx->user?->full_name ?? $tx->user?->email ?? '—' }}</div>
                        </td>
                        <td class="px-5 py-3">
                            @if ($tx->type === 'subscription')
                                <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-semibold bg-purple-50 text-purple-700">Subscription</span>
                            @elseif ($tx->type === 'tenant_payment')
                                <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-semibold bg-blue-50 text-blue-700">Tenant Payment</span>
                            @else
                                <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-semibold bg-gray-50 text-gray-600">{{ ucfirst($tx->type) }}</span>
                            @endif
                        </td>
                        <td class="px-5 py-3">
                            <span class="font-bold text-gray-800">{{ $tx->currency }} {{ number_format((float)$tx->amount, 0) }}</span>
                        </td>
                        <td class="px-5 py-3">
                            @if ($tx->payment_method)
                                <span class="text-xs font-semibold text-gray-600 capitalize">{{ str_replace('_', ' ', $tx->payment_method) }}</span>
                            @else
                                <span class="text-xs text-gray-400">—</span>
                            @endif
                        </td>
                        <td class="px-5 py-3">
                            @if ($tx->phone)
                                <span class="font-mono text-xs text-gray-600">{{ $tx->phone }}</span>
                            @else
                                <span class="text-xs text-gray-400">—</span>
                            @endif
                        </td>
                        <td class="px-5 py-3">
                            @if ($tx->status === 'completed')
                                <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold bg-green-50 text-green-700">
                                    <span class="w-1.5 h-1.5 rounded-full bg-green-500"></span> Completed
                                </span>
                            @elseif ($tx->status === 'pending')
                                <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold bg-amber-50 text-amber-700">
                                    <span class="w-1.5 h-1.5 rounded-full bg-amber-500"></span> Pending
                                </span>
                            @elseif ($tx->status === 'failed')
                                <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold bg-red-50 text-red-700">
                                    <span class="w-1.5 h-1.5 rounded-full bg-red-500"></span> Failed
                                </span>
                            @else
                                <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold bg-gray-50 text-gray-600">
                                    <span class="w-1.5 h-1.5 rounded-full bg-gray-400"></span> {{ ucfirst($tx->status) }}
                                </span>
                            @endif
                        </td>
                        <td class="px-5 py-3">
                            <div class="text-xs text-gray-600">{{ $tx->created_at->format('d M Y') }}</div>
                            <div class="text-[10px] text-gray-400">{{ $tx->created_at->format('H:i') }}</div>
                        </td>
                        <td class="px-5 py-3">
                            <button onclick='viewReceipt({
                                id: "{{ $tx->id }}",
                                provider_reference: "{{ $tx->provider_reference ?? '' }}",
                                org: "{{ addslashes($tx->organization?->name ?? '—') }}",
                                user: "{{ addslashes($tx->user?->full_name ?? $tx->user?->email ?? '—') }}",
                                type: "{{ $tx->type }}",
                                amount: "{{ number_format((float)$tx->amount, 0) }}",
                                currency: "{{ $tx->currency }}",
                                method: "{{ $tx->payment_method ?? '' }}",
                                phone: "{{ $tx->phone ?? '' }}",
                                provider: "{{ $tx->provider }}",
                                status: "{{ $tx->status }}",
                                paid_at: "{{ $tx->paid_at ?? '' }}",
                                created_at: "{{ $tx->created_at->toISOString() }}"
                            })' class="inline-flex items-center gap-1 px-3 py-1.5 text-xs font-bold text-emerald-700 bg-emerald-50 rounded-lg hover:bg-emerald-100 transition-colors">
                                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
                                Receipt
                            </button>
                            @if ($tx->payload)
                            <button onclick="togglePayload('{{ $tx->id }}')" class="inline-flex items-center gap-1 px-3 py-1.5 text-xs font-bold text-gray-600 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors ml-1">
                                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"/></svg>
                                Payload
                            </button>
                            @endif
                        </td>
                    </tr>
                    <tr id="payload-{{ $tx->id }}" class="hidden bg-gray-900">
                        <td colspan="9" class="px-5 py-3">
                            <pre class="text-xs text-green-400 font-mono overflow-x-auto max-h-64">{{ json_encode($tx->payload, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) }}</pre>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="9" class="px-5 py-12 text-center text-gray-400">
                            <svg class="w-12 h-12 mx-auto mb-3 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
                            <p class="font-semibold">No payment transactions found</p>
                        </td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        {{-- Pagination --}}
        @if ($transactions->hasPages())
        <div class="px-5 py-4 border-t border-gray-100">
            {{ $transactions->withQueryString()->links() }}
        </div>
        @endif
    </div>

</div>
@endsection
