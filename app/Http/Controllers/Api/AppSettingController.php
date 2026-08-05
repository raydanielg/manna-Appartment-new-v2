<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class AppSettingController extends Controller
{
    use ApiResponse;

    public function index()
    {
        $settings = Setting::where('group', 'mobile_app')
            ->orWhere('key', 'kyc_mandatory')
            ->get()
            ->pluck('value', 'key');

        return $this->success('App settings retrieved.', $settings);
    }
}
