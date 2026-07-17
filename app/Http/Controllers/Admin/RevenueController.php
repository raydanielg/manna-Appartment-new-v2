<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\Subscription;
use Illuminate\Http\Request;

class RevenueController extends Controller
{
    public function __construct()
    {
        $this->middleware(['auth']);
    }

    public function index(Request $request)
    {
        $payments = Payment::with(['tenant.user', 'organization'])->where('status', 'confirmed')->latest()->paginate(20);
        $subscriptions = Subscription::with(['organization.owner', 'plan'])->latest()->paginate(20);
        return view('admin.revenue.index', compact('payments', 'subscriptions'));
    }
}
