@extends('layouts.app')

@section('title', 'Reset Password - Manna Apartment')

@section('content')
{{-- Animated dots --}}
<div class="fixed inset-0 pointer-events-none overflow-hidden">
    <div class="dot dot-lg dot-float" style="top:15%; left:12%; animation-delay:0s;"></div>
    <div class="dot dot-md dot-float2" style="top:30%; right:18%; animation-delay:1.5s;"></div>
    <div class="dot dot-sm dot-float" style="bottom:30%; left:20%; animation-delay:2.5s;"></div>
    <div class="dot dot-md dot-float2" style="bottom:20%; right:12%; animation-delay:0.8s;"></div>
    <div class="dot dot-lg dot-float" style="top:70%; right:25%; animation-delay:2s;"></div>
    <div class="dot dot-sm dot-float2" style="top:8%; left:55%; animation-delay:1.2s;"></div>
</div>

<div class="flex-1 flex items-center justify-center min-h-screen p-4 relative z-10">
    <div class="w-full max-w-md animate__animated animate__fadeInUp">
        <div class="glass-card rounded-2xl shadow-2xl border border-white/50 overflow-hidden">
            <div class="bg-gradient-to-br from-emerald-600 to-emerald-700 px-8 py-8 text-center relative overflow-hidden">
                <div class="absolute top-0 right-0 w-32 h-32 bg-white/5 rounded-full -mr-10 -mt-10"></div>
                <div class="absolute bottom-0 left-0 w-24 h-24 bg-gold-400/20 rounded-full -ml-10 -mb-10"></div>
                <div class="w-16 h-16 mx-auto bg-white/10 backdrop-blur-sm rounded-2xl flex items-center justify-center mb-4 relative z-10">
                    <svg class="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"/></svg>
                </div>
                <h2 class="text-2xl font-extrabold text-white relative z-10">Reset Password</h2>
                <p class="text-emerald-100 text-sm mt-1 relative z-10">Set a new password for your account</p>
            </div>

            <div class="p-8">
                <div id="alert-success" class="hidden mb-4 p-3 rounded-lg bg-emerald-50 text-emerald-700 text-sm border border-emerald-100"></div>

                <form id="reset-form" method="POST" action="{{ route('password.update.reset') }}" class="space-y-5">
                    @csrf
                    <input type="hidden" id="phone" name="phone" value="{{ $phone }}">
                    <input type="hidden" id="otp" name="otp" value="{{ $otp }}">

                    <div>
                        <label for="password" class="block text-sm font-semibold text-gray-700 mb-1.5">New Password</label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                                <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                            </div>
                            <input id="password" type="password" name="password" required
                                class="w-full pl-11 pr-4 py-2.5 rounded-lg border border-gray-200 focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200 outline-none transition-all text-sm"
                                placeholder="Enter new password">
                        </div>
                        <p id="password-error" class="hidden mt-1.5 text-sm text-red-600 flex items-center gap-1"><svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg><span></span></p>
                    </div>

                    <div>
                        <label for="password-confirm" class="block text-sm font-semibold text-gray-700 mb-1.5">Confirm Password</label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                                <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                            </div>
                            <input id="password-confirm" type="password" name="password_confirmation" required
                                class="w-full pl-11 pr-4 py-2.5 rounded-lg border border-gray-200 focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200 outline-none transition-all text-sm"
                                placeholder="Confirm new password">
                        </div>
                    </div>

                    <button id="btn-reset" type="submit" class="w-full py-3 text-sm font-bold text-gray-900 bg-gradient-to-r from-gold-300 to-gold-400 hover:from-gold-400 hover:to-gold-500 rounded-lg shadow-md hover:shadow-lg transition-all flex items-center justify-center gap-2">
                        <span>Reset Password</span>
                        <svg id="spinner" class="hidden w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
                    </button>
                </form>
            </div>
        </div>
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

        btnReset.querySelector('span').textContent = 'Resetting...';
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
                alertSuccess.textContent = result.message || 'Password reset successfully! Redirecting...';
                alertSuccess.classList.remove('hidden');
                alertSuccess.classList.add('animate__animated', 'animate__bounceIn');
                setTimeout(() => {
                    window.location.href = result.redirect || '{{ route('login') }}';
                }, 1500);
            } else {
                const msg = result.errors ? Object.values(result.errors).flat().join(' ') : (result.message || 'Failed to reset password.');
                showError(msg);
            }
        } catch (err) {
            showError('Network error. Please try again.');
        } finally {
            btnReset.querySelector('span').textContent = 'Reset Password';
            spinner.classList.add('hidden');
            btnReset.disabled = false;
        }
    });
</script>
@endsection
