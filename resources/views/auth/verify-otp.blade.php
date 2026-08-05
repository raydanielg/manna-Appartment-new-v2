@extends('layouts.app')

@section('title', 'Verify OTP - Manna Apartment')

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
            <h2 class="text-3xl font-black text-gray-900 tracking-tight">Verify Code</h2>
            <p class="text-gray-500 text-sm mt-3 font-semibold tracking-wide uppercase opacity-70">Security Check</p>
            <p class="text-xs text-gray-400 mt-2 font-bold">Sent to <span class="text-blue-600">+{{ $phone }}</span></p>
        </div>

        <div id="alert-success" class="hidden mb-8 p-5 rounded-2xl bg-blue-50/50 text-blue-700 text-sm border border-blue-100 font-bold flex items-center gap-3 backdrop-blur-sm">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            <span></span>
        </div>

        <form id="verify-form" method="POST" action="{{ route('password.verify.otp') }}" class="space-y-8">
            @csrf
            <input type="hidden" id="phone" name="phone" value="{{ $phone }}">

            {{-- OTP Code --}}
            <div class="space-y-4">
                <label for="otp" class="text-[13px] font-black text-gray-400 uppercase tracking-widest ml-1 text-center block">Enter 6-Digit Code</label>
                <div class="relative">
                    <input id="otp" type="text" name="otp" value="{{ old('otp') }}" required maxlength="6"
                        class="block w-full px-4 py-5 bg-gray-50/50 border-2 border-gray-100 text-gray-900 text-3xl rounded-2xl focus:ring-4 focus:ring-blue-50 focus:border-blue-500 focus:bg-white outline-none transition-all font-black tracking-[0.6em] text-center shadow-sm placeholder:text-gray-200"
                        placeholder="000000" autocomplete="one-time-code">
                </div>
                <p id="otp-error" class="hidden text-xs font-bold text-red-500 mt-2 text-center flex items-center justify-center gap-1.5">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                    <span></span>
                </p>
            </div>

            {{-- Submit --}}
            <button id="btn-verify" type="submit" class="w-full py-4.5 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white text-lg font-black rounded-2xl shadow-xl shadow-blue-200 transition-all hover:-translate-y-1 active:translate-y-0 active:scale-[0.98] flex items-center justify-center gap-3 disabled:opacity-80 disabled:cursor-not-allowed">
                <span id="btn-text">Verify & Continue</span>
                <svg id="spinner" class="hidden w-6 h-6 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
            </button>
        </form>

        <div class="mt-10 text-center">
            <p class="text-sm text-gray-500 font-bold">
                Didn't get the code?
                <a href="{{ route('password.request') }}" class="text-blue-600 hover:text-blue-700 ml-1">Resend</a>
            </p>
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
    const btnText = document.getElementById('btn-text');

    function showError(msg) {
        otpError.querySelector('span').textContent = msg;
        otpError.classList.remove('hidden');
        otpInput.classList.add('border-red-300', 'ring-4', 'ring-red-50');
        otpInput.classList.remove('border-gray-100');
    }
    function hideError() { 
        otpError.classList.add('hidden');
        otpInput.classList.remove('border-red-300', 'ring-4', 'ring-red-50');
        otpInput.classList.add('border-gray-100');
    }

    otpInput.addEventListener('input', () => {
        let val = otpInput.value.replace(/\D/g, '');
        if (val.length > 6) val = val.slice(0, 6);
        otpInput.value = val;
        hideError();
    });

    verifyForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        hideError();
        const otp = otpInput.value.trim();
        if (!otp.match(/^[0-9]{6}$/)) {
            showError('Enter the 6-digit code');
            return;
        }

        btnText.textContent = 'Verifying...';
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
                alertSuccess.querySelector('span').textContent = data.message || 'Verified! Redirecting...';
                alertSuccess.classList.remove('hidden');
                setTimeout(() => {
                    window.location.href = '{{ route('password.reset.form') }}?phone=' + encodeURIComponent(phoneInput.value) + '&otp=' + encodeURIComponent(otp);
                }, 1000);
            } else {
                showError(data.message || 'Invalid or expired code.');
            }
        } catch (err) {
            showError('Network error. Please try again.');
        } finally {
            if (alertSuccess.classList.contains('hidden')) {
                btnText.textContent = 'Verify & Continue';
                spinner.classList.add('hidden');
                btnVerify.disabled = false;
            } else {
                btnText.textContent = 'Verified!';
                spinner.classList.add('hidden');
            }
        }
    });
</script>
@endsection
