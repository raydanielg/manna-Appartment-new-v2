<?php

namespace App\Http\Middleware;

use App\Models\Organization;
use Closure;
use Illuminate\Http\Request;

class CheckSubscriptionActive
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();

        if ($user->isSuperAdmin()) {
            return $next($request);
        }

        $organization = $user->organization;

        if (!$organization || $organization->status !== 'active') {
            return response()->json([
                'success' => false,
                'message' => 'Organization account is inactive or suspended.',
            ], 403);
        }

        // Prefer the latest active subscription for this organization —
        // organization.subscription_id may still point at an expired one.
        $subscription = $organization->subscriptions()
            ->where('status', 'active')
            ->where('end_date', '>=', now()->toDateString())
            ->orderByDesc('end_date')
            ->first()
            ?? $organization->subscription;

        if (!$subscription || $subscription->status !== 'active' || $subscription->end_date->startOfDay()->lt(now()->startOfDay())) {
            return response()->json([
                'success' => false,
                'message' => 'Subscription is inactive or expired. Please renew to continue.',
            ], 403);
        }

        return $next($request);
    }
}
