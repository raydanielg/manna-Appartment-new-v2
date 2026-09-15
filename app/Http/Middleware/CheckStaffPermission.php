<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CheckStaffPermission
{
    public function handle(Request $request, Closure $next, string $permission)
    {
        $user = $request->user();

        if (!$user || $user->role !== 'staff') {
            return $next($request);
        }

        $granted = $user->staffPermission?->permissions_json[$permission] ?? false;

        if (!$granted) {
            return response()->json([
                'success' => false,
                'message' => "You don't have permission to perform this action.",
            ], 403);
        }

        return $next($request);
    }
}
