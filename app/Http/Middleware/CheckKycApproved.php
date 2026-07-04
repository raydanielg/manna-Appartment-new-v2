<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CheckKycApproved
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();

        if ($user->isSuperAdmin() || $user->isTenant()) {
            return $next($request);
        }

        $organization = $user->organization;

        if (!$organization || $organization->kyc_status !== 'approved') {
            return response()->json([
                'success' => false,
                'message' => 'KYC verification is required. Please submit your documents for approval.',
            ], 403);
        }

        return $next($request);
    }
}
