@extends('layouts.app')

@section('title', 'Forgot Password - Manna Apartment')

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
            <h2 class="text-3xl font-black text-gray-900 tracking-tight">Forgot Password</h2>
            <p class="text-gray-500 text-sm mt-3 font-semibold tracking-wide uppercase opacity-70">Security Recovery</p>
        </div>

        <div id="alert-success" class="hidden mb-8 p-5 rounded-2xl bg-blue-50/50 text-blue-700 text-sm border border-blue-100 font-bold flex items-center gap-3 backdrop-blur-sm">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            <span></span>
        </div>

        <form id="forgot-form" method="POST" action="{{ route('password.send.otp') }}" class="space-y-8">
            @csrf

            {{-- Phone Number --}}
            <div class="space-y-2.5">
                <label for="phone" class="text-[13px] font-black text-gray-400 uppercase tracking-widest ml-1">Phone Number</label>
                <div class="relative group">
                    <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                        <span class="text-sm font-bold text-gray-400 group-focus-within:text-blue-600 transition-colors">+255</span>
                        <div class="h-5 w-px bg-gray-200 mx-3 group-focus-within:bg-blue-200 transition-colors"></div>
                    </div>
                    <input id="phone" type="tel" name="phone" required autofocus 
                        maxlength="9"
                        class="block w-full pl-20 pr-4 py-4 bg-gray-50/50 border-2 border-gray-100 text-gray-900 text-base rounded-2xl focus:ring-4 focus:ring-blue-50 focus:border-blue-500 focus:bg-white outline-none transition-all font-bold placeholder:text-gray-300 shadow-sm"
                        placeholder="7XX XXX XXX">
                </div>
                <p id="phone-error" class="hidden text-xs font-bold text-red-500 mt-2 ml-1 flex items-center gap-1.5">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                    <span></span>
                </p>
            </div>

            {{-- Submit --}}
            <button id="btn-send" type="submit" class="w-full py-4.5 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white text-lg font-black rounded-2xl shadow-xl shadow-blue-200 transition-all hover:-translate-y-1 active:translate-y-0 active:scale-[0.98] flex items-center justify-center gap-3 disabled:opacity-80 disabled:cursor-not-allowed">
                <span id="btn-text">Send Recovery Code</span>
                <svg id="arrow-icon" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"/></svg>
                <svg id="spinner" class="hidden w-6 h-6 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
            </button>
        </form>

        <div class="mt-10 text-center">
            <p class="text-sm text-gray-500 font-bold">
                Back to
                <a href="{{ route('login') }}" class="text-blue-600 hover:text-blue-700 ml-1">Sign in</a>
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
    const btnText = document.getElementById('btn-text');

    function showError(msg) {
        phoneError.querySelector('span').textContent = msg;
        phoneError.classList.remove('hidden');
        phoneInput.classList.add('border-red-300', 'ring-4', 'ring-red-50');
        phoneInput.classList.remove('border-gray-100');
    }

    function hideError() {
        phoneError.classList.add('hidden');
        phoneInput.classList.remove('border-red-300', 'ring-4', 'ring-red-50');
        phoneInput.classList.add('border-gray-100');
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
            showError('Enter a valid Tanzania number (e.g. 7XX XXX XXX)');
            return;
        }

        btnText.textContent = 'Sending...';
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
                showError(data.message || 'Number not found.');
            }
        } catch (err) {
            showError('Network error. Please try again.');
        } finally {
            if (!alertSuccess.classList.contains('hidden')) {
                btnText.textContent = 'Success!';
            } else {
                btnText.textContent = 'Send Recovery Code';
                arrowIcon.classList.remove('hidden');
            }
            spinner.classList.add('hidden');
            btnSend.disabled = false;
        }
    });
</script>
@endsection
