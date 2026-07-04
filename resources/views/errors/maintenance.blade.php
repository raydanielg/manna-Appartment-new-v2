<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Under Maintenance - Manna Apartment</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.bunny.net/css?family=Nunito:400,600,700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Nunito', sans-serif; }
        @keyframes pulse { 0%,100% { opacity: 1; } 50% { opacity: 0.6; } }
        .pulse-dot { animation: pulse 2s infinite; }
    </style>
</head>
<body class="bg-emerald-900 min-h-screen flex items-center justify-center p-4">
    <div class="text-center text-white max-w-md">
        <div class="w-20 h-20 mx-auto bg-white/10 rounded-full flex items-center justify-center mb-6 pulse-dot">
            <svg class="w-10 h-10 text-gold-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
        </div>
        <h1 class="text-3xl font-bold mb-3">App Under Maintenance</h1>
        <p class="text-emerald-100 mb-6">We are currently performing scheduled maintenance. Please check back soon.</p>
        <a href="/login" class="inline-block px-6 py-2 bg-gold-400 text-gray-900 font-semibold rounded-lg hover:bg-gold-500 transition">Admin Login</a>
    </div>
</body>
</html>
