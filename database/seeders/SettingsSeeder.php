<?php

namespace Database\Seeders;

use App\Models\Setting;
use Illuminate\Database\Seeder;

class SettingsSeeder extends Seeder
{
    public function run()
    {
        $settings = [
            // General
            ['key' => 'app_name', 'value' => 'Manna Apartment', 'group' => 'general', 'label' => 'App Name', 'type' => 'text'],
            ['key' => 'support_phone', 'value' => '255700000001', 'group' => 'general', 'label' => 'Support Phone', 'type' => 'text'],
            ['key' => 'support_email', 'value' => 'support@mannaapartment.com', 'group' => 'general', 'label' => 'Support Email', 'type' => 'text'],

            // Mobile App
            ['key' => 'mobile_app_version', 'value' => '1.0.0', 'group' => 'mobile_app', 'label' => 'Minimum App Version', 'type' => 'text'],
            ['key' => 'force_update', 'value' => 'off', 'group' => 'mobile_app', 'label' => 'Force Update', 'type' => 'boolean'],
            ['key' => 'app_store_url', 'value' => '', 'group' => 'mobile_app', 'label' => 'App Store URL', 'type' => 'text'],
            ['key' => 'play_store_url', 'value' => '', 'group' => 'mobile_app', 'label' => 'Play Store URL', 'type' => 'text'],

            // Maintenance
            ['key' => 'maintenance_mode', 'value' => 'off', 'group' => 'maintenance', 'label' => 'Maintenance Mode', 'type' => 'boolean'],
            ['key' => 'maintenance_message', 'value' => 'We are currently performing scheduled maintenance. Please check back soon.', 'group' => 'maintenance', 'label' => 'Maintenance Message', 'type' => 'textarea'],

            // SMS
            ['key' => 'sms_provider', 'value' => 'beem', 'group' => 'sms', 'label' => 'SMS Provider', 'type' => 'text'],
            ['key' => 'sms_sender_id', 'value' => 'MANNA', 'group' => 'sms', 'label' => 'SMS Sender ID', 'type' => 'text'],
        ];

        foreach ($settings as $setting) {
            Setting::updateOrCreate(['key' => $setting['key']], $setting);
        }
    }
}
