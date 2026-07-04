@extends('layouts.admin')

@section('title', 'KYC Reviews - Manna Apartment')
@section('page_title', 'KYC Reviews')

@section('content')
<div class="bg-white rounded-xl border overflow-hidden">
    <div class="px-5 py-4 border-b">
        <h3 class="text-sm font-semibold text-gray-900">KYC Documents</h3>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead><tr class="text-left text-xs text-gray-500 bg-gray-50/50">
                <th class="px-5 py-2.5 font-medium">Organization</th>
                <th class="px-5 py-2.5 font-medium">ID Number</th>
                <th class="px-5 py-2.5 font-medium">Status</th>
                <th class="px-5 py-2.5 font-medium">Reviewed By</th>
                <th class="px-5 py-2.5 font-medium">Submitted</th>
            </tr></thead>
            <tbody>
                @forelse($documents as $doc)
                <tr class="border-t border-gray-100 hover:bg-gray-50/50 transition-colors">
                    <td class="px-5 py-2.5 text-xs text-gray-900">{{ $doc->organization->name ?? '-' }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-700">{{ $doc->id_number }}</td>
                    <td class="px-5 py-2.5">
                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium
                            {{ $doc->status === 'approved' ? 'bg-emerald-50 text-emerald-700 border border-emerald-100' : ($doc->status === 'pending' ? 'bg-amber-50 text-amber-700 border border-amber-100' : 'bg-red-50 text-red-700 border border-red-100') }}">{{ ucfirst($doc->status) }}</span>
                    </td>
                    <td class="px-5 py-2.5 text-xs text-gray-500">{{ $doc->reviewer->full_name ?? '-' }}</td>
                    <td class="px-5 py-2.5 text-xs text-gray-500">{{ $doc->created_at->format('Y-m-d') }}</td>
                </tr>
                @empty
                <tr><td colspan="5" class="px-5 py-8 text-center text-gray-400 text-xs">No KYC documents</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
    <div class="px-5 py-3 border-t text-xs">
        {{ $documents->links() }}
    </div>
</div>
@endsection
