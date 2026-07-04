@extends('layouts.app')

@section('title', 'Verify OTP - Manna Apartment')

@section('content')
<div class="w-full max-w-md" style="animation: simpleFadeIn 0.4s ease-out both;">
    <div class="bg-white rounded-2xl shadow-xl border border-gray-100 overflow-hidden">
            <div class="bg-gradient-to-br from-emerald-600 to-emerald-700 px-8 py-8 text-center relative overflow-hidden">
                <div class="absolute top-0 right-0 w-32 h-32 bg-white/5 rounded-full -mr-10 -mt-10"></div>
                <div class="absolute bottom-0 left-0 w-24 h-24 bg-gold-400/20 rounded-full -ml-10 -mb-10"></div>
                <div class="w-20 h-20 mx-auto bg-white/10 backdrop-blur-sm rounded-2xl flex items-center justify-center mb-4 overflow-hidden">
                    <img src="{{ asset('file_000000001cdc7230acd3b9659475e375.png') }}" alt="Manna Apartment" class="w-16 h-16 object-cover rounded-2xl">
                </div>
                <h2 class="text-2xl font-extrabold text-white relative z-10">Verify OTP</h2>
                <p class="text-emerald-100 text-sm mt-1 relative z-10">Enter the 6-digit code sent to <span class="font-semibold">+{{ $phone }}</span></p>
            </div>

            <div class="p-8">
                <div id="alert-success" class="hidden mb-4 p-3 rounded-lg bg-emerald-50 text-emerald-700 text-sm border border-emerald-100"></div>

                <form id="verify-form" method="POST" action="{{ route('password.verify.otp') }}" class="space-y-5">
                    @csrf
                    <input type="hidden" id="phone" name="phone" value="{{ $phone }}">

                    <div>
                        <label for="otp" class="block text-sm font-semibold text-gray-700 mb-1.5">OTP Code</label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                                <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                            </div>
                            <input id="otp" type="text" name="otp" value="{{ old('otp') }}" required maxlength="6"
                                class="w-full pl-11 pr-4 py-2.5 rounded-lg border border-gray-200 focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200 outline-none transition-all text-sm tracking-[0.5em] text-center"
                                placeholder="000000">
                        </div>
                        <p id="otp-error" class="hidden mt-1.5 text-sm text-red-600 flex items-center gap-1"><svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg><span></span></p>
                    </div>

                    <button id="btn-verify" type="submit" class="w-full py-3 text-sm font-bold text-gray-900 bg-gradient-to-r from-gold-300 to-gold-400 hover:from-gold-400 hover:to-gold-500 rounded-lg shadow-md hover:shadow-lg transition-all flex items-center justify-center gap-2">
                        <span>Verify OTP</span>
                        <svg id="spinner" class="hidden w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
                    </button>
                </form>

                <p class="mt-6 text-center text-sm text-gray-500">
                    Didn't receive code?
                    <a href="{{ route('password.request') }}" class="font-semibold text-emerald-600 hover:text-emerald-700 transition-colors">Resend</a>
                </p>
            </div>
        </div>
    </div>
</div>

<script>
    const verifyForm = document.getElementById('verify-form');
    const otpInput = document.getElementById('otp');
    const phoneInput = document.getElementById('phone');
    const btnVerify = document.getElementById('btn-verify');
    const spinner = document.getElementById('spinner');
    const otpError = document.getElementById('otp-error');
    const alertSuccess = document.getElementById('alert-success');

    function showError(msg) {
        otpError.querySelector('span').textContent = msg;
        otpError.classList.remove('hidden');
    }
    function hideError() { otpError.classList.add('hidden'); }

    verifyForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        hideError();
        const otp = otpInput.value.replace(/\s/g, '');
        if (!otp.match(/^[0-9]{6}$/)) {
            showError('Enter the 6-digit OTP code');
            return;
        }

        btnVerify.querySelector('span').textContent = 'Verifying...';
        spinner.classList.remove('hidden');
        btnVerify.disabled = true;

        try {
            const response = await fetch(verifyForm.action, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                },
                body: JSON.stringify({ phone: phoneInput.value, otp })
            });
            const data = await response.json();

            if (response.ok) {
                alertSuccess.textContent = data.message || 'OTP verified! Redirecting...';
                alertSuccess.classList.remove('hidden');
                alertSuccess.classList.add('animate__animated', 'animate__bounceIn');
                setTimeout(() => {
                    window.location.href = '{{ route('password.reset.form') }}?phone=' + encodeURIComponent(phoneInput.value) + '&otp=' + encodeURIComponent(otp);
                }, 1000);
            } else {
                showError(data.message || 'Invalid or expired OTP.');
            }
        } catch (err) {
            showError('Network error. Please try again.');
        } finally {
            btnVerify.querySelector('span').textContent = 'Verify OTP';
            spinner.classList.add('hidden');
            btnVerify.disabled = false;
        }
    });
</script>
@endsection
