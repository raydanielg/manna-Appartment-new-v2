<?php
$key = 'snp_26934533ce7805a15b2d9b40837e172d57c0d1d9cf37e24926655d25300f1c5c';
$payload = json_encode([
    'payment_type' => 'mobile',
    'details' => [
        'amount' => 500,
        'currency' => 'TZS',
    ],
    'phone_number' => '255711000000',
    'customer' => [
        'firstname' => 'Test',
        'lastname' => 'User',
        'email' => 'test@manna.co.tz',
    ],
    'webhook_url' => 'https://mannaappartnment.test/api/v1/payments-gateway/callback',
    'metadata' => ['test' => true],
]);

$ch = curl_init('https://api.snippe.sh/v1/payments');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $key,
    'Content-Type: application/json',
    'Accept: application/json',
]);
$resp = curl_exec($ch);
$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
echo "HTTP $code\n";
echo $resp . "\n";
curl_close($ch);
