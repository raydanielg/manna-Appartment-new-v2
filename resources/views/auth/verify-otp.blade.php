@extends('layouts.app')

@section('title', 'Verify OTP - Manna Apartment')

@section('content')
<div class="w-full max-w-[420px] relative z-10" style="animation: simpleFadeIn 0.5s cubic-bezier(0.16, 1, 0.3, 1) both;">
    <div class="bg-white rounded-2xl shadow-sm border border-gray-200 p-8">
        {{-- Logo & Header --}}
        <div class="text-center mb-10">
            <div class="inline-flex items-center justify-center w-16 h-16 bg-blue-50 rounded-xl mb-6">
                <img src="{{ asset('file_000000001cdc7230acd3b9659475e375.png') }}" alt="Manna Apartment" class="w-12 h-12 object-cover rounded-lg">
            </div>
            <h2 class="text-2xl font-extrabold text-gray-900">Verify Code</h2>
            <p class="text-gray-500 text-sm mt-2 font-medium">Enter the 6-digit code we sent to <span class="text-blue-600 font-bold">+{{ $phone }}</span></p>
        </div>

        <div id="alert-success" class="hidden mb-6 p-4 rounded-xl bg-blue-50 text-blue-700 text-sm border border-blue-100 font-bold flex items-center gap-2">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            <span></span>
        </div>

        <form id="verify-form" method="POST" action="{{ route('password.verify.otp') }}" class="space-y-6">
            @csrf
            <input type="hidden" id="phone" name="phone" value="{{ $phone }}">

            {{-- OTP Code --}}
            <div class="space-y-2">
                <label for="otp" class="text-sm font-bold text-gray-700 ml-1">OTP Code</label>
                <div class="relative">
                    <input id="otp" type="text" name="otp" value="{{ old('otp') }}" required maxlength="6"
                        class="block w-full px-4 py-4 bg-gray-50 border border-gray-200 text-gray-900 text-2xl rounded-xl focus:ring-2 focus:ring-blue-100 focus:border-blue-500 outline-none transition-all font-extrabold tracking-[0.6em] text-center"
                        placeholder="000000" autocomplete="one-time-code">
                </div>
                <p id="otp-error" class="hidden text-xs font-semibold text-red-500 mt-1 flex items-center gap-1">
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                    <span></span>
                </p>
            </div>

            {{-- Submit --}}
            <button id="btn-verify" type="submit" class="w-full py-3.5 bg-blue-600 hover:bg-blue-700 text-white font-extrabold rounded-xl shadow-lg shadow-blue-200 transition-all hover:-translate-y-0.5 active:scale-[0.98] flex items-center justify-center gap-2 disabled:bg-blue-600 disabled:opacity-80 disabled:cursor-not-allowed">
                <span>Verify Code</span>
                <svg id="spinner" class="hidden w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
            </button>
        </form>

        <div class="mt-8 text-center">
            <p class="text-sm text-gray-500 font-medium">
                Didn't receive code?
                <a href="{{ route('password.request') }}" class="font-bold text-blue-600 hover:text-blue-700 ml-1">Resend</a>
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

    function showError(msg) {
        otpError.querySelector('span').textContent = msg;
        otpError.classList.remove('hidden');
    }
    function hideError() { otpError.classList.add('hidden'); }

    otpInput.addEventListener('input', () => {
        let val = otpInput.value.replace(/\D/g, '');
        if (val.length > 6) val = val.slice(0, 6);
        otpInput.value = val;
        hideError();
        
        if (val.length === 6) {
            // Auto-submit if needed, but manual is safer for now
        }
    });

    verifyForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        hideError();
        const otp = otpInput.value.trim();
        if (!otp.match(/^[0-9]{6}$/)) {
            showError('Enter the 6-digit code');
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
                alertSuccess.querySelector('span').textContent = data.message || 'OTP verified! Redirecting...';
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
            btnVerify.querySelector('span').textContent = 'Verify Code';
            spinner.classList.add('hidden');
            btnVerify.disabled = false;
        }
    });
</script>
@endsection
