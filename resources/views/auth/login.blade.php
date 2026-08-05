@extends('layouts.app')

@section('title', 'Login - Manna Apartment')

@section('content')
<div class="w-full max-w-[440px] relative z-10" style="animation: simpleFadeIn 0.6s cubic-bezier(0.16, 1, 0.3, 1) both;">
    {{-- Decorative Background Elements --}}
    <div class="absolute -top-10 -right-10 w-40 h-40 bg-blue-100 rounded-full blur-3xl opacity-50 -z-10"></div>
    <div class="absolute -bottom-10 -left-10 w-40 h-40 bg-blue-50 rounded-full blur-3xl opacity-50 -z-10"></div>

    <div class="bg-white/80 backdrop-blur-xl rounded-[2rem] shadow-2xl shadow-blue-100/50 border border-white p-10">
        {{-- Logo & Header --}}
        <div class="text-center mb-10">
            <div class="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-tr from-blue-600 to-blue-400 rounded-3xl mb-8 shadow-lg shadow-blue-200 rotate-3 hover:rotate-0 transition-transform duration-500">
                <img src="{{ asset('file_000000001cdc7230acd3b9659475e375.png') }}" alt="Manna Apartment" class="w-14 h-14 object-cover rounded-2xl">
            </div>
            <h2 class="text-3xl font-black text-gray-900 tracking-tight">Manna Apartment</h2>
            <p class="text-gray-500 text-sm mt-3 font-semibold tracking-wide uppercase opacity-70">Admin Portal Access</p>
        </div>

        <form method="POST" action="{{ route('login') }}" class="space-y-7">
            @csrf

            {{-- Phone Number --}}
            <div class="space-y-2.5">
                <label for="phone" class="text-[13px] font-black text-gray-400 uppercase tracking-widest ml-1">Phone Number</label>
                <div class="relative group">
                    <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                        <span class="text-sm font-bold text-gray-400 group-focus-within:text-blue-600 transition-colors">+255</span>
                        <div class="h-5 w-px bg-gray-200 mx-3 group-focus-within:bg-blue-200 transition-colors"></div>
                    </div>
                    <input id="phone" type="tel" name="phone" value="{{ old('phone') }}" required autofocus 
                        maxlength="9"
                        class="block w-full pl-20 pr-4 py-4 bg-gray-50/50 border-2 border-gray-100 text-gray-900 text-base rounded-2xl focus:ring-4 focus:ring-blue-50 focus:border-blue-500 focus:bg-white outline-none transition-all font-bold placeholder:text-gray-300 shadow-sm"
                        placeholder="7XX XXX XXX">
                </div>
                @error('phone')
                    <p class="text-xs font-bold text-red-500 mt-2 ml-1 flex items-center gap-1.5">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                        {{ $message }}
                    </p>
                @enderror
            </div>

            {{-- Password --}}
            <div class="space-y-2.5">
                <div class="flex items-center justify-between ml-1">
                    <label for="password" class="text-[13px] font-black text-gray-400 uppercase tracking-widest">Password</label>
                    @if (Route::has('password.request'))
                        <a href="{{ route('password.request') }}" class="text-[11px] font-black text-blue-600 hover:text-blue-700 uppercase tracking-wider transition-colors">Recover?</a>
                    @endif
                </div>
                <div class="relative group">
                    <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                        <svg class="w-5 h-5 text-gray-300 group-focus-within:text-blue-600 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                    </div>
                    <input id="password" type="password" name="password" required autocomplete="current-password"
                        class="block w-full pl-12 pr-4 py-4 bg-gray-50/50 border-2 border-gray-100 text-gray-900 text-base rounded-2xl focus:ring-4 focus:ring-blue-50 focus:border-blue-500 focus:bg-white outline-none transition-all font-bold placeholder:text-gray-300 shadow-sm"
                        placeholder="••••••••">
                </div>
                @error('password')
                    <p class="text-xs font-bold text-red-500 mt-2 ml-1 flex items-center gap-1.5">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                        {{ $message }}
                    </p>
                @enderror
            </div>

            {{-- Controls --}}
            <div class="flex items-center justify-between px-1">
                <label for="remember" class="flex items-center cursor-pointer group">
                    <div class="relative">
                        <input id="remember" type="checkbox" name="remember" class="sr-only peer">
                        <div class="w-5 h-5 bg-gray-100 border-2 border-gray-200 rounded-lg peer-checked:bg-blue-600 peer-checked:border-blue-600 transition-all"></div>
                        <svg class="absolute top-0.5 left-0.5 w-4 h-4 text-white opacity-0 peer-checked:opacity-100 transition-opacity" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"/></svg>
                    </div>
                    <span class="ml-3 text-sm font-bold text-gray-500 group-hover:text-gray-700 transition-colors">Remember me</span>
                </label>
            </div>

            {{-- Submit --}}
            <button type="submit" id="btn-login" class="w-full py-4.5 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white text-lg font-black rounded-2xl shadow-xl shadow-blue-200 transition-all hover:-translate-y-1 active:translate-y-0 active:scale-[0.98] flex items-center justify-center gap-3 disabled:opacity-80 disabled:cursor-not-allowed">
                <span id="btn-text">Log in to Dashboard</span>
                <svg id="login-icon" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M13 7l5 5m0 0l-5 5m5-5H6"/></svg>
                <svg id="login-spinner" class="hidden w-6 h-6 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
            </button>
        </form>
    </div>

    <div class="mt-10 text-center">
        <p class="text-sm text-gray-400 font-black tracking-widest uppercase opacity-50">&copy; {{ date('Y') }} Manna Apartment</p>
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
        btnText.textContent = 'Verifying...';
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
