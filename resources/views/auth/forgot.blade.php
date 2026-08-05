@extends('layouts.app')

@section('title', 'Forgot Password - Manna Apartment')

@section('content')
<div class="w-full max-w-[420px] relative z-10" style="animation: simpleFadeIn 0.5s cubic-bezier(0.16, 1, 0.3, 1) both;">
    <div class="bg-white rounded-2xl shadow-sm border border-gray-200 p-8">
        {{-- Logo & Header --}}
        <div class="text-center mb-10">
            <div class="inline-flex items-center justify-center w-16 h-16 bg-blue-50 rounded-xl mb-6">
                <img src="{{ asset('file_000000001cdc7230acd3b9659475e375.png') }}" alt="Manna Apartment" class="w-12 h-12 object-cover rounded-lg">
            </div>
            <h2 class="text-2xl font-extrabold text-gray-900">Forgot Password</h2>
            <p class="text-gray-500 text-sm mt-2 font-medium">Enter your phone to receive an OTP code.</p>
        </div>

        <div id="alert-success" class="hidden mb-6 p-4 rounded-xl bg-blue-50 text-blue-700 text-sm border border-blue-100 font-bold flex items-center gap-2">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            <span></span>
        </div>

        <form id="forgot-form" method="POST" action="{{ route('password.send.otp') }}" class="space-y-6">
            @csrf

            {{-- Phone Number --}}
            <div class="space-y-2">
                <label for="phone" class="text-sm font-bold text-gray-700 ml-1">Phone Number</label>
                <div class="relative group">
                    <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                        <span class="text-sm font-bold text-gray-400 group-focus-within:text-blue-500 transition-colors">+255</span>
                        <div class="h-4 w-px bg-gray-200 mx-2 group-focus-within:bg-blue-200"></div>
                    </div>
                    <input id="phone" type="tel" name="phone" required autofocus 
                        maxlength="9"
                        class="block w-full pl-[4.5rem] pr-4 py-3 bg-gray-50 border border-gray-200 text-gray-900 text-sm rounded-xl focus:ring-2 focus:ring-blue-100 focus:border-blue-500 outline-none transition-all font-semibold"
                        placeholder="7XX XXX XXX">
                </div>
                <p id="phone-error" class="hidden text-xs font-semibold text-red-500 mt-1 flex items-center gap-1">
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                    <span></span>
                </p>
            </div>

            {{-- Submit --}}
            <button id="btn-send" type="submit" class="w-full py-3.5 bg-blue-600 hover:bg-blue-700 text-white font-extrabold rounded-xl shadow-lg shadow-blue-200 transition-all hover:-translate-y-0.5 active:scale-[0.98] flex items-center justify-center gap-2 disabled:bg-blue-600 disabled:opacity-80 disabled:cursor-not-allowed">
                <span>Send Code</span>
                <svg id="arrow-icon" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"/></svg>
                <svg id="spinner" class="hidden w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
            </button>
        </form>

        <div class="mt-8 text-center">
            <p class="text-sm text-gray-500 font-medium">
                Remembered your password?
                <a href="{{ route('login') }}" class="font-bold text-blue-600 hover:text-blue-700 ml-1">Sign in</a>
            </p>
        </div>
    </div>
</div>

<script>
    const phoneInput = document.getElementById('phone');
    const forgotForm = document.getElementById('forgot-form');
    const phoneError = document.getElementById('phone-error');
    const alertSuccess = document.getElementById('alert-success');
    const btnSend = document.getElementById('btn-send');
    const arrowIcon = document.getElementById('arrow-icon');
    const spinner = document.getElementById('spinner');

    function showError(msg) {
        phoneError.querySelector('span').textContent = msg;
        phoneError.classList.remove('hidden');
        phoneInput.classList.add('border-red-300', 'ring-2', 'ring-red-100');
        phoneInput.classList.remove('border-gray-200');
    }

    function hideError() {
        phoneError.classList.add('hidden');
        phoneInput.classList.remove('border-red-300', 'ring-2', 'ring-red-100');
        phoneInput.classList.add('border-gray-200');
    }

    phoneInput.addEventListener('input', () => {
        let val = phoneInput.value.replace(/\D/g, '');
        if (val.length > 9) val = val.slice(0, 9);
        phoneInput.value = val;
        hideError();
    });

    forgotForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        hideError();
        const local = phoneInput.value.replace(/\D/g, '');
        const phone = '255' + local;
        
        if (!phone.match(/^255[67][0-9]{8}$/)) {
            showError('Enter a valid phone number (e.g. 7XX XXX XXX)');
            return;
        }

        arrowIcon.classList.add('hidden');
        spinner.classList.remove('hidden');
        btnSend.disabled = true;

        try {
            const response = await fetch(forgotForm.action, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                },
                body: JSON.stringify({ phone })
            });
            const data = await response.json();

            if (response.ok) {
                alertSuccess.querySelector('span').textContent = data.message || 'OTP sent! Redirecting...';
                alertSuccess.classList.remove('hidden');
                setTimeout(() => {
                    window.location.href = '{{ route('password.verify.form') }}?phone=' + encodeURIComponent(phone);
                }, 1200);
            } else {
                showError(data.message || 'Phone number not found.');
            }
        } catch (err) {
            showError('Network error. Please try again.');
        } finally {
            arrowIcon.classList.remove('hidden');
            spinner.classList.add('hidden');
            btnSend.disabled = false;
        }
    });
</script>
@endsection
