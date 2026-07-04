<?php

namespace Database\Seeders;

use App\Models\SubscriptionPlan;
use Illuminate\Database\Seeder;

class SubscriptionPlanSeeder extends Seeder
{
    public function run()
    {
        $plans = [
            [
                'name' => 'Free Trial',
                'price' => 0,
                'billing_cycle' => 'trial',
                'property_limit' => 1,
                'unit_limit' => 10,
                'sms_included' => 10,
                'features_json' => ['3_day_trial', 'basic_reports'],
            ],
            [
                'name' => 'Basic',
                'price' => 10000,
                'billing_cycle' => 'monthly',
                'property_limit' => 1,
                'unit_limit' => 10,
                'sms_included' => 50,
                'features_json' => ['basic_reports', 'email_support'],
            ],
            [
                'name' => 'Standard',
                'price' => 25000,
                'billing_cycle' => 'monthly',
                'property_limit' => 5,
                'unit_limit' => 50,
                'sms_included' => 200,
                'features_json' => ['advanced_reports', 'sms_notifications', 'priority_support'],
            ],
            [
                'name' => 'Premium',
                'price' => 50000,
                'billing_cycle' => 'monthly',
                'property_limit' => 0, // unlimited
                'unit_limit' => 0, // unlimited
                'sms_included' => 1000,
                'features_json' => ['unlimited_properties', 'unlimited_units', 'premium_support', 'analytics'],
            ],
        ];

        foreach ($plans as $plan) {
            SubscriptionPlan::updateOrCreate(
                ['name' => $plan['name']],
                $plan
            );
        }
    }
}
