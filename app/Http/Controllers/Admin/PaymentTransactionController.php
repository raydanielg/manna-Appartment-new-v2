<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\PaymentTransaction;
use Illuminate\Http\Request;

class PaymentTransactionController extends Controller
{
    public function __construct()
    {
        $this->middleware(['auth']);
    }

    public function index(Request $request)
    {
        $query = PaymentTransaction::with(['organization', 'user']);

        if ($request->filled('status') && $request->status !== 'all') {
            $query->where('status', $request->status);
        }

        if ($request->filled('type') && $request->type !== 'all') {
            $query->where('type', $request->type);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('provider_reference', 'like', "%{$search}%")
                    ->orWhere('phone', 'like', "%{$search}%")
                    ->orWhere('id', 'like', "%{$search}%")
                    ->orWhereHas('organization', function ($oq) use ($search) {
                        $oq->where('name', 'like', "%{$search}%");
                    })
                    ->orWhereHas('user', function ($uq) use ($search) {
                        $uq->where('full_name', 'like', "%{$search}%")
                            ->orWhere('email', 'like', "%{$search}%");
                    });
            });
        }

        $transactions = $query->latest()->paginate(20);

        $totalTransactions = PaymentTransaction::count();
        $completedCount = PaymentTransaction::where('status', 'completed')->count();
        $pendingCount = PaymentTransaction::where('status', 'pending')->count();
        $failedCount = PaymentTransaction::where('status', 'failed')->count();
        $totalVolume = PaymentTransaction::where('status', 'completed')->sum('amount');
        $subscriptionCount = PaymentTransaction::where('type', 'subscription')->count();
        $completedVolume = PaymentTransaction::where('status', 'completed')->sum('amount');

        return view('admin.payment-transactions.index', compact(
            'transactions',
            'totalTransactions',
            'completedCount',
            'pendingCount',
            'failedCount',
            'totalVolume',
            'subscriptionCount',
            'completedVolume'
        ));
    }

    public function show($id)
    {
        $transaction = PaymentTransaction::with(['organization', 'user'])->findOrFail($id);
        return view('admin.payment-transactions.show', compact('transaction'));
    }
}
