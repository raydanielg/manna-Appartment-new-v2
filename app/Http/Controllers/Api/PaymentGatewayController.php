<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use App\Models\DeviceToken;
use App\Models\Organization;
use App\Models\PaymentTransaction;
use App\Models\SubscriptionPlan;
use App\Services\SnippeService;
use App\Services\SubscriptionService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class PaymentGatewayController extends Controller
{
    use ApiResponse;

    public function initiate(Request $request)
    {
        $request->validate([
            'type' => 'required|in:subscription,payment',
            'id' => 'required|uuid',
            'phone' => 'required|string',
            'payment_method' => 'required|in:mobile_money',
        ]);

        $user = Auth::user();
        $organization = $user->organization;

        if (!$organization) {
            return $this->error('No organization associated with this account.', null, 400);
        }

        if ($request->type === 'subscription') {
            try {
                return $this->initiateSubscription($request, $user, $organization);
            } catch (\Exception $e) {
                Log::error('Payment initiation failed', [
                    'message' => $e->getMessage(),
                    'trace' => $e->getTraceAsString(),
                ]);
                return $this->error('Payment could not be initiated: ' . $e->getMessage(), null, 500);
            }
        }

        return $this->error('Tenant payments are not yet supported via this gateway.', null, 400);
    }

    private function initiateSubscription(Request $request, $user, Organization $organization)
    {
        $plan = SubscriptionPlan::findOrFail($request->id);

        if (!$plan->status || $plan->status !== 'active') {
            return $this->error('Selected subscription plan is not active.', null, 400);
        }

        $paymentMethod = 'mobile_money';

        $transaction = PaymentTransaction::create([
            'organization_id' => $organization->id,
            'user_id' => $user->id,
            'type' => 'subscription',
            'reference_id' => $plan->id,
            'provider' => 'snippe',
            'amount' => $plan->price,
            'currency' => config('snippe.currency', 'TZS'),
            'status' => 'pending',
            'phone' => app(SnippeService::class)->formatPhone($request->phone),
            'payment_method' => $paymentMethod,
        ]);

        $sessionData = [
            'amount' => (int) $plan->price,
            'currency' => config('snippe.currency', 'TZS'),
            'allowed_methods' => ['mobile_money'],
            'phone' => $request->phone,
            'customer_name' => $user->full_name,
            'customer_email' => $user->email,
            'description' => "Subscription: {$plan->name}",
            'metadata' => [
                'transaction_id' => $transaction->id,
                'organization_id' => $organization->id,
                'plan_id' => $plan->id,
                'type' => 'subscription',
                'payment_method' => $paymentMethod,
            ],
        ];

        $session = app(SnippeService::class)->createSession($sessionData);

        if (!$this->isSessionSuccessful($session)) {
            $transaction->update(['status' => 'failed']);
            Log::error('Snippe session failed', ['response' => $session]);
            return $this->error(
                $session['message'] ?? 'Failed to create payment session. Please check your Snippe configuration.',
                $session,
                502
            );
        }

        $transaction->update([
            'provider_reference' => $this->sessionReference($session),
            'payload' => $session['data'] ?? $session,
        ]);

        return $this->success('Payment initiated.', [
            'reference' => $transaction->id,
            'provider_reference' => $this->sessionReference($session),
            'checkout_url' => $this->sessionCheckoutUrl($session),
            'payment_link_url' => $this->sessionPaymentLinkUrl($session),
            'amount' => $plan->price,
            'currency' => config('snippe.currency', 'TZS'),
            'status' => 'pending',
            'payment_method' => $paymentMethod,
        ]);
    }

    private function isSessionSuccessful(array $session): bool
    {
        if (!empty($session['status']) && $session['status'] !== 'success') {
            return false;
        }
        return !empty($session['data']['reference']) || !empty($session['reference']);
    }

    private function sessionReference(array $session): ?string
    {
        return $session['data']['reference'] ?? $session['reference'] ?? null;
    }

    private function sessionCheckoutUrl(array $session): ?string
    {
        return $session['data']['checkout_url'] ?? $session['checkout_url'] ?? null;
    }

    private function sessionPaymentLinkUrl(array $session): ?string
    {
        return $session['data']['payment_link_url'] ?? $session['payment_link_url'] ?? null;
    }

    public function callback(Request $request)
    {
        $payload = $request->getContent();
        $signature = $request->header('X-Webhook-Signature');
        $timestamp = $request->header('X-Webhook-Timestamp');
        $eventType = $request->header('X-Webhook-Event');

        $service = app(SnippeService::class);

        if (!$service->enabled()) {
            Log::info('Snippe is disabled. Ignoring webhook.');
            return response('OK', 200);
        }

        if (!$service->verifyWebhookSignature($payload, $timestamp, $signature)) {
            Log::warning('Snippe webhook signature verification failed.');
            return response('Invalid signature', 400);
        }

        $event = json_decode($payload, true);

        if (empty($event['data']['reference'])) {
            Log::warning('Snippe webhook missing reference.', ['event' => $event]);
            return response('OK', 200);
        }

        $providerReference = $event['data']['reference'];
        $transaction = PaymentTransaction::where('provider_reference', $providerReference)->first();

        if (!$transaction) {
            Log::warning('Snippe webhook transaction not found.', ['reference' => $providerReference]);
            return response('OK', 200);
        }

        $transaction->update([
            'payload' => array_merge($transaction->payload ?? [], $event),
        ]);

        if (in_array($eventType, ['payment.completed', 'payment.success'])) {
            $this->completeTransaction($transaction, $event);
        } elseif (in_array($eventType, ['payment.failed', 'payment.expired', 'payment.voided'])) {
            $transaction->update(['status' => 'failed']);
        }

        return response('OK', 200);
    }

    private function completeTransaction(PaymentTransaction $transaction, array $event)
    {
        if ($transaction->status === 'completed') {
            return;
        }

        $transaction->update([
            'status' => 'completed',
            'paid_at' => now(),
        ]);

        $organization = Organization::find($transaction->organization_id);
        $plan = SubscriptionPlan::find($transaction->reference_id);

        if ($transaction->type === 'subscription' && $organization && $plan) {
            app(SubscriptionService::class)->subscribe(
                $organization,
                $plan,
                $transaction->provider_reference
            );
        }

        $title = 'Payment Successful';
        $body = 'Your payment of ' . $transaction->currency . ' ' . number_format($transaction->amount, 2) . ' has been received.';
        if ($transaction->type === 'subscription' && $plan) {
            $body = "Subscription payment for {$plan->name} completed. Your plan is now active.";
        }

        AppNotification::create([
            'user_id' => $transaction->user_id,
            'title' => $title,
            'body' => $body,
            'type' => 'payment',
            'data' => [
                'transaction_id' => $transaction->id,
                'type' => $transaction->type,
                'amount' => $transaction->amount,
                'currency' => $transaction->currency,
            ],
            'sent_at' => now(),
        ]);

        $this->sendPaymentPushNotification($transaction->user_id, $title, $body);
    }

    private function sendPaymentPushNotification(?string $userId, string $title, string $body)
    {
        if (empty($userId)) {
            return;
        }

        $serverKey = config('services.fcm.server_key');
        if (empty($serverKey)) {
            return;
        }

        $tokens = DeviceToken::where('user_id', $userId)
            ->whereNotNull('token')
            ->where('token', '!=', '')
            ->pluck('token')
            ->unique()
            ->values()
            ->toArray();

        if (empty($tokens)) {
            return;
        }

        foreach (array_chunk($tokens, 500) as $chunk) {
            try {
                Http::withHeaders([
                    'Authorization' => 'key=' . $serverKey,
                    'Content-Type' => 'application/json',
                ])->post('https://fcm.googleapis.com/fcm/send', [
                    'registration_ids' => $chunk,
                    'notification' => [
                        'title' => $title,
                        'body' => $body,
                        'sound' => 'default',
                    ],
                    'priority' => 'high',
                ]);
            } catch (\Exception $e) {
                Log::error('FCM payment notification failed: ' . $e->getMessage());
            }
        }
    }

    public function verify($ref)
    {
        $transaction = PaymentTransaction::where(function ($query) use ($ref) {
            $query->where('id', $ref)->orWhere('provider_reference', $ref);
        })->first();

        if (!$transaction) {
            return $this->error('Transaction not found.', null, 404);
        }

        // Auto-verify: check Snippe API directly if still pending
        if ($transaction->status === 'pending' && $transaction->provider_reference) {
            $this->autoVerifyWithSnippe($transaction);
            $transaction->refresh();
        }

        return $this->success('Transaction status retrieved.', [
            'reference' => $transaction->id,
            'provider_reference' => $transaction->provider_reference,
            'status' => $transaction->status,
            'amount' => $transaction->amount,
            'currency' => $transaction->currency,
            'paid_at' => $transaction->paid_at,
        ]);
    }

    private function autoVerifyWithSnippe(PaymentTransaction $transaction)
    {
        try {
            $service = app(SnippeService::class);
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . config('snippe.api_key'),
                'Accept' => 'application/json',
            ])->withOptions(['verify' => !app()->environment('local')])
              ->get($service->baseUrl() . '/api/v1/sessions/' . $transaction->provider_reference);

            if (!$response->successful()) {
                return;
            }

            $data = $response->json();
            $sessionStatus = $data['data']['status'] ?? $data['status'] ?? null;

            if (in_array($sessionStatus, ['completed', 'paid', 'successful', 'success'])) {
                $this->completeTransaction($transaction, $data);
            } elseif (in_array($sessionStatus, ['failed', 'expired', 'cancelled', 'voided'])) {
                $transaction->update(['status' => 'failed']);
            }
        } catch (\Exception $e) {
            Log::error('Snippe auto-verify failed: ' . $e->getMessage());
        }
    }
}
