<?php

namespace App\Http\Controllers\Api\Landlord;

use App\Http\Controllers\Controller;
use App\Models\Property;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class PropertyController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $query = Property::withCount('units');
        return $this->paginated($query->paginate($request->get('per_page', 20)));
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'location' => 'required|string|max:255',
            'type' => 'required|string|max:255',
            'description' => 'nullable|string',
        ]);

        $property = Property::create($request->only(['name', 'location', 'type', 'description']));
        return $this->success('Property created.', $property, 201);
    }

    public function show($id)
    {
        $property = Property::with('units')->findOrFail($id);
        return $this->success('Property retrieved.', $property);
    }

    public function update(Request $request, $id)
    {
        $property = Property::findOrFail($id);
        $property->update($request->only(['name', 'location', 'type', 'description', 'status']));
        return $this->success('Property updated.', $property);
    }

    public function destroy($id)
    {
        $property = Property::findOrFail($id);
        $property->delete();
        return $this->success('Property deleted.');
    }
}
