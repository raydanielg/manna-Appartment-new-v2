<?php

return [
    'default_provider' => env('SMS_PROVIDER', 'nextsms'),
    'sender_id' => env('SMS_SENDER_ID', 'Manna'),

    'providers' => [
        'nextsms' => [
            'base_url' => env('NEXTSMS_BASE_URL', 'https://messaging-service.co.tz'),
            'api_key' => env('NEXTSMS_API_KEY'),
            'from' => env('NEXTSMS_SENDER_ID', 'Manna'),
            'endpoints' => [
                'send' => '/api/v2/sms/send',
                'balance' => '/api/v2/balance',
                'logs' => '/api/v2/logs',
            ],
        ],
        'beem' => [
            'api_key' => env('SMS_API_KEY'),
            'secret_key' => env('SMS_SECRET_KEY'),
            'base_url' => 'https://apisms.beem.africa/v1/send',
        ],
        'africas_talking' => [
            'username' => env('AFRICASTALKING_USERNAME'),
            'api_key' => env('AFRICASTALKING_API_KEY'),
        ],
    ],
];
