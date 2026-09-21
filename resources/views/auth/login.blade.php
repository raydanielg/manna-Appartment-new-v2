@extends('layouts.app')

@section('title', 'Login - Manna Apartment')

@section('content')
<div class="w-full max-w-[400px] relative z-10">
    <div class="bg-white rounded-xl border border-gray-200 p-8 sm:p-10">
        {{-- Header --}}
        <div class="text-center mb-8">
            <h2 class="text-xl font-bold text-gray-900">Manna Apartment</h2>
            <p class="text-gray-400 text-xs mt-1 font-semibold uppercase tracking-widest">Admin Portal</p>
        </div>

        <form method="POST" action="{{ route('login') }}" class="space-y-5">
            @csrf

            {{-- Phone Number --}}
            <div>
                <label for="phone" class="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1.5">Phone Number</label>
                <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                        <span class="text-sm font-semibold text-gray-400">+255</span>
                        <div class="h-4 w-px bg-gray-200 mx-2.5"></div>
                    </div>
                    <input id="phone" type="tel" name="phone" value="{{ old('phone') }}" required autofocus
                        maxlength="9" inputmode="numeric" autocomplete="tel"
                        class="block w-full pl-[74px] pr-4 py-3 bg-white border border-gray-200 text-gray-900 text-sm rounded-lg focus:border-blue-600 focus:ring-1 focus:ring-blue-600 outline-none transition-colors font-semibold placeholder:text-gray-300 placeholder:font-normal"
                        placeholder="7XX XXX XXX">
                </div>
                @error('phone')
                    <p class="text-xs font-semibold text-red-500 mt-1.5">{{ $message }}</p>
                @enderror
            </div>

            {{-- Password --}}
            <div>
                <div class="flex items-center justify-between mb-1.5">
                    <label for="password" class="block text-xs font-semibold text-gray-500 uppercase tracking-wide">Password</label>
                    @if (Route::has('password.request'))
                        <a href="{{ route('password.request') }}" class="text-xs font-semibold text-blue-600 hover:text-blue-700">Forgot?</a>
                    @endif
                </div>
                <input id="password" type="password" name="password" required autocomplete="current-password"
                    class="block w-full px-4 py-3 bg-white border border-gray-200 text-gray-900 text-sm rounded-lg focus:border-blue-600 focus:ring-1 focus:ring-blue-600 outline-none transition-colors font-semibold placeholder:text-gray-300 placeholder:font-normal"
                    placeholder="Enter your password">
                @error('password')
                    <p class="text-xs font-semibold text-red-500 mt-1.5">{{ $message }}</p>
                @enderror
            </div>

            {{-- Remember me --}}
            <div class="flex items-center">
                <input id="remember" type="checkbox" name="remember"
                    class="w-4 h-4 text-blue-600 bg-white border-gray-300 rounded focus:ring-blue-600 focus:ring-1">
                <label for="remember" class="ml-2 text-sm text-gray-500 cursor-pointer select-none">Remember me</label>
            </div>

            {{-- Submit --}}
            <button type="submit" id="btn-login"
                class="w-full py-3 bg-blue-600 hover:bg-blue-700 text-white text-sm font-bold rounded-lg transition-colors flex items-center justify-center gap-2 disabled:opacity-70 disabled:cursor-not-allowed">
                <span id="btn-text">Log in</span>
                <svg id="login-spinner" class="hidden w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
            </button>
        </form>
    </div>

    <p class="mt-6 text-center text-xs text-gray-400">&copy; {{ date('Y') }} Manna Apartment</p>
</div>

<script>
    const loginForm = document.querySelector('form');
    const loginBtn = document.getElementById('btn-login');
    const loginSpinner = document.getElementById('login-spinner');
    const btnText = document.getElementById('btn-text');
    const phoneInput = document.getElementById('phone');

    loginForm.addEventListener('submit', () => {
        btnText.textContent = 'Signing in...';
        loginSpinner.classList.remove('hidden');
        loginBtn.disabled = true;
    });

    phoneInput.addEventListener('input', () => {
        let val = phoneInput.value.replace(/\D/g, '');
        if (val.length > 9) val = val.slice(0, 9);
        phoneInput.value = val;
    });
</script>
@endsection
