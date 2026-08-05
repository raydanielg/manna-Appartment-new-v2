@extends('layouts.app')

@section('title', 'Login - Manna Apartment')

@section('content')
<div class="w-full max-w-[420px] relative z-10" style="animation: simpleFadeIn 0.5s cubic-bezier(0.16, 1, 0.3, 1) both;">
    <div class="bg-white rounded-2xl shadow-sm border border-gray-200 p-8">
        {{-- Logo & Header --}}
        <div class="text-center mb-10">
            <div class="inline-flex items-center justify-center w-16 h-16 bg-blue-50 rounded-xl mb-6">
                <img src="{{ asset('file_000000001cdc7230acd3b9659475e375.png') }}" alt="Manna Apartment" class="w-12 h-12 object-cover rounded-lg">
            </div>
            <h2 class="text-2xl font-extrabold text-gray-900">Welcome Back</h2>
            <p class="text-gray-500 text-sm mt-2 font-medium">Please enter your details to sign in.</p>
        </div>

        <form method="POST" action="{{ route('login') }}" class="space-y-6">
            @csrf

            {{-- Phone Number --}}
            <div class="space-y-2">
                <label for="phone" class="text-sm font-bold text-gray-700 ml-1">Phone Number</label>
                <div class="relative group">
                    <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                        <span class="text-sm font-bold text-gray-400 group-focus-within:text-blue-500 transition-colors">+255</span>
                        <div class="h-4 w-px bg-gray-200 mx-2 group-focus-within:bg-blue-200"></div>
                    </div>
                    <input id="phone" type="tel" name="phone" value="{{ old('phone') }}" required autofocus 
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

            {{-- Password --}}
            <div class="space-y-2">
                <div class="flex items-center justify-between ml-1">
                    <label for="password" class="text-sm font-bold text-gray-700">Password</label>
                    @if (Route::has('password.request'))
                        <a href="{{ route('password.request') }}" class="text-xs font-bold text-blue-600 hover:text-blue-700">Forgot password?</a>
                    @endif
                </div>
                <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                        <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                    </div>
                    <input id="password" type="password" name="password" required autocomplete="current-password"
                        class="block w-full pl-11 pr-4 py-3 bg-gray-50 border border-gray-200 text-gray-900 text-sm rounded-xl focus:ring-2 focus:ring-blue-100 focus:border-blue-500 outline-none transition-all font-semibold"
                        placeholder="••••••••">
                </div>
                @error('password')
                    <p class="text-xs font-semibold text-red-500 mt-1 flex items-center gap-1">
                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                        {{ $message }}
                    </p>
                @enderror
            </div>

            {{-- Remember Me --}}
            <div class="flex items-center ml-1">
                <input id="remember" type="checkbox" name="remember" class="w-4 h-4 text-blue-600 bg-gray-50 border-gray-300 rounded focus:ring-blue-500 cursor-pointer">
                <label for="remember" class="ml-2 text-sm font-semibold text-gray-500 cursor-pointer">Keep me signed in</label>
            </div>

            {{-- Submit --}}
            <button type="submit" id="btn-login" class="w-full py-3.5 bg-blue-600 hover:bg-blue-700 text-white font-extrabold rounded-xl shadow-lg shadow-blue-200 transition-all hover:-translate-y-0.5 active:scale-[0.98] flex items-center justify-center gap-2 disabled:bg-blue-600 disabled:opacity-80 disabled:cursor-not-allowed">
                <span id="btn-text">Sign In</span>
                <svg id="login-icon" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M13 7l5 5m0 0l-5 5m5-5H6"/></svg>
                <svg id="login-spinner" class="hidden w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
            </button>
        </form>
    </div>

    <div class="mt-8 text-center">
        <p class="text-sm text-gray-400 font-medium">&copy; {{ date('Y') }} Manna Apartment. All rights reserved.</p>
    </div>
</div>

<script>
    const loginForm = document.querySelector('form');
    const loginBtn = document.getElementById('btn-login');
    const loginIcon = document.getElementById('login-icon');
    const loginSpinner = document.getElementById('login-spinner');
    const btnText = document.getElementById('btn-text');
    const phoneInput = document.getElementById('phone');
    
    loginForm.addEventListener('submit', () => {
        btnText.textContent = 'Signing in...';
        loginIcon.classList.add('hidden');
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
