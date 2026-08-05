<?php

namespace Database\Seeders;

use App\Models\Setting;
use Illuminate\Database\Seeder;

class AppSettingsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        Setting::updateOrCreate(
            ['key' => 'kyc_mandatory'],
            [
                'value' => 'on',
                'group' => 'mobile_app',
                'label' => 'KYC Mandatory for Landlords',
                'type' => 'boolean'
            ]
        );
    }
}
