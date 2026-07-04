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

        $subscription = $organization->subscription;

        if (!$subscription || $subscription->status !== 'active' || $subscription->end_date < now()) {
            return response()->json([
                'success' => false,
                'message' => 'Subscription is inactive or expired. Please renew to continue.',
            ], 403);
        }

        return $next($request);
    }
}
