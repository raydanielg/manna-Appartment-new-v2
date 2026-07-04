<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', config('app.name', 'Manna Apartment'))</title>
    <link rel="dns-prefetch" href="//fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=Nunito:400,500,600,700,800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css">
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        emerald: { 50:'#e6f5f1',100:'#b3e0d4',200:'#80cbc0',300:'#4db5a8',400:'#1a9f8e',500:'#024938',600:'#023d30',700:'#013028',800:'#01241f',900:'#001816' },
                        gold: { 50:'#fff5e0',100:'#ffe6b3',200:'#ffd680',300:'#ffc64d',400:'#ffb71a',500:'#f9ac00',600:'#d49700',700:'#b07c00',800:'#8c6100',900:'#684600' }
                    }
                }
            }
        }
    </script>
    <style>
        @keyframes fadeIn { from { opacity:0; transform: translateY(10px); } to { opacity:1; transform: translateY(0); } }
        .animate-fade { animation: fadeIn 0.4s ease-out both; }
        @keyframes float { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-20px); } }
        @keyframes float2 { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-15px); } }
        @keyframes pulseDot { 0%,100% { opacity: 0.3; transform: scale(1); } 50% { opacity: 0.8; transform: scale(1.1); } }
        .dot { position: absolute; border-radius: 50%; background: linear-gradient(135deg, #024938, #4db5a8); opacity: 0.25; animation: pulseDot 4s ease-in-out infinite; }
        .dot-sm { width: 8px; height: 8px; }
        .dot-md { width: 16px; height: 16px; }
        .dot-lg { width: 28px; height: 28px; }
        .dot-float { animation: float 6s ease-in-out infinite; }
        .dot-float2 { animation: float2 7s ease-in-out infinite; }
        .auth-bg { position: relative; overflow: hidden; }
        .auth-bg::before { content: ''; position: absolute; inset: 0; background: radial-gradient(circle at 20% 80%, rgba(2,73,56,0.08) 0%, transparent 50%), radial-gradient(circle at 80% 20%, rgba(249,172,0,0.08) 0%, transparent 50%); }
        .glass-card { background: rgba(255,255,255,0.95); backdrop-filter: blur(10px); }
        ::-webkit-scrollbar { width: 5px; }
        ::-webkit-scrollbar-track { background: #01241f; }
        ::-webkit-scrollbar-thumb { background: #024938; border-radius: 3px; }
    </style>
</head>
<body class="font-['Nunito',sans-serif] antialiased bg-gray-50 text-slate-800">
    <div class="min-h-screen flex flex-col auth-bg">
        @yield('content')
    </div>
</body>
</html>
