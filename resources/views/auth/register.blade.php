@extends('layouts.app')

@section('title', 'Register as Landlord - Manna Apartment')

@section('content')
<div class="w-full max-w-[480px] relative z-10" style="animation: simpleFadeIn 0.5s cubic-bezier(0.16, 1, 0.3, 1) both;">
    <div class="bg-white rounded-2xl shadow-sm border border-gray-200 p-8">
        {{-- Logo & Header --}}
        <div class="text-center mb-8">
            <div class="inline-flex items-center justify-center w-16 h-16 bg-blue-50 rounded-xl mb-6">
                <img src="{{ asset('file_000000001cdc7230acd3b9659475e375.png') }}" alt="Manna Apartment" class="w-12 h-12 object-cover rounded-lg">
            </div>
            <h2 class="text-2xl font-extrabold text-gray-900">Create Account</h2>
            <p class="text-gray-500 text-sm mt-2 font-medium">Join Manna Apartment as a landlord.</p>
        </div>

        <form method="POST" action="{{ route('register') }}" class="space-y-5">
            @csrf

            {{-- Full Name --}}
            <div class="space-y-2">
                <label for="name" class="text-sm font-bold text-gray-700 ml-1">Full Name</label>
                <div class="relative group">
                    <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                        <svg class="w-5 h-5 text-gray-400 group-focus-within:text-blue-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
                    </div>
                    <input id="name" type="text" name="name" value="{{ old('name') }}" required autofocus
                        class="block w-full pl-11 pr-4 py-3 bg-gray-50 border border-gray-200 text-gray-900 text-sm rounded-xl focus:ring-2 focus:ring-blue-100 focus:border-blue-500 outline-none transition-all font-semibold"
                        placeholder="John Doe">
                </div>
                @error('name')
                    <p class="text-xs font-semibold text-red-500 mt-1 flex items-center gap-1">
                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                        {{ $message }}
                    </p>
                @enderror
            </div>

            {{-- Phone Number --}}
            <div class="space-y-2">
                <label for="phone" class="text-sm font-bold text-gray-700 ml-1">Phone Number</label>
                <div class="relative group">
                    <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                        <span class="text-sm font-bold text-gray-400 group-focus-within:text-blue-500 transition-colors">+255</span>
                        <div class="h-4 w-px bg-gray-200 mx-2 group-focus-within:bg-blue-200"></div>
                    </div>
                    <input id="phone" type="tel" name="phone" value="{{ old('phone') }}" required
                        maxlength="9"
                        class="block w-full pl-[4.5rem] pr-4 py-3 bg-gray-50 border border-gray-200 text-gray-900 text-sm rounded-xl focus:ring-2 focus:ring-blue-100 focus:border-blue-500 outline-none transition-all font-semibold"
                        placeholder="7XX XXX XXX">
                </div>
                @error('phone')
                    <p class="text-xs font-semibold text-red-500 mt-1 flex items-center gap-1">
                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                        {{ $message }}
                    </p>
                @enderror
            </div>

            {{-- Email --}}
            <div class="space-y-2">
                <label for="email" class="text-sm font-bold text-gray-700 ml-1">Email Address</label>
                <div class="relative group">
                    <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                        <svg class="w-5 h-5 text-gray-400 group-focus-within:text-blue-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207"/></svg>
                    </div>
                    <input id="email" type="email" name="email" value="{{ old('email') }}" required
                        class="block w-full pl-11 pr-4 py-3 bg-gray-50 border border-gray-200 text-gray-900 text-sm rounded-xl focus:ring-2 focus:ring-blue-100 focus:border-blue-500 outline-none transition-all font-semibold"
                        placeholder="you@example.com">
                </div>
                @error('email')
                    <p class="text-xs font-semibold text-red-500 mt-1 flex items-center gap-1">
                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                        {{ $message }}
                    </p>
                @enderror
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                {{-- Password --}}
                <div class="space-y-2">
                    <label for="password" class="text-sm font-bold text-gray-700 ml-1">Password</label>
                    <div class="relative group">
                        <input id="password" type="password" name="password" required
                            class="block w-full px-4 py-3 bg-gray-50 border border-gray-200 text-gray-900 text-sm rounded-xl focus:ring-2 focus:ring-blue-100 focus:border-blue-500 outline-none transition-all font-semibold"
                            placeholder="••••••••">
                    </div>
                </div>

                {{-- Confirm Password --}}
                <div class="space-y-2">
                    <label for="password-confirm" class="text-sm font-bold text-gray-700 ml-1">Confirm</label>
                    <div class="relative group">
                        <input id="password-confirm" type="password" name="password_confirmation" required
                            class="block w-full px-4 py-3 bg-gray-50 border border-gray-200 text-gray-900 text-sm rounded-xl focus:ring-2 focus:ring-blue-100 focus:border-blue-500 outline-none transition-all font-semibold"
                            placeholder="••••••••">
                    </div>
                </div>
            </div>
            @error('password')
                <p class="text-xs font-semibold text-red-500 mt-1 flex items-center gap-1">
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                    {{ $message }}
                </p>
            @enderror

            {{-- Submit --}}
            <button type="submit" id="btn-register" class="w-full py-3.5 bg-blue-600 hover:bg-blue-700 text-white font-extrabold rounded-xl shadow-lg shadow-blue-200 transition-all hover:-translate-y-0.5 active:scale-[0.98] flex items-center justify-center gap-2 disabled:bg-blue-600 disabled:opacity-80 disabled:cursor-not-allowed">
                <span id="btn-text">Create Account</span>
                <svg id="reg-icon" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"/></svg>
                <svg id="reg-spinner" class="hidden w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
            </button>
        </form>

        <div class="mt-8 text-center border-t border-gray-100 pt-6">
            <p class="text-sm text-gray-500 font-medium">
                Already have an account?
                <a href="{{ route('login') }}" class="font-bold text-blue-600 hover:text-blue-700 ml-1">Sign in</a>
            </p>
        </div>
    </div>

    <div class="mt-8 text-center">
        <p class="text-sm text-gray-400 font-medium">&copy; {{ date('Y') }} Manna Apartment. All rights reserved.</p>
    </div>
</div>

<script>
    const regForm = document.querySelector('form');
    const regBtn = document.getElementById('btn-register');
    const regIcon = document.getElementById('reg-icon');
    const regSpinner = document.getElementById('reg-spinner');
    const btnText = document.getElementById('btn-text');
    const phoneInput = document.getElementById('phone');
    
    regForm.addEventListener('submit', () => {
        btnText.textContent = 'Creating account...';
        regIcon.classList.add('hidden');
        regSpinner.classList.remove('hidden');
        regBtn.disabled = true;
    });

    phoneInput.addEventListener('input', () => {
        let val = phoneInput.value.replace(/\D/g, '');
        if (val.length > 9) val = val.slice(0, 9);
        phoneInput.value = val;
    });
</script>
@endsection
