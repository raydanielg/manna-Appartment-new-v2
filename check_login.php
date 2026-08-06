<?php
require 'vendor/autoload.php';
$app = require 'bootstrap/app.php';
$app->boot();

$u = App\Models\User::where('phone', '255722000000')->first();
echo "Found: " . ($u ? "YES" : "NO") . "\n";
echo "Phone: " . $u->phone . "\n";
echo "Pass check (password): " . (Illuminate\Support\Facades\Hash::check('password', $u->password) ? "YES" : "NO") . "\n";
echo "Role: " . $u->role . "\n";
echo "Status: " . $u->status . "\n";
