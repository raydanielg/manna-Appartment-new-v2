@extends('layouts.admin')

@section('title', 'Settings - Manna Apartment')
@section('page_title', 'Platform Settings')

@section('content')
@if (session('success'))
    <div class="mb-4 p-3 rounded-lg bg-emerald-50 text-emerald-700 text-sm border border-emerald-100 animate__animated animate__fadeInDown">{{ session('success') }}</div>
@endif

<form method="POST" action="{{ route('admin.settings.update') }}" class="space-y-6">
    @csrf
    @method('PUT')

    @foreach($settings as $group => $items)
    <div class="bg-white rounded-xl border overflow-hidden">
        <div class="px-5 py-4 border-b bg-gray-50/50">
            <h3 class="text-sm font-semibold text-gray-900 uppercase tracking-wide">{{ ucfirst(str_replace('_', ' ', $group)) }}</h3>
        </div>
        <div class="p-5 grid grid-cols-1 md:grid-cols-2 gap-5">
            @foreach($items as $setting)
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1.5">{{ $setting->label }}</label>
                @if($setting->type === 'textarea')
                    <textarea name="{{ $setting->key }}" rows="3" class="w-full px-4 py-2.5 rounded-lg border border-gray-200 focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200 outline-none transition-all text-sm">{{ old($setting->key, $setting->value) }}</textarea>
                @elseif($setting->type === 'boolean')
                    <select name="{{ $setting->key }}" class="w-full px-4 py-2.5 rounded-lg border border-gray-200 focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200 outline-none transition-all text-sm bg-white">
                        <option value="on" {{ old($setting->key, $setting->value) === 'on' ? 'selected' : '' }}>Enabled</option>
                        <option value="off" {{ old($setting->key, $setting->value) === 'off' ? 'selected' : '' }}>Disabled</option>
                    </select>
                @elseif($setting->type === 'number')
                    <input type="number" name="{{ $setting->key }}" value="{{ old($setting->key, $setting->value) }}" class="w-full px-4 py-2.5 rounded-lg border border-gray-200 focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200 outline-none transition-all text-sm">
                @else
                    <input type="text" name="{{ $setting->key }}" value="{{ old($setting->key, $setting->value) }}" class="w-full px-4 py-2.5 rounded-lg border border-gray-200 focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200 outline-none transition-all text-sm">
                @endif
                <p class="text-xs text-gray-400 mt-1">Key: {{ $setting->key }}</p>
            </div>
            @endforeach
        </div>
    </div>
    @endforeach

    <div class="flex items-center gap-3">
        <button type="submit" class="px-6 py-2.5 text-sm font-bold text-gray-900 bg-gradient-to-r from-gold-300 to-gold-400 hover:from-gold-400 hover:to-gold-500 rounded-lg shadow-md transition-all">
            Save Settings
        </button>
        <a href="{{ route('admin.sms_logs') }}" class="px-6 py-2.5 text-sm font-semibold text-emerald-700 bg-emerald-50 hover:bg-emerald-100 border border-emerald-200 rounded-lg transition-all">
            View SMS Logs
        </a>
    </div>
</form>

{{-- Add new setting --}}
<div class="bg-white rounded-xl border overflow-hidden mt-6">
    <div class="px-5 py-4 border-b bg-gray-50/50">
        <h3 class="text-sm font-semibold text-gray-900 uppercase tracking-wide">Add New Setting</h3>
    </div>
    <div class="p-5">
        <form method="POST" action="{{ route('admin.settings.store') }}" class="grid grid-cols-1 md:grid-cols-5 gap-3">
            @csrf
            <input type="text" name="key" placeholder="Key" required class="px-3 py-2 rounded-lg border border-gray-200 text-sm">
            <input type="text" name="label" placeholder="Label" required class="px-3 py-2 rounded-lg border border-gray-200 text-sm">
            <select name="group" class="px-3 py-2 rounded-lg border border-gray-200 text-sm bg-white">
                <option value="general">General</option>
                <option value="mobile_app">Mobile App</option>
                <option value="maintenance">Maintenance</option>
                <option value="sms">SMS</option>
                <option value="payments">Payments</option>
            </select>
            <select name="type" class="px-3 py-2 rounded-lg border border-gray-200 text-sm bg-white">
                <option value="text">Text</option>
                <option value="textarea">Textarea</option>
                <option value="boolean">Boolean</option>
                <option value="number">Number</option>
            </select>
            <input type="text" name="value" placeholder="Value" class="px-3 py-2 rounded-lg border border-gray-200 text-sm">
            <button type="submit" class="md:col-span-5 px-4 py-2 text-sm font-semibold text-white bg-emerald-600 hover:bg-emerald-700 rounded-lg transition-all">Add Setting</button>
        </form>
    </div>
</div>
@endsection
