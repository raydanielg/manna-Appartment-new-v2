@extends('layouts.admin')

@section('title', 'Property Details - Manna Apartment')
@section('page_title', 'Property Details')

@section('content')
@php
    $images = $property->images_json ?? [];
    $occupied = $property->units->where('status', 'occupied')->count();
    $total = $property->units_count;
    $vacant = max(0, $total - $occupied);
@endphp
<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <div class="lg:col-span-2 space-y-6">
        <div class="bg-white rounded-xl border overflow-hidden">
            <div class="px-5 py-4 border-b flex items-center justify-between">
                <h3 class="text-sm font-semibold text-gray-900">{{ $property->name }}</h3>
                <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium {{ $property->status === 'active' ? 'bg-emerald-50 text-emerald-700 border border-emerald-100' : 'bg-gray-100 text-gray-700 border border-gray-200' }}">{{ ucfirst($property->status) }}</span>
            </div>
            <div class="p-5 grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
                <div class="bg-gray-50 rounded-lg p-3">
                    <p class="text-xs text-gray-500 mb-1">Type</p>
                    <p class="font-semibold text-gray-900">{{ ucfirst($property->type) }}</p>
                </div>
                <div class="bg-gray-50 rounded-lg p-3">
                    <p class="text-xs text-gray-500 mb-1">Address</p>
                    <p class="font-semibold text-gray-900">{{ $property->address ?? $property->location ?? '-' }}</p>
                </div>
                <div class="bg-gray-50 rounded-lg p-3">
                    <p class="text-xs text-gray-500 mb-1">Total Units</p>
                    <p class="font-semibold text-gray-900">{{ $total }}</p>
                </div>
                <div class="bg-gray-50 rounded-lg p-3">
                    <p class="text-xs text-gray-500 mb-1">Occupied</p>
                    <p class="font-semibold text-gray-900">{{ $occupied }}</p>
                </div>
                <div class="bg-gray-50 rounded-lg p-3">
                    <p class="text-xs text-gray-500 mb-1">Vacant</p>
                    <p class="font-semibold text-gray-900">{{ $vacant }}</p>
                </div>
                <div class="bg-gray-50 rounded-lg p-3">
                    <p class="text-xs text-gray-500 mb-1">Organization</p>
                    <p class="font-semibold text-gray-900">{{ $property->organization->business_name ?? '-' }}</p>
                </div>
            </div>
            @if($property->description)
            <div class="px-5 pb-5">
                <p class="text-xs text-gray-500 mb-1">Description</p>
                <p class="text-sm text-gray-700">{{ $property->description }}</p>
            </div>
            @endif
        </div>

        <div class="bg-white rounded-xl border overflow-hidden">
            <div class="px-5 py-4 border-b">
                <h3 class="text-sm font-semibold text-gray-900">Photos</h3>
            </div>
            <div class="p-5 grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
                @forelse($images as $img)
                <a href="{{ url('storage/' . $img) }}" target="_blank" class="block border rounded-lg overflow-hidden hover:opacity-90">
                    <img src="{{ url('storage/' . $img) }}" class="w-full h-32 object-cover" alt="Property photo">
                </a>
                @empty
                <p class="text-xs text-gray-400 col-span-full text-center py-6">No photos uploaded</p>
                @endforelse
            </div>
        </div>
    </div>

    <div class="space-y-6">
        <div class="bg-white rounded-xl border overflow-hidden">
            <div class="px-5 py-4 border-b">
                <h3 class="text-sm font-semibold text-gray-900">Units</h3>
            </div>
            <div class="p-5">
                @forelse($property->units as $unit)
                <div class="border rounded-lg p-3 mb-2 last:mb-0 flex items-center justify-between">
                    <div>
                        <p class="text-xs font-semibold text-gray-900">{{ $unit->unit_number ?? $unit->name }}</p>
                        <p class="text-[10px] text-gray-500">{{ $unit->type ?? '-' }} • TZS {{ number_format($unit->rent_amount ?? 0) }}</p>
                    </div>
                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium {{ $unit->status === 'occupied' ? 'bg-emerald-50 text-emerald-700 border border-emerald-100' : 'bg-amber-50 text-amber-700 border border-amber-100' }}">{{ ucfirst($unit->status) }}</span>
                </div>
                @empty
                <p class="text-xs text-gray-400 text-center py-4">No units yet</p>
                @endforelse
            </div>
        </div>
    </div>
</div>
@endsection
