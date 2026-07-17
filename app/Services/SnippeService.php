<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class SnippeService
{
    public function baseUrl(): string
    {
        return rtrim(config('snippe.base_url', 'https://api.snippe.sh'), '/');
    }

    private function headers(): array
    {
        return [
            'Authorization' => 'Bearer ' . config('snippe.api_key'),
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
        ];
    }

    public function enabled(): bool
    {
        return (bool) config('snippe.enabled', true);
    }

    /**
     * Create a mobile money payment intent via Payments API.
     * Customer receives USSD push automatically.
     */
    public function createPayment(array $data): array
    {
        $phone = $this->formatPhone($data['phone'] ?? '');
        $name = $data['customer_name'] ?? 'Manna User';
        $parts = array_pad(explode(' ', $name, 2), 2, '');
        $firstname = $parts[0] ?: 'Customer';
        $lastname = $parts[1] ?: 'User';

        $payload = [
            'payment_type' => 'mobile',
            'details' => [
                'amount' => (int) $data['amount'],
                'currency' => $data['currency'] ?? config('snippe.currency', 'TZS'),
            ],
            'phone_number' => $phone,
            'customer' => [
                'firstname' => $firstname,
                'lastname' => $lastname,
            ],
            'webhook_url' => $data['webhook_url'] ?? route('snippe.webhook'),
            'metadata' => $data['metadata'] ?? [],
        ];

        if (!empty($data['customer_email'])) {
            $payload['customer']['email'] = $data['customer_email'];
        } else {
            $payload['customer']['email'] = 'customer@manna.co.tz';
        }

        $idempotencyKey = Str::limit($data['metadata']['transaction_id'] ?? Str::random(20), 30, '');

        try {
            $response = Http::withHeaders($this->headers())
                ->withOptions(['verify' => !app()->environment('local')])
                ->withHeaders(['Idempotency-Key' => $idempotencyKey])
                ->post($this->baseUrl() . '/v1/payments', $payload);

            if ($response->successful()) {
                $result = $response->json();
                Log::info('Snippe payment created', [
                    'reference' => $result['data']['reference'] ?? null,
                    'status' => $result['data']['status'] ?? null,
                    'phone' => $phone,
                ]);
                return $result;
            }

            Log::error('Snippe payment creation failed', [
                'status' => $response->status(),
                'body' => $response->body(),
                'payload' => $payload,
            ]);

            $errorBody = $response->json();
            return [
                'status' => 'error',
                'code' => $response->status(),
                'message' => $errorBody['message'] ?? 'Snippe payment creation failed: ' . $response->body(),
            ];
        } catch (\Exception $e) {
            Log::error('Snippe payment exception: ' . $e->getMessage());
            return [
                'status' => 'error',
                'code' => 500,
                'message' => 'Could not reach Snippe: ' . $e->getMessage(),
            ];
        }
    }

    /**
     * Trigger USSD push to the customer's phone.
     */
    public function pushUssd(string $reference): array
    {
        try {
            $response = Http::withHeaders($this->headers())
                ->withOptions(['verify' => !app()->environment('local')])
                ->post($this->baseUrl() . '/v1/payments/' . $reference . '/push', []);

            if ($response->successful()) {
                Log::info('Snippe USSD push sent', ['reference' => $reference]);
                return $response->json();
            }

            Log::error('Snippe USSD push failed', [
                'reference' => $reference,
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return [
                'status' => 'error',
                'code' => $response->status(),
                'message' => 'USSD push failed: ' . $response->body(),
            ];
        } catch (\Exception $e) {
            Log::error('Snippe USSD push exception: ' . $e->getMessage());
            return [
                'status' => 'error',
                'code' => 500,
                'message' => 'Could not send USSD push: ' . $e->getMessage(),
            ];
        }
    }

    /**
     * Get payment status from Snippe.
     */
    public function getPaymentStatus(string $reference): ?array
    {
        try {
            $response = Http::withHeaders($this->headers())
                ->withOptions(['verify' => !app()->environment('local')])
                ->get($this->baseUrl() . '/v1/payments/' . $reference);

            if ($response->successful()) {
                return $response->json();
            }
        } catch (\Exception $e) {
            Log::error('Snippe get payment status failed: ' . $e->getMessage());
        }

        return null;
    }

    /**
     * Create a hosted checkout session.
     */
    public function createSession(array $data): array
    {
        $payload = [
            'amount' => (int) $data['amount'],
            'currency' => $data['currency'] ?? config('snippe.currency', 'TZS'),
            'allowed_methods' => $data['allowed_methods'] ?? ['mobile_money', 'card', 'qr'],
            'customer' => [
                'name' => $data['customer_name'] ?? 'Manna User',
                'phone' => $this->formatPhone($data['phone'] ?? ''),
                'email' => $data['customer_email'] ?? null,
            ],
            'redirect_url' => $data['redirect_url'] ?? config('snippe.redirect_url'),
            'webhook_url' => $data['webhook_url'] ?? route('snippe.webhook'),
            'description' => $data['description'] ?? 'Payment',
            'metadata' => $data['metadata'] ?? [],
            'expires_in' => $data['expires_in'] ?? 3600,
        ];

        // Remove null customer email to avoid validation issues
        if (empty($payload['customer']['email'])) {
            unset($payload['customer']['email']);
        }

        try {
            $response = Http::withHeaders($this->headers())
                ->withOptions(['verify' => !app()->environment('local')])
                ->post($this->baseUrl() . '/api/v1/sessions', $payload);

            if ($response->successful()) {
                return $response->json();
            }

            Log::error('Snippe session creation failed', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return [
                'status' => 'error',
                'code' => $response->status(),
                'message' => 'Snippe session creation failed: ' . $response->body(),
            ];
        } catch (\Exception $e) {
            Log::error('Snippe session exception: ' . $e->getMessage());
            return [
                'status' => 'error',
                'code' => 500,
                'message' => 'Could not reach Snippe: ' . $e->getMessage(),
            ];
        }
    }

    /**
     * Verify a webhook signature.
     */
    public function verifyWebhookSignature(string $payload, string $timestamp, string $signature): bool
    {
        $secret = config('snippe.webhook_secret');

        if (empty($secret)) {
            Log::warning('Snippe webhook secret not configured. Skipping signature verification.');
            return true;
        }

        // Prevent replay attacks (5 minutes tolerance)
        $eventTime = (int) $timestamp;
        $currentTime = now()->timestamp;
        if (abs($currentTime - $eventTime) > 300) {
            Log::warning('Snippe webhook timestamp too old.', ['timestamp' => $timestamp]);
            return false;
        }

        $expected = hash_hmac('sha256', "{$timestamp}.{$payload}", $secret);
        return hash_equals($expected, $signature);
    }

    /**
     * Format phone numbers to 255XXXXXXXXX.
     */
    public function formatPhone(string $phone): string
    {
        $phone = trim($phone);

        if (Str::startsWith($phone, '+')) {
            $phone = substr($phone, 1);
        }

        $phone = preg_replace('/[^0-9]/', '', $phone);

        if (Str::startsWith($phone, '0')) {
            $phone = '255' . substr($phone, 1);
        }

        return $phone;
    }
}
