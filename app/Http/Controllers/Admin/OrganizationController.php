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
        $query = Organization::with(['owner', 'subscription.plan'])->withCount(['properties', 'tenants'])->latest();

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('kyc_status')) {
            $query->where('kyc_status', $request->kyc_status);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('business_name', 'like', "%{$search}%")
                  ->orWhereHas('owner', function ($oq) use ($search) {
                      $oq->where('full_name', 'like', "%{$search}%")
                         ->orWhere('phone', 'like', "%{$search}%");
                  });
            });
        }

        $organizations = $query->paginate(20)->withQueryString();
        return view('admin.organizations.index', compact('organizations'));
    }

    public function create()
    {
        $plans = SubscriptionPlan::where('status', 'active')->get();
        return view('admin.organizations.create', compact('plans'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'full_name' => 'required|string|max:255',
            'phone' => 'required|string|unique:users,phone',
            'email' => 'nullable|email|unique:users,email',
            'business_name' => 'required|string|max:255',
            'password' => 'required|string|min:6',
            'plan_id' => 'nullable|uuid|exists:subscription_plans,id',
            'start_date' => 'nullable|date',
        ]);

        $owner = \App\Models\User::create([
            'id' => (string) Str::uuid(),
            'full_name' => $request->full_name,
            'phone' => $request->phone,
            'email' => $request->email,
            'password' => \Illuminate\Support\Facades\Hash::make($request->password),
            'role' => 'landlord',
            'status' => 'active',
        ]);

        $organization = Organization::create([
            'id' => (string) Str::uuid(),
            'owner_user_id' => $owner->id,
            'business_name' => $request->business_name,
            'kyc_status' => 'pending',
            'status' => 'active',
            'sms_balance' => 0,
        ]);

        $owner->update(['organization_id' => $organization->id]);

        if ($request->filled('plan_id')) {
            $this->assignPlanToOrganization($organization, $request->plan_id, $request->start_date ?? now()->toDateString());
        }

        return redirect()->route('admin.organizations')->with('success', 'Landlord / organization created successfully.');
    }

    private function assignPlanToOrganization(Organization $organization, string $planId, string $startDateString)
    {
        $plan = SubscriptionPlan::findOrFail($planId);
        $startDate = \Carbon\Carbon::parse($startDateString);
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
    }

    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:active,suspended,deactivated',
            'reason' => 'nullable|string',
        ]);

        $organization = Organization::findOrFail($id);
        $organization->update([
            'status' => $request->status,
            'suspension_reason' => $request->reason,
        ]);

        if ($organization->owner) {
            $organization->owner->update(['status' => $request->status === 'active' ? 'active' : 'suspended']);
        }

        return redirect()->route('admin.organizations')->with('success', 'Organization status updated to ' . ucfirst($request->status) . '.');
    }

    public function updateKycStatus(Request $request, $id)
    {
        $request->validate(['kyc_status' => 'required|in:pending,approved,rejected']);
        $organization = Organization::findOrFail($id);
        $organization->update(['kyc_status' => $request->kyc_status]);
        return redirect()->route('admin.organizations.show', $id)->with('success', 'KYC status updated.');
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
        $this->assignPlanToOrganization($organization, $request->plan_id, $request->start_date);

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
