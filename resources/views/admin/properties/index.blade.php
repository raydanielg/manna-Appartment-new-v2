@extends('layouts.admin')

@section('title', 'Properties - Manna Apartment')
@section('page_title', 'Properties')

@section('content')
<div class="bg-white rounded-xl border overflow-hidden">
    <div class="px-5 py-4 border-b flex items-center justify-between">
        <h3 class="text-sm font-semibold text-gray-900">All Properties</h3>
        <span class="text-xs text-gray-500">{{ $properties->total() }} total</span>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead><tr class="text-left text-xs text-gray-500 bg-gray-50/50">
                <th class="px-5 py-2.5 font-medium">Property</th>
                <th class="px-5 py-2.5 font-medium">Organization</th>
                <th class="px-5 py-2.5 font-medium">Type</th>
                <th class="px-5 py-2.5 font-medium">Units</th>
                <th class="px-5 py-2.5 font-medium">Status</th>
                <th class="px-5 py-2.5 font-medium">Actions</th>
            </tr></thead>
            <tbody>
                @forelse($properties as $property)
                @php
                    $occupied = $property->units->where('status', 'occupied')->count();
                    $total = $property->units_count;
                    $vacant = max(0, $total - $occupied);
                    $images = $property->images_json ?? [];
                @endphp
                <tr class="border-t border-gray-100 hover:bg-gray-50/50 transition-colors">
                    <td class="px-5 py-2.5">
                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 rounded-lg bg-gray-100 overflow-hidden flex items-center justify-center">
                                @if(!empty($images))
                                <img src="{{ url('storage/' . $images[0]) }}" class="w-full h-full object-cover" alt="">
                                @else
                                <span class="text-gray-400 text-xs">No img</span>
                                @endif
                            </div>
                            <div>
                                <p class="text-xs font-medium text-gray-900">{{ $property->name }}</p>
                                <p class="text-[10px] text-gray-500">{{ $property->address ?? $property->location }}</p>
                            </div>
                        </div>
                    </td>
                    <td class="px-5 py-2.5 text-xs text-gray-700">{{ $property->organization->business_name ?? '-' }}</td>
                    <td class="px-5 py-2.5">
                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium bg-gray-100 text-gray-700 border border-gray-200">{{ ucfirst($property->type) }}</span>
                    </td>
                    <td class="px-5 py-2.5 text-xs text-gray-700">{{ $occupied }}/{{ $total }} ({{ $vacant }} vacant)</td>
                    <td class="px-5 py-2.5">
                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium {{ $property->status === 'active' ? 'bg-emerald-50 text-emerald-700 border border-emerald-100' : 'bg-gray-100 text-gray-700 border border-gray-200' }}">{{ ucfirst($property->status) }}</span>
                    </td>
                    <td class="px-5 py-2.5">
                        <a href="{{ route('admin.properties.show', $property->id) }}" class="px-2 py-1 rounded-md bg-gray-100 text-gray-600 hover:bg-gray-200 text-[10px] font-medium">View</a>
                    </td>
                </tr>
                @empty
                <tr><td colspan="6" class="px-5 py-8 text-center text-gray-400 text-xs">No properties yet</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
    <div class="px-5 py-3 border-t text-xs">
        {{ $properties->links() }}
    </div>
</div>
@endsection
