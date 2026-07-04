<?php

return [
    'default_plan' => env('DEFAULT_SUBSCRIPTION_PLAN', 'Basic'),
    'trial_days' => env('SUBSCRIPTION_TRIAL_DAYS', 14),
    'currency' => env('SUBSCRIPTION_CURRENCY', 'TZS'),
];
