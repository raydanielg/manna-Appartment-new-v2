<?php

namespace App\Http\Controllers\Api\SuperAdmin;

use App\Http\Controllers\Controller;
use App\Models\SubscriptionPlan;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class SubscriptionPlanController extends Controller
{
    use ApiResponse;

    public function index()
    {
        return $this->success('Plans retrieved.', SubscriptionPlan::all());
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'price' => 'required|numeric|min:0',
            'billing_cycle' => 'required|string|in:monthly,yearly',
            'property_limit' => 'required|integer|min:0',
            'unit_limit' => 'required|integer|min:0',
            'sms_included' => 'required|integer|min:0',
            'features_json' => 'nullable|array',
        ]);

        $plan = SubscriptionPlan::create($request->only([
            'name', 'price', 'billing_cycle', 'property_limit', 'unit_limit', 'sms_included', 'features_json',
        ]));

        return $this->success('Plan created.', $plan, 201);
    }

    public function update(Request $request, $id)
    {
        $plan = SubscriptionPlan::findOrFail($id);
        $plan->update($request->only([
            'name', 'price', 'billing_cycle', 'property_limit', 'unit_limit', 'sms_included', 'features_json', 'status',
        ]));

        return $this->success('Plan updated.', $plan);
    }
}
