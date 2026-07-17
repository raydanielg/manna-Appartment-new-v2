<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\SubscriptionPlan;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class PlanController extends Controller
{
    public function __construct()
    {
        $this->middleware(['auth']);
    }

    public function index(Request $request)
    {
        $plans = SubscriptionPlan::latest()->get();
        return view('admin.plans.index', compact('plans'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'price' => 'required|numeric|min:0',
            'billing_cycle' => 'required|in:monthly,yearly,trial',
            'property_limit' => 'required|integer|min:0',
            'unit_limit' => 'required|integer|min:0',
            'sms_included' => 'required|integer|min:0',
            'features_json' => 'nullable|string',
            'status' => 'required|in:active,inactive',
        ]);

        $features = [];
        if ($request->features_json) {
            $features = array_map('trim', explode(',', $request->features_json));
        }

        SubscriptionPlan::create([
            'id' => (string) Str::uuid(),
            'name' => $request->name,
            'price' => $request->price,
            'billing_cycle' => $request->billing_cycle,
            'property_limit' => $request->property_limit,
            'unit_limit' => $request->unit_limit,
            'sms_included' => $request->sms_included,
            'features_json' => $features,
            'status' => $request->status,
        ]);

        return redirect()->route('admin.plans')->with('success', 'Plan created successfully.');
    }

    public function update(Request $request, $id)
    {
        $plan = SubscriptionPlan::findOrFail($id);

        $request->validate([
            'name' => 'required|string|max:255',
            'price' => 'required|numeric|min:0',
            'billing_cycle' => 'required|in:monthly,yearly,trial',
            'property_limit' => 'required|integer|min:0',
            'unit_limit' => 'required|integer|min:0',
            'sms_included' => 'required|integer|min:0',
            'features_json' => 'nullable|string',
            'status' => 'required|in:active,inactive',
        ]);

        $features = [];
        if ($request->features_json) {
            $features = array_map('trim', explode(',', $request->features_json));
        }

        $plan->update([
            'name' => $request->name,
            'price' => $request->price,
            'billing_cycle' => $request->billing_cycle,
            'property_limit' => $request->property_limit,
            'unit_limit' => $request->unit_limit,
            'sms_included' => $request->sms_included,
            'features_json' => $features,
            'status' => $request->status,
        ]);

        return redirect()->route('admin.plans')->with('success', 'Plan updated successfully.');
    }

    public function destroy($id)
    {
        $plan = SubscriptionPlan::findOrFail($id);
        $plan->delete();

        return redirect()->route('admin.plans')->with('success', 'Plan deleted successfully.');
    }
}
