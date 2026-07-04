<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class EnsurePlatform
{
    public function handle(Request $request, Closure $next, $platform)
    {
        $user = $request->user();
        $requestPlatform = strtolower($request->header('X-Platform', $platform));

        $webOnlyRoles = ['super_admin', 'staff'];
        $mobileOnlyRoles = ['landlord', 'tenant'];

        if (in_array($user->role, $webOnlyRoles) && $requestPlatform !== 'web') {
            return response()->json([
                'success' => false,
                'message' => 'This account must be accessed via the Web Admin Panel.',
            ], 403);
        }

        if (in_array($user->role, $mobileOnlyRoles) && $requestPlatform !== 'mobile') {
            return response()->json([
                'success' => false,
                'message' => 'This account must be accessed via the Mobile App.',
            ], 403);
        }

        return $next($request);
    }
}
