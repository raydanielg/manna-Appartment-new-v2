<?php

return [
    'enabled' => env('SNIPPE_ENABLED', true),
    'api_key' => env('SNIPPE_API_KEY'),
    'webhook_secret' => env('SNIPPE_WEBHOOK_SECRET'),
    'base_url' => env('SNIPPE_BASE_URL', 'https://api.snippe.sh'),
    'api_version' => env('SNIPPE_API_VERSION', '2026-01-25'),
    'currency' => env('SNIPPE_CURRENCY', 'TZS'),
    'default_provider' => env('SNIPPE_PROVIDER', 'snippe'),
    'redirect_url' => env('SNIPPE_REDIRECT_URL', config('app.url') . '/payment/success'),
    'cancel_url' => env('SNIPPE_CANCEL_URL', config('app.url') . '/payment/cancel'),
];
