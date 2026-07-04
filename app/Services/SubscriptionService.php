<?php

namespace App\Services;

use App\Models\Organization;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use Carbon\Carbon;

class SubscriptionService
{
    public function subscribe(Organization $organization, SubscriptionPlan $plan, string $paymentReference = null): Subscription
    {
        $startDate = now();
        $endDate = match ($plan->billing_cycle) {
            'yearly' => $startDate->copy()->addYear(),
            default => $startDate->copy()->addMonth(),
        };

        $subscription = Subscription::create([
            'organization_id' => $organization->id,
            'plan_id' => $plan->id,
            'start_date' => $startDate,
            'end_date' => $endDate,
            'amount' => $plan->price,
            'payment_reference' => $paymentReference,
            'status' => 'active',
        ]);

        $organization->update([
            'subscription_id' => $subscription->id,
            'sms_balance' => $organization->sms_balance + $plan->sms_included,
        ]);

        return $subscription;
    }
}
