<?php
namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class CheckLoginSeeder extends Seeder
{
    public function run()
    {
        $u = User::where('phone', '255722000000')->first();
        echo "Found: " . ($u ? "YES" : "NO") . "\n";
        echo "Phone: " . $u->phone . "\n";
        echo "Pass check (password): " . (Hash::check('password', $u->password) ? "YES" : "NO") . "\n";
        echo "Role: " . $u->role . "\n";
        echo "Status: " . $u->status . "\n";
    }
}
