@extends('layouts.app')

@section('title', 'Privacy Policy - Manna Apartment')

@section('content')
<div class="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
    <!-- Hero -->
    <div class="bg-gradient-to-r from-blue-900 via-blue-800 to-blue-700 text-white">
        <div class="max-w-4xl mx-auto px-6 py-16">
            <div class="flex items-center gap-3 mb-6">
                <div class="w-12 h-12 bg-white rounded-xl flex items-center justify-center shadow-lg">
                    <svg class="w-7 h-7 text-blue-800" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.062-.18-2.087-.51-3.031z"/>
                    </svg>
                </div>
                <div>
                    <h1 class="text-3xl font-extrabold tracking-tight">Privacy Policy</h1>
                    <p class="text-blue-200 text-sm mt-1">Last updated: July 4, 2026</p>
                </div>
            </div>
            <p class="text-blue-100 text-lg max-w-2xl">
                Your privacy is important to us. This policy explains how Manna Apartment collects, uses, and protects your personal information.
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
                    <li><a href="#introduction" class="hover:text-blue-700 transition">1. Introduction</a></li>
                    <li><a href="#information" class="hover:text-blue-700 transition">2. Information We Collect</a></li>
                    <li><a href="#use" class="hover:text-blue-700 transition">3. How We Use Your Information</a></li>
                    <li><a href="#sharing" class="hover:text-blue-700 transition">4. Information Sharing & Disclosure</a></li>
                    <li><a href="#sms" class="hover:text-blue-700 transition">5. SMS Communications</a></li>
                    <li><a href="#data-security" class="hover:text-blue-700 transition">6. Data Security</a></li>
                    <li><a href="#cookies" class="hover:text-blue-700 transition">7. Cookies & Tracking</a></li>
                    <li><a href="#rights" class="hover:text-blue-700 transition">8. Your Privacy Rights</a></li>
                    <li><a href="#retention" class="hover:text-blue-700 transition">9. Data Retention</a></li>
                    <li><a href="#children" class="hover:text-blue-700 transition">10. Children's Privacy</a></li>
                    <li><a href="#changes" class="hover:text-blue-700 transition">11. Changes to This Policy</a></li>
                    <li><a href="#contact" class="hover:text-blue-700 transition">12. Contact Us</a></li>
                </ol>
            </div>

            <!-- 1. Introduction -->
            <section id="introduction">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">1</span>
                    Introduction
                </h2>
                <div class="prose prose-slate max-w-none text-slate-600 leading-relaxed space-y-4">
                    <p>Manna Apartment ("we", "us", or "our") operates a property management platform that connects landlords and tenants for seamless rental management. This Privacy Policy governs the collection, use, and processing of personal data within our web platform and mobile application.</p>
                    <p>By registering an account or using our services, you consent to the practices described in this policy. If you do not agree with these terms, please discontinue use of our platform immediately.</p>
                </div>
            </section>

            <!-- 2. Information We Collect -->
            <section id="information">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">2</span>
                    Information We Collect
                </h2>
                <div class="text-slate-600 leading-relaxed space-y-4">
                    <p>We collect the following categories of personal information:</p>
                    <div class="grid md:grid-cols-2 gap-4 mt-4">
                        <div class="bg-slate-50 rounded-xl p-5 border border-slate-200">
                            <h3 class="font-bold text-slate-900 mb-2">Account Information</h3>
                            <ul class="text-sm space-y-1 list-disc list-inside">
                                <li>Full name</li>
                                <li>Phone number</li>
                                <li>Email address (optional)</li>
                                <li>Password (encrypted)</li>
                                <li>Business name (landlords)</li>
                            </ul>
                        </div>
                        <div class="bg-slate-50 rounded-xl p-5 border border-slate-200">
                            <h3 class="font-bold text-slate-900 mb-2">Property Data</h3>
                            <ul class="text-sm space-y-1 list-disc list-inside">
                                <li>Property details and units</li>
                                <li>Tenant information</li>
                                <li>Lease/contract details</li>
                                <li>Payment records</li>
                                <li>Maintenance requests</li>
                            </ul>
                        </div>
                        <div class="bg-slate-50 rounded-xl p-5 border border-slate-200">
                            <h3 class="font-bold text-slate-900 mb-2">Usage Data</h3>
                            <ul class="text-sm space-y-1 list-disc list-inside">
                                <li>Device information</li>
                                <li>App usage patterns</li>
                                <li>Log data and timestamps</li>
                                <li>IP address</li>
                            </ul>
                        </div>
                        <div class="bg-slate-50 rounded-xl p-5 border border-slate-200">
                            <h3 class="font-bold text-slate-900 mb-2">Communications</h3>
                            <ul class="text-sm space-y-1 list-disc list-inside">
                                <li>SMS messages sent via platform</li>
                                <li>OTP verification codes</li>
                                <li>Support requests</li>
                                <li>Push notifications</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </section>

            <!-- 3. How We Use -->
            <section id="use">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">3</span>
                    How We Use Your Information
                </h2>
                <div class="text-slate-600 leading-relaxed space-y-3">
                    <p>We process your personal data for the following legitimate purposes:</p>
                    <ul class="space-y-2">
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span><strong>Service Delivery:</strong> Managing properties, tenants, contracts, payments, and maintenance requests.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span><strong>Authentication:</strong> Verifying your identity during registration and login via OTP.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span><strong>Communication:</strong> Sending SMS notifications, payment reminders, and important account alerts.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span><strong>Analytics:</strong> Understanding usage patterns to improve our platform and user experience.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span><strong>Legal Compliance:</strong> Meeting obligations under Tanzanian data protection regulations.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span><strong>Security:</strong> Detecting and preventing fraud, abuse, and unauthorized access.</span></li>
                    </ul>
                </div>
            </section>

            <!-- 4. Information Sharing -->
            <section id="sharing">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">4</span>
                    Information Sharing & Disclosure
                </h2>
                <div class="text-slate-600 leading-relaxed space-y-4">
                    <p>We do not sell, rent, or trade your personal data to third parties. We may share information in the following limited circumstances:</p>
                    <ul class="space-y-2">
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span><strong>SMS Service Providers:</strong> We use NextSMS (messaging-service.co.tz) to deliver SMS messages. Phone numbers and message content are transmitted to this provider for delivery purposes only.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span><strong>Landlord-Tenant Sharing:</strong> Landlords can view tenant information within their organization. This is limited to data necessary for rental management.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span><strong>Legal Requirements:</strong> When required by law, court order, or government authority under Tanzanian jurisdiction.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span><strong>Business Transfers:</strong> In the event of a merger, acquisition, or asset sale, data may be transferred under appropriate confidentiality terms.</span></li>
                    </ul>
                </div>
            </section>

            <!-- 5. SMS Communications -->
            <section id="sms">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">5</span>
                    SMS Communications
                </h2>
                <div class="bg-amber-50 border border-amber-200 rounded-xl p-6">
                    <div class="text-slate-700 leading-relaxed space-y-3">
                        <p>Our platform utilizes SMS messaging for critical communications including:</p>
                        <ul class="space-y-1 text-sm">
                            <li>&#8226; OTP verification codes during registration and password reset</li>
                            <li>&#8226; Payment confirmation and rent reminders</li>
                            <li>&#8226; Maintenance request updates</li>
                            <li>&#8226; Welcome messages upon account creation</li>
                        </ul>
                        <p class="text-sm">SMS messages are sent through NextSMS, a Tanzania-based messaging provider. Standard SMS rates may apply depending on your mobile carrier. All SMS communications are logged for audit and troubleshooting purposes.</p>
                    </div>
                </div>
            </section>

            <!-- 6. Data Security -->
            <section id="data-security">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">6</span>
                    Data Security
                </h2>
                <div class="text-slate-600 leading-relaxed space-y-4">
                    <p>We implement industry-standard security measures to protect your personal data:</p>
                    <div class="grid md:grid-cols-3 gap-4 mt-4">
                        <div class="text-center p-5 bg-green-50 rounded-xl border border-green-200">
                            <div class="w-12 h-12 bg-green-100 rounded-full mx-auto flex items-center justify-center mb-3">
                                <svg class="w-6 h-6 text-green-700" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                            </div>
                            <h3 class="font-bold text-slate-900 text-sm">Encryption</h3>
                            <p class="text-xs mt-1">Passwords hashed with bcrypt. HTTPS/TLS for all data transmission.</p>
                        </div>
                        <div class="text-center p-5 bg-blue-50 rounded-xl border border-blue-200">
                            <div class="w-12 h-12 bg-blue-100 rounded-full mx-auto flex items-center justify-center mb-3">
                                <svg class="w-6 h-6 text-blue-700" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.062-.18-2.087-.51-3.031z"/></svg>
                            </div>
                            <h3 class="font-bold text-slate-900 text-sm">Access Control</h3>
                            <p class="text-xs mt-1">Role-based permissions. API tokens with scoped abilities.</p>
                        </div>
                        <div class="text-center p-5 bg-purple-50 rounded-xl border border-purple-200">
                            <div class="w-12 h-12 bg-purple-100 rounded-full mx-auto flex items-center justify-center mb-3">
                                <svg class="w-6 h-6 text-purple-700" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/></svg>
                            </div>
                            <h3 class="font-bold text-slate-900 text-sm">Audit Logs</h3>
                            <p class="text-xs mt-1">All SMS and critical actions logged for accountability.</p>
                        </div>
                    </div>
                    <p class="mt-4">Despite our efforts, no method of transmission over the internet is 100% secure. We cannot guarantee absolute security but commit to promptly investigating and notifying affected users of any data breach.</p>
                </div>
            </section>

            <!-- 7. Cookies -->
            <section id="cookies">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">7</span>
                    Cookies & Tracking
                </h2>
                <div class="text-slate-600 leading-relaxed space-y-3">
                    <p>Our web platform uses essential cookies for session management and authentication. We do not use third-party advertising or tracking cookies. The mobile application does not use cookies.</p>
                </div>
            </section>

            <!-- 8. Your Rights -->
            <section id="rights">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">8</span>
                    Your Privacy Rights
                </h2>
                <div class="text-slate-600 leading-relaxed space-y-3">
                    <p>Under Tanzanian data protection principles, you have the following rights:</p>
                    <ul class="space-y-2">
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span><strong>Access:</strong> Request a copy of your personal data held by us.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span><strong>Rectification:</strong> Correct inaccurate or incomplete information.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span><strong>Erasure:</strong> Request deletion of your account and associated data.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span><strong>Restriction:</strong> Limit the processing of your data under certain conditions.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span><strong>Portability:</strong> Receive your data in a structured, machine-readable format.</span></li>
                        <li class="flex items-start gap-3"><span class="text-blue-600 mt-1">&#10003;</span><span><strong>Withdrawal:</strong> Withdraw consent for SMS communications at any time.</span></li>
                    </ul>
                    <p>To exercise any of these rights, contact us at <a href="mailto:support@manna.co.tz" class="text-blue-700 font-semibold hover:underline">support@manna.co.tz</a>.</p>
                </div>
            </section>

            <!-- 9. Data Retention -->
            <section id="retention">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">9</span>
                    Data Retention
                </h2>
                <div class="text-slate-600 leading-relaxed space-y-3">
                    <p>We retain your personal data for as long as your account is active or as necessary to provide our services. After account deletion, we may retain certain records for:</p>
                    <ul class="space-y-1 text-sm">
                        <li>&#8226; Financial records: 7 years (per Tanzanian tax regulations)</li>
                        <li>&#8226; SMS logs: 12 months for audit purposes</li>
                        <li>&#8226; Security logs: 6 months</li>
                        <li>&#8226; Contract/lease records: Duration of contract + 2 years</li>
                    </ul>
                </div>
            </section>

            <!-- 10. Children -->
            <section id="children">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">10</span>
                    Children's Privacy
                </h2>
                <div class="text-slate-600 leading-relaxed">
                    <p>Our services are intended for individuals 18 years and older. We do not knowingly collect personal information from minors. If you believe a child has provided us with personal data, please contact us immediately for prompt removal.</p>
                </div>
            </section>

            <!-- 11. Changes -->
            <section id="changes">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">11</span>
                    Changes to This Policy
                </h2>
                <div class="text-slate-600 leading-relaxed">
                    <p>We may update this Privacy Policy from time to time. Material changes will be communicated via SMS or in-app notification. The "Last updated" date at the top of this page indicates when the policy was last revised. Continued use of our services after changes constitutes acceptance of the updated policy.</p>
                </div>
            </section>

            <!-- 12. Contact -->
            <section id="contact">
                <h2 class="text-2xl font-bold text-slate-900 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 bg-blue-100 text-blue-800 rounded-lg flex items-center justify-center text-sm font-bold">12</span>
                    Contact Us
                </h2>
                <div class="bg-blue-50 rounded-xl p-6 border border-blue-200">
                    <div class="text-slate-700 space-y-2">
                        <p class="font-bold text-slate-900">Manna Apartment</p>
                        <p>For privacy-related inquiries, data requests, or concerns:</p>
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
                <a href="{{ route('terms') }}" class="text-sm text-blue-700 font-semibold hover:underline">View Terms of Service &rarr;</a>
            </div>
        </div>
    </div>
</div>
@endsection
