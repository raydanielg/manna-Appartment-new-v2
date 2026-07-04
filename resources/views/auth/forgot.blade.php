@extends('layouts.app')

@section('title', 'Forgot Password - Manna Apartment')

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
                    <svg class="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>
                </div>
                <h2 class="text-2xl font-extrabold text-white relative z-10">Forgot Password?</h2>
                <p class="text-emerald-100 text-sm mt-1 relative z-10">Enter your phone number to receive an OTP</p>
            </div>

            <div class="p-8">
                <div id="alert-success" class="hidden mb-4 p-3 rounded-lg bg-emerald-50 text-emerald-700 text-sm border border-emerald-100"></div>

                <form id="forgot-form" method="POST" action="{{ route('password.send.otp') }}" class="space-y-5">
                    @csrf
                    <div>
                        <label for="phone" class="block text-sm font-semibold text-gray-700 mb-1.5">Phone Number</label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none gap-2">
                                <svg class="w-6 h-4 rounded-sm shadow-sm" viewBox="0 0 900 600" xmlns="http://www.w3.org/2000/svg">
                                    <rect width="900" height="600" fill="#00a3dd"/>
                                    <path d="M0 600 L900 0 L900 600 Z" fill="#1eb53a"/>
                                    <path d="M0 600 L900 0" stroke="#000" stroke-width="140"/>
                                    <path d="M0 600 L900 0" stroke="#fcd116" stroke-width="100"/>
                                </svg>
                                <span class="text-sm text-gray-500 font-medium">+255</span>
                                <span class="text-gray-300">|</span>
                            </div>
                            <input id="phone" type="tel" name="phone" required autofocus maxlength="13"
                                class="w-full pl-[6.5rem] pr-4 py-2.5 rounded-lg border border-gray-200 focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200 outline-none transition-all text-sm tracking-wide"
                                placeholder="6XX XXX XXX">
                        </div>
                        <p id="phone-error" class="hidden mt-1.5 text-sm text-red-600 flex items-center gap-1"><svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg><span></span></p>
                    </div>

                    <button id="btn-send" type="submit" class="w-full py-3 text-sm font-bold text-gray-900 bg-gradient-to-r from-gold-300 to-gold-400 hover:from-gold-400 hover:to-gold-500 rounded-lg shadow-md hover:shadow-lg transition-all flex items-center justify-center gap-2">
                        <span>Send OTP</span>
                        <svg id="arrow-icon" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"/></svg>
                        <svg id="spinner" class="hidden w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
                    </button>
                </form>

                <p class="mt-6 text-center text-sm text-gray-500">
                    Remembered your password?
                    <a href="{{ route('login') }}" class="font-semibold text-emerald-600 hover:text-emerald-700 transition-colors">Sign in</a>
                </p>
            </div>
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
        let raw = phoneInput.value.replace(/\D/g, '');
        if (raw.length > 9) raw = raw.slice(0, 9);

        let formatted = raw.slice(0, 3);
        if (raw.length > 3) formatted += ' ' + raw.slice(3, 6);
        if (raw.length > 6) formatted += ' ' + raw.slice(6, 9);

        phoneInput.value = formatted;
        hideError();
    });

    forgotForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        hideError();
        const local = phoneInput.value.replace(/\D/g, '');
        const phone = '255' + local;
        if (!phone.match(/^255[67][0-9]{8}$/)) {
            showError('Enter a valid Tanzania phone number (e.g. 6XX XXX XXX)');
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
                alertSuccess.textContent = data.message || 'OTP sent successfully! Redirecting...';
                alertSuccess.classList.remove('hidden');
                alertSuccess.classList.add('animate__animated', 'animate__bounceIn');
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
