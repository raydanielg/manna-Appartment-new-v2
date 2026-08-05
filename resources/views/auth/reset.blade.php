@extends('layouts.app')

@section('title', 'Reset Password - Manna Apartment')

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
            <h2 class="text-3xl font-black text-gray-900 tracking-tight">Set Password</h2>
            <p class="text-gray-500 text-sm mt-3 font-semibold tracking-wide uppercase opacity-70">Secure Update</p>
        </div>

        <div id="alert-success" class="hidden mb-8 p-5 rounded-2xl bg-blue-50/50 text-blue-700 text-sm border border-blue-100 font-bold flex items-center gap-3 backdrop-blur-sm">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            <span></span>
        </div>

        <form id="reset-form" method="POST" action="{{ route('password.update.reset') }}" class="space-y-7">
            @csrf
            <input type="hidden" id="phone" name="phone" value="{{ $phone }}">
            <input type="hidden" id="otp" name="otp" value="{{ $otp }}">

            {{-- New Password --}}
            <div class="space-y-2.5">
                <label for="password" class="text-[13px] font-black text-gray-400 uppercase tracking-widest ml-1">New Password</label>
                <div class="relative group">
                    <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                        <svg class="w-5 h-5 text-gray-400 group-focus-within:text-blue-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                    </div>
                    <input id="password" type="password" name="password" required autofocus
                        class="block w-full pl-12 pr-4 py-4 bg-gray-50/50 border-2 border-gray-100 text-gray-900 text-base rounded-2xl focus:ring-4 focus:ring-blue-50 focus:border-blue-500 focus:bg-white outline-none transition-all font-bold shadow-sm placeholder:text-gray-300"
                        placeholder="••••••••">
                </div>
                <p id="password-error" class="hidden text-xs font-bold text-red-500 mt-2 ml-1 flex items-center gap-1.5">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                    <span></span>
                </p>
            </div>

            {{-- Confirm Password --}}
            <div class="space-y-2.5">
                <label for="password-confirm" class="text-[13px] font-black text-gray-400 uppercase tracking-widest ml-1">Confirm Password</label>
                <div class="relative group">
                    <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                        <svg class="w-5 h-5 text-gray-400 group-focus-within:text-blue-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                    </div>
                    <input id="password-confirm" type="password" name="password_confirmation" required
                        class="block w-full pl-12 pr-4 py-4 bg-gray-50/50 border-2 border-gray-100 text-gray-900 text-base rounded-2xl focus:ring-4 focus:ring-blue-50 focus:border-blue-500 focus:bg-white outline-none transition-all font-bold shadow-sm placeholder:text-gray-300"
                        placeholder="••••••••">
                </div>
            </div>

            {{-- Submit --}}
            <button id="btn-reset" type="submit" class="w-full py-4.5 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white text-lg font-black rounded-2xl shadow-xl shadow-blue-200 transition-all hover:-translate-y-1 active:translate-y-0 active:scale-[0.98] flex items-center justify-center gap-3 disabled:opacity-80 disabled:cursor-not-allowed">
                <span id="btn-text">Update Password</span>
                <svg id="spinner" class="hidden w-6 h-6 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
            </button>
        </form>
    </div>

    <div class="mt-10 text-center">
        <p class="text-sm text-gray-400 font-black tracking-widest uppercase opacity-50">&copy; {{ date('Y') }} Manna Apartment</p>
    </div>
</div>

<script>
    const resetForm = document.getElementById('reset-form');
    const passwordInput = document.getElementById('password');
    const confirmInput = document.getElementById('password-confirm');
    const btnReset = document.getElementById('btn-reset');
    const spinner = document.getElementById('spinner');
    const passwordError = document.getElementById('password-error');
    const alertSuccess = document.getElementById('alert-success');
    const btnText = document.getElementById('btn-text');

    function showError(msg) {
        passwordError.querySelector('span').textContent = msg;
        passwordError.classList.remove('hidden');
        passwordInput.classList.add('border-red-300', 'ring-4', 'ring-red-50');
        passwordInput.classList.remove('border-gray-100');
    }
    function hideError() { 
        passwordError.classList.add('hidden');
        passwordInput.classList.remove('border-red-300', 'ring-4', 'ring-red-50');
        passwordInput.classList.add('border-gray-100');
    }

    resetForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        hideError();
        const password = passwordInput.value;
        const confirm = confirmInput.value;
        
        if (password.length < 6) {
            showError('Password must be at least 6 characters');
            return;
        }
        if (password !== confirm) {
            showError('Passwords do not match');
            return;
        }

        btnText.textContent = 'Updating...';
        spinner.classList.remove('hidden');
        btnReset.disabled = true;

        const formData = new FormData(resetForm);
        const data = Object.fromEntries(formData.entries());

        try {
            const response = await fetch(resetForm.action, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                },
                body: JSON.stringify(data)
            });
            const result = await response.json();

            if (response.ok) {
                alertSuccess.querySelector('span').textContent = result.message || 'Password updated! Redirecting...';
                alertSuccess.classList.remove('hidden');
                setTimeout(() => {
                    window.location.href = result.redirect || '{{ route('login') }}';
                }, 1500);
            } else {
                const msg = result.errors ? Object.values(result.errors).flat().join(' ') : (result.message || 'Failed to update password.');
                showError(msg);
            }
        } catch (err) {
            showError('Network error. Please try again.');
        } finally {
            if (alertSuccess.classList.contains('hidden')) {
                btnText.textContent = 'Update Password';
                spinner.classList.add('hidden');
                btnReset.disabled = false;
            } else {
                btnText.textContent = 'Updated!';
                spinner.classList.add('hidden');
            }
        }
    });
</script>
@endsection
