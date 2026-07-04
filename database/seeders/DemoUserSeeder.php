<?php

namespace Database\Seeders;

use App\Models\Organization;
use App\Models\Property;
use App\Models\Tenant;
use App\Models\Unit;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class DemoUserSeeder extends Seeder
{
    public function run()
    {
        // Demo landlord
        $landlord = User::updateOrCreate(
            ['phone' => '255711000000'],
            [
                'full_name' => 'Demo Landlord',
                'phone' => '255711000000',
                'email' => 'landlord@demo.com',
                'password' => Hash::make('password'),
                'role' => 'landlord',
                'status' => 'active',
            ]
        );

        $organization = Organization::updateOrCreate(
            ['business_name' => 'Demo Properties Ltd'],
            [
                'owner_user_id' => $landlord->id,
                'business_name' => 'Demo Properties Ltd',
                'kyc_status' => 'approved',
                'status' => 'active',
                'sms_balance' => 1000,
            ]
        );

        $landlord->update(['organization_id' => $organization->id]);

        // Demo property
        $property = Property::updateOrCreate(
            ['organization_id' => $organization->id, 'name' => 'Manna Heights'],
            [
                'organization_id' => $organization->id,
                'name' => 'Manna Heights',
                'address' => 'Kijitonyama, Dar es Salaam',
                'location' => 'Dar es Salaam',
                'type' => 'apartment',
                'description' => 'Modern apartment building with secure parking and backup power.',
                'status' => 'active',
            ]
        );

        // Demo unit
        $unit = Unit::updateOrCreate(
            ['property_id' => $property->id, 'name' => 'A-101'],
            [
                'property_id' => $property->id,
                'organization_id' => $organization->id,
                'name' => 'A-101',
                'type' => '2br',
                'rent_amount' => 450000,
                'size' => '85',
                'bedrooms' => 2,
                'bathrooms' => 1,
                'status' => 'occupied',
            ]
        );

        // Demo tenant
        $tenantUser = User::updateOrCreate(
            ['phone' => '255722000000'],
            [
                'full_name' => 'Demo Tenant',
                'phone' => '255722000000',
                'email' => 'tenant@demo.com',
                'password' => Hash::make('password'),
                'role' => 'tenant',
                'status' => 'active',
                'organization_id' => $organization->id,
            ]
        );

        Tenant::updateOrCreate(
            ['user_id' => $tenantUser->id],
            [
                'organization_id' => $organization->id,
                'user_id' => $tenantUser->id,
                'unit_id' => $unit->id,
                'id_number' => 'T' . random_int(100000, 999999),
                'emergency_contact' => '255733000000',
                'moved_in_date' => now()->subMonths(3),
                'status' => 'active',
            ]
        );
    }
}
