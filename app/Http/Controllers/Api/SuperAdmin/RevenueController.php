<?php

namespace App\Http\Controllers\Api\SuperAdmin;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\Subscription;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class RevenueController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $subscriptionRevenue = Subscription::where('status', 'active')->sum('amount');
        $paymentRevenue = Payment::where('status', 'confirmed')->sum('amount');

        $monthly = Subscription::select(
            DB::raw('DATE_FORMAT(created_at, "%Y-%m") as month'),
            DB::raw('SUM(amount) as total')
        )->groupBy('month')->orderBy('month', 'desc')->limit(12)->get();

        return $this->success('Revenue retrieved.', [
            'subscription_revenue' => $subscriptionRevenue,
            'payment_revenue' => $paymentRevenue,
            'total' => $subscriptionRevenue + $paymentRevenue,
            'monthly_trend' => $monthly,
        ]);
    }
}
