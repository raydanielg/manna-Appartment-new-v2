@extends('layouts.app')

@section('title', 'Terms of Service - Manna Apartment')

@section('content')
<div class="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
    <!-- Hero -->
    <div class="bg-gradient-to-r from-blue-900 via-blue-800 to-blue-700 text-white">
        <div class="max-w-4xl mx-auto px-6 py-16">
            <div class="flex items-center gap-3 mb-6">
                <div class="w-12 h-12 bg-white rounded-xl flex items-center justify-center shadow-lg">
                    <svg class="w-7 h-7 text-blue-800" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
                    </svg>
                </div>
                <div>
                    <h1 class="text-3xl font-extrabold tracking-tight">Terms of Service</h1>
                    <p class="text-blue-200 text-sm mt-1">Last updated: July 4, 2026</p>
                </div>
            </div>
            <p class="text-blue-100 text-lg max-w-2xl">
                These terms govern your use of Manna Apartment's platform and services. Please read them carefully before creating an account.
            </p>
        </div>
    </div>

    <!-- Content -->
    <div class="max-w-4xl mx-auto px-6 py-12">
        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-8 md:p-12 space-y-10">

            <!-- Table of Contents -->
            <div class="bg-blue-50 rounded-xl p-6 border border-blue-100">
                <h2 class="text-sm font-bold text-blue-900 uppercase tracking-wider mb-4">Table of Contents</h2>
                <ol class="space-y-2 text-sm text-slate-700">
                    <li><a href="#acceptance" class="hover:text-blue-700 transition">1. Acceptance of Terms</a></li>
                    <li><a href="#definitions" class="hover:text-blue-700 transition">2. Definitions</a></li>
                    <li><a href="#accounts" class="hover:text-blue-700 transition">3. Account Registration & Responsibilities</a></li>
                    <li><a href="#landlord" class="hover:text-blue-700 transition">4. Landlord Obligations</a></li>
                    <li><a href="#tenant" class="hover:text-blue-700 transition">5. Tenant Obligations</a></li>
                    <li><a href="#sms" class="hover:text-blue-700 transition">6. SMS & Communication Policy</a></li>
                    <li><a href="#payments" class="hover:text-blue-700 transition">7. Payments & Fees</a></li>
                    <li><a href="#prohibited" class="hover:text-blue-700 transition">8. Prohibited Conduct</a></li>
                    <li><a href="#ip" class="hover:text-blue-700 transition">9. Intellectual Property</a></li>
                    <li><a href="#disclaimer" class="hover:text-blue-700 transition">10. Disclaimer of Warranties</a></li>
                    <li><a href="#liability" class="hover:text-blue-700 transition">11. Limitation of Liability</a></li>
                    <li><a href="#indemnification" class="hover:text-blue-700 transition">12. Indemnification</a></li>
                    <li><a href="#termination" class="hover:text-blue-700 transition">13. Account Termination</a></li>
                    <li><a href="#governing" class="hover:text-blue-700 transition">14. Governing Law</a></li>
                    <li><a href="#changes" class="hover:text-blue-700 transition">15. Changes to Terms</a></li>
                    <li><a href="#contact" class="hover:text-blue-700 transition">16. Contact Us</a></li>
                </ol>
            </div>

            <!-- 1. Acceptance -->
            <section id="acceptance">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">1</span>
                    Acceptance of Terms
                </h2>
                <div class="text-slate-600 leading-relaxed space-y-4">
                    <p>By downloading the Manna Apartment mobile application, registering an account on our web platform, or otherwise accessing any of our services, you agree to be bound by these Terms of Service and our Privacy Policy.</p>
                    <p>If you do not agree to these terms, you must not register, access, or use any part of our platform. These terms constitute a legally binding agreement between you and Manna Apartment.</p>
                </div>
            </section>

            <!-- 2. Definitions -->
            <section id="definitions">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">2</span>
                    Definitions
                </h2>
                <div class="text-slate-600 leading-relaxed">
                    <div class="bg-slate-50 rounded-xl p-6 border border-slate-200 space-y-3 text-sm">
                        <p><strong class="text-slate-900">"Platform"</strong> refers to the Manna Apartment web application and mobile application collectively.</p>
                        <p><strong class="text-slate-900">"Landlord"</strong> refers to a registered user who owns or manages properties and leases units to tenants.</p>
                        <p><strong class="text-slate-900">"Tenant"</strong> refers to a user who rents or occupies a property unit managed through the platform.</p>
                        <p><strong class="text-slate-900">"Organization"</strong> refers to a landlord's business entity registered on the platform.</p>
                        <p><strong class="text-slate-900">"SMS Credits"</strong> refers to the messaging balance allocated to an organization for sending SMS communications.</p>
                        <p><strong class="text-slate-900">"We", "Us", "Our"</strong> refers to Manna Apartment, its operators, and authorized representatives.</p>
                    </div>
                </div>
            </section>

            <!-- 3. Accounts -->
            <section id="accounts">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">3</span>
                    Account Registration & Responsibilities
                </h2>
                <div class="text-slate-600 leading-relaxed space-y-3">
                    <p>To use our platform, you must:</p>
                    <ul class="space-y-2">
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Be at least 18 years of age and legally capable of entering into binding contracts.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Provide accurate, complete, and current information during registration.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Maintain the confidentiality of your password and account credentials.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Accept responsibility for all activities conducted under your account.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Notify us immediately of any unauthorized account access or security breach.</span></li>
                    </ul>
                    <p class="bg-red-50 border border-red-200 rounded-lg p-4 text-sm">One person or entity may not maintain multiple accounts. Creating duplicate accounts may result in suspension without notice.</p>
                </div>
            </section>

            <!-- 4. Landlord Obligations -->
            <section id="landlord">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">4</span>
                    Landlord Obligations
                </h2>
                <div class="text-slate-600 leading-relaxed space-y-3">
                    <p>As a landlord using our platform, you agree to:</p>
                    <ul class="space-y-2">
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Maintain valid ownership or legal authority to manage all properties listed on the platform.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Provide truthful and accurate property details, including unit specifications, pricing, and availability.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Comply with all Tanzanian tenancy laws, including the Land Act and Rent Restriction Act.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Respect tenant privacy and obtain consent before sharing tenant information.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Use SMS communications responsibly and only for legitimate rental management purposes.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Complete KYC verification when requested by the platform administrators.</span></li>
                    </ul>
                </div>
            </section>

            <!-- 5. Tenant Obligations -->
            <section id="tenant">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">5</span>
                    Tenant Obligations
                </h2>
                <div class="text-slate-600 leading-relaxed space-y-3">
                    <p>As a tenant on the platform, you agree to:</p>
                    <ul class="space-y-2">
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Pay rent and applicable fees on time as agreed in your lease contract.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Use the property for its intended residential or commercial purpose.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Report maintenance issues promptly through the platform.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Not sublet or assign the property without landlord consent.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Comply with all building rules and regulations set by the landlord.</span></li>
                    </ul>
                </div>
            </section>

            <!-- 6. SMS Policy -->
            <section id="sms">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">6</span>
                    SMS & Communication Policy
                </h2>
                <div class="bg-amber-50 border border-amber-200 rounded-xl p-6 space-y-3">
                    <div class="text-slate-700 leading-relaxed">
                        <p>The platform uses SMS messaging through NextSMS for various communications. By using our services, you acknowledge and agree that:</p>
                        <ul class="space-y-2 mt-3 text-sm">
                            <li class="flex items-start gap-2"><span class="text-amber-600 mt-1">&#9888;</span><span>You will receive OTP codes via SMS for account verification and password resets.</span></li>
                            <li class="flex items-start gap-2"><span class="text-amber-600 mt-1">&#9888;</span><span>Landlords will receive payment confirmations, maintenance alerts, and system notifications.</span></li>
                            <li class="flex items-start gap-2"><span class="text-amber-600 mt-1">&#9888;</span><span>Tenants will receive rent reminders, payment receipts, and maintenance updates.</span></li>
                            <li class="flex items-start gap-2"><span class="text-amber-600 mt-1">&#9888;</span><span>SMS messages are delivered via a third-party provider (NextSMS) and standard carrier rates may apply.</span></li>
                            <li class="flex items-start gap-2"><span class="text-amber-600 mt-1">&#9888;</span><span>We are not liable for SMS delivery failures or delays caused by the mobile network operator.</span></li>
                            <li class="flex items-start gap-2"><span class="text-amber-600 mt-1">&#9888;</span><span>SMS content must not contain abusive, illegal, or fraudulent material.</span></li>
                        </ul>
                        <p class="mt-3 text-sm">Landlords are allocated SMS credits per organization. Misuse of SMS functionality may result in suspension of messaging privileges.</p>
                    </div>
                </div>
            </section>

            <!-- 7. Payments -->
            <section id="payments">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">7</span>
                    Payments & Fees
                </h2>
                <div class="text-slate-600 leading-relaxed space-y-3">
                    <p>The platform may charge fees for certain services, including SMS credits and premium features. The following terms apply:</p>
                    <ul class="space-y-2">
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>All fees are displayed in Tanzanian Shillings (TZS) unless otherwise stated.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>SMS credits are non-refundable once purchased.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Payment records within the platform are for tracking purposes and do not constitute financial advice.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Landlords are responsible for collecting rent from tenants directly; the platform facilitates tracking only.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>We reserve the right to adjust pricing with 30 days' notice via SMS or email.</span></li>
                    </ul>
                </div>
            </section>

            <!-- 8. Prohibited -->
            <section id="prohibited">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">8</span>
                    Prohibited Conduct
                </h2>
                <div class="text-slate-600 leading-relaxed space-y-3">
                    <p>You are strictly prohibited from engaging in any of the following activities on the platform:</p>
                    <div class="grid md:grid-cols-2 gap-3 mt-3">
                        <div class="bg-red-50 rounded-lg p-4 border border-red-200">
                            <ul class="text-sm space-y-2">
                                <li class="flex items-start gap-2"><span class="text-red-500 mt-1">&#10007;</span><span>Listing fraudulent or non-existent properties</span></li>
                                <li class="flex items-start gap-2"><span class="text-red-500 mt-1">&#10007;</span><span>Harassing or threatening other users via SMS or platform</span></li>
                                <li class="flex items-start gap-2"><span class="text-red-500 mt-1">&#10007;</span><span>Attempting to reverse engineer or breach platform security</span></li>
                                <li class="flex items-start gap-2"><span class="text-red-500 mt-1">&#10007;</span><span>Using the platform for money laundering or illegal activities</span></li>
                            </ul>
                        </div>
                        <div class="bg-red-50 rounded-lg p-4 border border-red-200">
                            <ul class="text-sm space-y-2">
                                <li class="flex items-start gap-2"><span class="text-red-500 mt-1">&#10007;</span><span>Sharing account credentials with unauthorized persons</span></li>
                                <li class="flex items-start gap-2"><span class="text-red-500 mt-1">&#10007;</span><span>Sending spam or unsolicited commercial SMS messages</span></li>
                                <li class="flex items-start gap-2"><span class="text-red-500 mt-1">&#10007;</span><span>Uploading malicious code or harmful content</span></li>
                                <li class="flex items-start gap-2"><span class="text-red-500 mt-1">&#10007;</span><span>Impersonating another person or entity</span></li>
                            </ul>
                        </div>
                    </div>
                    <p class="text-sm">Violations may result in immediate account suspension, data removal, and potential legal action under Tanzanian law.</p>
                </div>
            </section>

            <!-- 9. IP -->
            <section id="ip">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">9</span>
                    Intellectual Property
                </h2>
                <div class="text-slate-600 leading-relaxed space-y-3">
                    <p>All platform content, including the Manna Apartment name, logo, software, design, and documentation, is the exclusive property of Manna Apartment and is protected under Tanzanian intellectual property laws.</p>
                    <p>You may not copy, modify, distribute, or create derivative works from any part of the platform without prior written consent. User-generated content (property listings, photos) remains the property of the respective users, who grant us a license to display it within the platform.</p>
                </div>
            </section>

            <!-- 10. Disclaimer -->
            <section id="disclaimer">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">10</span>
                    Disclaimer of Warranties
                </h2>
                <div class="bg-slate-50 rounded-xl p-6 border border-slate-200 text-slate-600 leading-relaxed space-y-3">
                    <p>The platform is provided on an "as is" and "as available" basis without warranties of any kind, either express or implied, including but not limited to:</p>
                    <ul class="space-y-1 text-sm">
                        <li>&#8226; Warranties of merchantability or fitness for a particular purpose</li>
                        <li>&#8226; Guarantees that the platform will be uninterrupted or error-free</li>
                        <li>&#8226; Assurance that SMS messages will always be delivered</li>
                        <li>&#8226; Verification of the accuracy or completeness of user-submitted property data</li>
                    </ul>
                    <p>We do not endorse, verify, or guarantee the legitimacy of any property listing, tenant, or landlord on the platform. Users conduct their own due diligence before entering into rental agreements.</p>
                </div>
            </section>

            <!-- 11. Liability -->
            <section id="liability">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">11</span>
                    Limitation of Liability
                </h2>
                <div class="text-slate-600 leading-relaxed space-y-3">
                    <p>To the fullest extent permitted by Tanzanian law, Manna Apartment shall not be liable for:</p>
                    <ul class="space-y-2">
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Indirect, incidental, special, consequential, or punitive damages arising from platform use.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Loss of profits, data, business opportunities, or rental income.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Disputes between landlords and tenants, including unpaid rent or property damage.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>SMS delivery failures or delays by third-party providers or network operators.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span>Platform downtime due to maintenance, system upgrades, or events beyond our control.</span></li>
                    </ul>
                    <p>Our total liability for any claim shall not exceed the amount paid by the user for platform services in the three (3) months preceding the claim.</p>
                </div>
            </section>

            <!-- 12. Indemnification -->
            <section id="indemnification">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">12</span>
                    Indemnification
                </h2>
                <div class="text-slate-600 leading-relaxed">
                    <p>You agree to indemnify and hold harmless Manna Apartment, its operators, employees, and partners from any claims, damages, losses, or expenses (including legal fees) arising from:</p>
                    <ul class="space-y-1 mt-3 text-sm">
                        <li>&#8226; Your use or misuse of the platform</li>
                        <li>&#8226; Your violation of these Terms of Service</li>
                        <li>&#8226; Your infringement of any third-party rights</li>
                        <li>&#8226; Any dispute between you and another platform user</li>
                        <li>&#8226; Any inaccurate or misleading information you provide</li>
                    </ul>
                </div>
            </section>

            <!-- 13. Termination -->
            <section id="termination">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">13</span>
                    Account Termination
                </h2>
                <div class="text-slate-600 leading-relaxed space-y-3">
                    <p>You may terminate your account at any time by contacting support. Upon termination:</p>
                    <ul class="space-y-1 text-sm">
                        <li>&#8226; Your access to the platform will be immediately revoked</li>
                        <li>&#8226; Your data will be retained per our Privacy Policy and legal requirements</li>
                        <li>&#8226; Any outstanding SMS credits will be forfeited</li>
                        <li>&#8226; Active lease contracts remain valid and are not affected by account termination</li>
                    </ul>
                    <p class="bg-red-50 border border-red-200 rounded-lg p-4 text-sm">We reserve the right to suspend or terminate accounts that violate these terms, engage in fraudulent activity, or pose a risk to other users or the platform. Such termination may occur without prior notice.</p>
                </div>
            </section>

            <!-- 14. Governing Law -->
            <section id="governing">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">14</span>
                    Governing Law
                </h2>
                <div class="text-slate-600 leading-relaxed space-y-3">
                    <p>These Terms of Service are governed by the laws of the United Republic of Tanzania. Any disputes arising from or relating to these terms shall be resolved in the courts of Tanzania, with jurisdiction in Dar es Salaam, unless otherwise required by mandatory consumer protection laws.</p>
                    <p>The United Nations Convention on Contracts for the International Sale of Goods (CISG) shall not apply to these terms.</p>
                </div>
            </section>

            <!-- 15. Changes -->
            <section id="changes">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">15</span>
                    Changes to Terms
                </h2>
                <div class="text-slate-600 leading-relaxed">
                    <p>We reserve the right to modify these Terms of Service at any time. Material changes will be communicated via SMS, email, or in-app notification at least 30 days before taking effect. The "Last updated" date indicates when terms were last revised. Continued use of the platform after changes constitutes acceptance of the updated terms.</p>
                </div>
            </section>

            <!-- 16. Contact -->
            <section id="contact">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">16</span>
                    Contact Us
                </h2>
                <div class="bg-blue-50 rounded-xl p-6 border border-blue-200">
                    <div class="text-slate-700 space-y-2">
                        <p class="font-bold text-slate-900">Manna Apartment</p>
                        <p>For questions, legal inquiries, or support regarding these Terms:</p>
                        <div class="flex flex-col gap-1 mt-3 text-sm">
                            <p><span class="font-semibold">Email:</span> <a href="mailto:support@manna.co.tz" class="text-blue-700 hover:underline">support@manna.co.tz</a></p>
                            <p><span class="font-semibold">Website:</span> <a href="https://app.manna.co.tz" class="text-blue-700 hover:underline">https://app.manna.co.tz</a></p>
                            <p><span class="font-semibold">Phone:</span> +255 700 000 000</p>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Footer Links -->
            <div class="border-t border-slate-200 pt-6 flex flex-col sm:flex-row justify-between items-center gap-4">
                <p class="text-sm text-slate-500">&copy; 2026 Manna Apartment. All rights reserved.</p>
                <a href="{{ route('privacy') }}" class="text-sm text-blue-700 font-semibold hover:underline">View Privacy Policy &rarr;</a>
            </div>
        </div>
    </div>
</div>
@endsection
