<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Contract;
use App\Models\Organization;
use App\Models\Payment;
use App\Models\Property;
use App\Models\SmsLog;
use App\Models\Tenant;
use App\Models\Unit;
use Illuminate\Http\Request;

class AnalyticsController extends Controller
{
    public function __construct()
    {
        $this->middleware(['auth']);
    }

    public function index(Request $request)
    {
        $stats = [
            'organizations' => Organization::count(),
            'properties' => Property::count(),
            'units' => Unit::count(),
            'tenants' => Tenant::count(),
            'contracts' => Contract::count(),
            'payments' => Payment::where('status', 'confirmed')->sum('amount'),
            'smsSent' => SmsLog::where('status', 'sent')->count(),
        ];
        return view('admin.analytics.index', compact('stats'));
    }
}
