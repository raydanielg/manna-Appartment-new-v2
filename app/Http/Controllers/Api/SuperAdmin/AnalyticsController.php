<?php

namespace App\Http\Controllers\Api\SuperAdmin;

use App\Http\Controllers\Controller;
use App\Models\Contract;
use App\Models\Organization;
use App\Models\Payment;
use App\Models\Property;
use App\Models\Tenant;
use App\Models\Unit;
use App\Traits\ApiResponse;

class AnalyticsController extends Controller
{
    use ApiResponse;

    public function index()
    {
        return $this->success('Analytics retrieved.', [
            'organizations' => Organization::count(),
            'active_organizations' => Organization::where('status', 'active')->count(),
            'pending_kyc' => Organization::where('kyc_status', 'pending')->count(),
            'properties' => Property::count(),
            'units' => Unit::count(),
            'vacant_units' => Unit::where('status', 'vacant')->count(),
            'occupied_units' => Unit::where('status', 'occupied')->count(),
            'tenants' => Tenant::count(),
            'active_contracts' => Contract::where('status', 'active')->count(),
            'total_payments' => Payment::where('status', 'confirmed')->sum('amount'),
        ]);
    }

    public function smsUsage()
    {
        return $this->success('SMS usage retrieved.', [
            'total_sms_sent' => \App\Models\SmsLog::where('status', 'sent')->count(),
            'total_sms_queued' => \App\Models\SmsLog::where('status', 'queued')->count(),
            'top_organizations' => \App\Models\SmsLog::selectRaw('organization_id, COUNT(*) as total')
                ->groupBy('organization_id')
                ->orderByDesc('total')
                ->limit(10)
                ->get(),
        ]);
    }
}
