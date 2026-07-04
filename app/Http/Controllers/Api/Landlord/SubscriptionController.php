<?php

namespace App\Http\Controllers\Api\Landlord;

use App\Http\Controllers\Controller;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class SubscriptionController extends Controller
{
    use ApiResponse;

    public function plans()
    {
        return $this->success('Plans retrieved.', SubscriptionPlan::where('status', 'active')->get());
    }

    public function current()
    {
        $organization = Auth::user()->organization;
        $subscription = Subscription::with('plan')->where('organization_id', $organization->id)->latest()->first();
        return $this->success('Current subscription retrieved.', $subscription);
    }

    public function freeTrial()
    {
        $organization = Auth::user()->organization;

        $existingTrial = Subscription::where('organization_id', $organization->id)
            ->whereHas('plan', fn ($q) => $q->where('billing_cycle', 'trial'))
            ->first();

        if ($existingTrial) {
            return $this->error('Free trial has already been used on this account.', null, 422);
        }

        $plan = SubscriptionPlan::where('billing_cycle', 'trial')->where('status', 'active')->first();
        if (!$plan) {
            return $this->error('Free trial plan is not available.', null, 422);
        }

        $startDate = now();
        $endDate = $startDate->copy()->addDays(3);

        $subscription = Subscription::create([
            'organization_id' => $organization->id,
            'plan_id' => $plan->id,
            'start_date' => $startDate,
            'end_date' => $endDate,
            'amount' => 0,
            'status' => 'active',
        ]);

        $organization->update([
            'subscription_id' => $subscription->id,
            'sms_balance' => $organization->sms_balance + $plan->sms_included,
        ]);

        return $this->success('Free trial activated for 3 days.', $subscription->load('plan'), 201);
    }

    public function subscribe(Request $request)
    {
        $request->validate([
            'plan_id' => 'required|uuid|exists:subscription_plans,id',
            'start_date' => 'required|date',
            'payment_reference' => 'nullable|string',
        ]);

        $plan = SubscriptionPlan::findOrFail($request->plan_id);
        $organization = Auth::user()->organization;
        $startDate = \Carbon\Carbon::parse($request->start_date);

        $endDate = match ($plan->billing_cycle) {
            'monthly' => $startDate->copy()->addMonth(),
            'yearly' => $startDate->copy()->addYear(),
            default => $startDate->copy()->addMonth(),
        };

        $subscription = Subscription::create([
            'organization_id' => $organization->id,
            'plan_id' => $plan->id,
            'start_date' => $startDate,
            'end_date' => $endDate,
            'amount' => $plan->price,
            'payment_reference' => $request->payment_reference,
            'status' => 'active',
        ]);

        $organization->update([
            'subscription_id' => $subscription->id,
            'sms_balance' => $organization->sms_balance + $plan->sms_included,
        ]);

        return $this->success('Subscription activated.', $subscription->load('plan'), 201);
    }

    public function invoices(Request $request)
    {
        $organization = Auth::user()->organization;
        $invoices = Subscription::with('plan')->where('organization_id', $organization->id)->latest()->paginate($request->get('per_page', 20));
        return $this->paginated($invoices);
    }
}
