<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class RequirePasswordChange
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();

        if ($user && $user->must_change_password) {
            $allowedRoute = $request->routeIs('tenant.profile.force-change-password');

            if (!$allowedRoute) {
                return response()->json([
                    'success' => false,
                    'message' => 'You must change your password before continuing.',
                    'must_change_password' => true,
                ], 403);
            }
        }

        return $next($request);
    }
}
