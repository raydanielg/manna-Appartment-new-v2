<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Organization;
use App\Models\PaymentTransaction;
use App\Models\SubscriptionPlan;
use App\Services\SnippeService;
use App\Services\SubscriptionService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
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
        ]);

        $user = Auth::user();
        $organization = $user->organization;

        if (!$organization) {
            return $this->error('No organization associated with this account.', null, 400);
        }

        if ($request->type === 'subscription') {
            return $this->initiateSubscription($request, $user, $organization);
        }

        return $this->error('Tenant payments are not yet supported via this gateway.', null, 400);
    }

    private function initiateSubscription(Request $request, $user, Organization $organization)
    {
        $plan = SubscriptionPlan::findOrFail($request->id);

        if (!$plan->status || $plan->status !== 'active') {
            return $this->error('Selected subscription plan is not active.', null, 400);
        }

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
        ]);

        $session = app(SnippeService::class)->createSession([
            'amount' => $plan->price * 100, // Snippe expects smallest currency unit (cents)
            'currency' => config('snippe.currency', 'TZS'),
            'allowed_methods' => ['mobile_money', 'card'],
            'phone' => $request->phone,
            'customer_name' => $user->full_name,
            'customer_email' => $user->email,
            'description' => "Subscription: {$plan->name}",
            'metadata' => [
                'transaction_id' => $transaction->id,
                'organization_id' => $organization->id,
                'plan_id' => $plan->id,
                'type' => 'subscription',
            ],
        ]);

        if (($session['status'] ?? 'success') !== 'success' || empty($session['data']['reference'])) {
            $transaction->update(['status' => 'failed']);
            return $this->error($session['message'] ?? 'Failed to create Snippe payment session.', $session, 500);
        }

        $transaction->update([
            'provider_reference' => $session['data']['reference'],
            'payload' => $session['data'],
        ]);

        return $this->success('Payment initiated.', [
            'reference' => $transaction->id,
            'provider_reference' => $session['data']['reference'],
            'checkout_url' => $session['data']['checkout_url'] ?? null,
            'payment_link_url' => $session['data']['payment_link_url'] ?? null,
            'amount' => $plan->price,
            'currency' => config('snippe.currency', 'TZS'),
            'status' => 'pending',
        ]);
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

        if ($transaction->type === 'subscription') {
            $organization = Organization::find($transaction->organization_id);
            $plan = SubscriptionPlan::find($transaction->reference_id);

            if ($organization && $plan) {
                app(SubscriptionService::class)->subscribe(
                    $organization,
                    $plan,
                    $transaction->provider_reference
                );
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

        return $this->success('Transaction status retrieved.', [
            'reference' => $transaction->id,
            'provider_reference' => $transaction->provider_reference,
            'status' => $transaction->status,
            'amount' => $transaction->amount,
            'currency' => $transaction->currency,
            'paid_at' => $transaction->paid_at,
        ]);
    }
}
