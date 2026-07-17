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
        $paymentQuery = Payment::with(['tenant.user', 'organization'])->where('status', 'confirmed');

        if ($request->filled('payment_status') && $request->payment_status !== 'all') {
            $paymentQuery->where('status', $request->payment_status);
        }

        $payments = $paymentQuery->latest()->paginate(20);
        $subscriptions = Subscription::with(['organization.owner', 'plan'])->latest()->paginate(20);

        $totalRevenue = Payment::where('status', 'confirmed')->sum('amount');
        $subscriptionRevenue = Subscription::where('status', 'active')->sum('amount');
        $activeSubs = Subscription::where('status', 'active')->count();
        $totalPayments = Payment::where('status', 'confirmed')->count();

        return view('admin.revenue.index', compact('payments', 'subscriptions', 'totalRevenue', 'subscriptionRevenue', 'activeSubs', 'totalPayments'));
    }
}
