<?php

return [
    'default_provider' => env('SMS_PROVIDER', 'beem'),
    'sender_id' => env('SMS_SENDER_ID', 'MANNA'),

    'providers' => [
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
