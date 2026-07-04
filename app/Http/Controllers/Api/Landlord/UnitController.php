<?php

namespace App\Http\Controllers\Api\Landlord;

use App\Http\Controllers\Controller;
use App\Models\Property;
use App\Models\Unit;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class UnitController extends Controller
{
    use ApiResponse;

    public function index(Request $request, $propertyId)
    {
        $property = Property::findOrFail($propertyId);
        $units = $property->units()->paginate($request->get('per_page', 20));
        return $this->paginated($units);
    }

    public function store(Request $request, $propertyId)
    {
        Property::findOrFail($propertyId);

        $request->validate([
            'name' => 'required|string|max:255',
            'type' => 'required|string|max:255',
            'rent_amount' => 'required|numeric|min:0',
            'description' => 'nullable|string',
        ]);

        $unit = Unit::create(array_merge(
            $request->only(['name', 'type', 'rent_amount', 'description']),
            ['property_id' => $propertyId]
        ));

        return $this->success('Unit created.', $unit, 201);
    }

    public function update(Request $request, $id)
    {
        $unit = Unit::findOrFail($id);
        $unit->update($request->only(['name', 'type', 'rent_amount', 'status', 'description']));
        return $this->success('Unit updated.', $unit);
    }

    public function destroy($id)
    {
        $unit = Unit::findOrFail($id);
        $unit->delete();
        return $this->success('Unit deleted.');
    }

    public function allUnits(Request $request)
    {
        $units = Unit::with('property')->paginate($request->get('per_page', 20));
        return $this->paginated($units);
    }
}
