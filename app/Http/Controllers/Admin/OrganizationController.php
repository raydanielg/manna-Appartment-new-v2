<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Organization;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class OrganizationController extends Controller
{
    public function __construct()
    {
        $this->middleware(['auth']);
    }

    public function index(Request $request)
    {
        $organizations = Organization::with(['owner', 'subscription.plan'])->withCount(['properties', 'tenants'])->latest()->paginate(20);
        return view('admin.organizations.index', compact('organizations'));
    }

    public function show($id)
    {
        $organization = Organization::with(['owner', 'subscription.plan', 'kycDocuments'])
            ->withCount(['properties', 'tenants'])
            ->findOrFail($id);
        $plans = SubscriptionPlan::where('status', 'active')->get();
        return view('admin.organizations.show', compact('organization', 'plans'));
    }

    public function assignPlan(Request $request, $id)
    {
        $request->validate([
            'plan_id' => 'required|uuid|exists:subscription_plans,id',
            'start_date' => 'required|date',
        ]);

        $organization = Organization::findOrFail($id);
        $plan = SubscriptionPlan::findOrFail($request->plan_id);
        $startDate = \Carbon\Carbon::parse($request->start_date);

        $endDate = match ($plan->billing_cycle) {
            'monthly' => $startDate->copy()->addMonth(),
            'yearly' => $startDate->copy()->addYear(),
            'trial' => $startDate->copy()->addDays(3),
            default => $startDate->copy()->addMonth(),
        };

        $subscription = Subscription::create([
            'id' => (string) Str::uuid(),
            'organization_id' => $organization->id,
            'plan_id' => $plan->id,
            'start_date' => $startDate,
            'end_date' => $endDate,
            'amount' => $plan->price,
            'status' => 'active',
        ]);

        $organization->update([
            'subscription_id' => $subscription->id,
            'sms_balance' => $organization->sms_balance + $plan->sms_included,
        ]);

        return redirect()->route('admin.organizations.show', $id)
            ->with('success', 'Plan assigned to organization successfully.');
    }

    public function destroy($id)
    {
        $organization = Organization::findOrFail($id);
        $organization->delete();

        return redirect()->route('admin.organizations')
            ->with('success', 'Organization deleted successfully.');
    }
}
