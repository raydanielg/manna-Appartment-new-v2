<?php

namespace App\Http\Controllers\Api\Tenant;

use App\Http\Controllers\Controller;
use App\Traits\ApiResponse;
use Illuminate\Support\Facades\Auth;

class MyUnitController extends Controller
{
    use ApiResponse;

    public function show()
    {
        $user = Auth::user();
        $tenant = $user->tenant;

        if (!$tenant || !$tenant->unit) {
            return $this->error('No unit assigned.', null, 404);
        }

        return $this->success('Unit retrieved.', $tenant->unit->load('property'));
    }
}
