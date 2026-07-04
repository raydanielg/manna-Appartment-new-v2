<?php

namespace App\Http\Middleware;

use App\Models\Setting;
use Closure;
use Illuminate\Http\Request;

class CheckMaintenanceMode
{
    public function handle(Request $request, Closure $next)
    {
        try {
            $maintenance = Setting::get('maintenance_mode', 'off');
        } catch (\Exception $e) {
            $maintenance = 'off';
        }

        if ($maintenance === 'on' && !$request->is('admin/*') && !$request->is('login')) {
            return response()->view('errors.maintenance', [], 503);
        }

        return $next($request);
    }
}
