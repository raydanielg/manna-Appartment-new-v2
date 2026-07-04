<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class SuperAdminSeeder extends Seeder
{
    public function run()
    {
        User::updateOrCreate(
            ['phone' => '255700000001'],
            [
                'full_name' => 'Super Admin',
                'phone' => '255700000001',
                'password' => Hash::make('password'),
                'role' => 'super_admin',
                'status' => 'active',
            ]
        );
    }
}
