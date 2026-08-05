@extends('layouts.app')

@section('title', 'Reset Password - Manna Apartment')

@section('content')
<div class="w-full max-w-[420px] relative z-10" style="animation: simpleFadeIn 0.5s cubic-bezier(0.16, 1, 0.3, 1) both;">
    <div class="bg-white rounded-2xl shadow-sm border border-gray-200 p-8">
        {{-- Logo & Header --}}
        <div class="text-center mb-10">
            <div class="inline-flex items-center justify-center w-16 h-16 bg-blue-50 rounded-xl mb-6">
                <img src="{{ asset('file_000000001cdc7230acd3b9659475e375.png') }}" alt="Manna Apartment" class="w-12 h-12 object-cover rounded-lg">
            </div>
            <h2 class="text-2xl font-extrabold text-gray-900">Reset Password</h2>
            <p class="text-gray-500 text-sm mt-2 font-medium">Set a new secure password for your account.</p>
        </div>

        <div id="alert-success" class="hidden mb-6 p-4 rounded-xl bg-blue-50 text-blue-700 text-sm border border-blue-100 font-bold flex items-center gap-2">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            <span></span>
        </div>

        <form id="reset-form" method="POST" action="{{ route('password.update.reset') }}" class="space-y-6">
            @csrf
            <input type="hidden" id="phone" name="phone" value="{{ $phone }}">
            <input type="hidden" id="otp" name="otp" value="{{ $otp }}">

            {{-- New Password --}}
            <div class="space-y-2">
                <label for="password" class="text-sm font-bold text-gray-700 ml-1">New Password</label>
                <div class="relative group">
                    <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                        <svg class="w-5 h-5 text-gray-400 group-focus-within:text-blue-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                    </div>
                    <input id="password" type="password" name="password" required autofocus
                        class="block w-full pl-11 pr-4 py-3 bg-gray-50 border border-gray-200 text-gray-900 text-sm rounded-xl focus:ring-2 focus:ring-blue-100 focus:border-blue-500 outline-none transition-all font-semibold"
                        placeholder="••••••••">
                </div>
                <p id="password-error" class="hidden text-xs font-semibold text-red-500 mt-1 flex items-center gap-1">
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                    <span></span>
                </p>
            </div>

            {{-- Confirm Password --}}
            <div class="space-y-2">
                <label for="password-confirm" class="text-sm font-bold text-gray-700 ml-1">Confirm Password</label>
                <div class="relative group">
                    <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                        <svg class="w-5 h-5 text-gray-400 group-focus-within:text-blue-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                    </div>
                    <input id="password-confirm" type="password" name="password_confirmation" required
                        class="block w-full pl-11 pr-4 py-3 bg-gray-50 border border-gray-200 text-gray-900 text-sm rounded-xl focus:ring-2 focus:ring-blue-100 focus:border-blue-500 outline-none transition-all font-semibold"
                        placeholder="••••••••">
                </div>
            </div>

            {{-- Submit --}}
            <button id="btn-reset" type="submit" class="w-full py-3.5 bg-blue-600 hover:bg-blue-700 text-white font-extrabold rounded-xl shadow-lg shadow-blue-200 transition-all hover:-translate-y-0.5 active:scale-[0.98] flex items-center justify-center gap-2">
                <span>Update Password</span>
                <svg id="spinner" class="hidden w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
            </button>
        </form>
    </div>

    <div class="mt-8 text-center">
        <p class="text-sm text-gray-400 font-medium">&copy; {{ date('Y') }} Manna Apartment. All rights reserved.</p>
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

    function showError(msg) {
        passwordError.querySelector('span').textContent = msg;
        passwordError.classList.remove('hidden');
    }
    function hideError() { passwordError.classList.add('hidden'); }

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

        btnReset.querySelector('span').textContent = 'Updating...';
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
            btnReset.querySelector('span').textContent = 'Update Password';
            spinner.classList.add('hidden');
            btnReset.disabled = false;
        }
    });
</script>
@endsection
