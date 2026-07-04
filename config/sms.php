<?php

return [
    'default_provider' => env('SMS_PROVIDER', 'nextsms'),
    'sender_id' => env('SMS_SENDER_ID', 'MANNA'),

    'providers' => [
        'nextsms' => [
            'url' => env('NEXTSMS_URL', 'https://messaging-service.co.tz/api/sms/v1/text/single'),
            'username' => env('NEXTSMS_USERNAME'),
            'password' => env('NEXTSMS_PASSWORD'),
            'from' => env('NEXTSMS_FROM', 'MANNA'),
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
