<?php

namespace App\Http\Controllers\Api\Landlord;

use App\Http\Controllers\Controller;
use App\Models\Property;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class PropertyController extends Controller
{
    use ApiResponse;

    private function organizationQuery()
    {
        $organization = Auth::user()->organization;
        return Property::where('organization_id', $organization->id);
    }

    public function index(Request $request)
    {
        $query = $this->organizationQuery()
            ->withCount('units as units_count')
            ->with(['units' => fn ($q) => $q->where('status', 'occupied')]);

        $properties = $query->paginate($request->get('per_page', 20));

        $properties->getCollection()->transform(function ($property) {
            return $this->formatProperty($property);
        });

        return $this->paginated($properties);
    }

    public function store(Request $request)
    {
        try {
            $request->validate([
                'name' => 'required|string|max:255',
                'address' => 'required|string|max:255',
                'location' => 'nullable|string|max:255',
                'type' => 'required|string|max:255',
                'description' => 'nullable|string',
                'images' => 'nullable|array',
                'images.*' => 'image|mimes:jpeg,png,jpg,webp|max:5120',
            ]);
        } catch (\Illuminate\Validation\ValidationException $e) {
            Log::error('Property validation failed', [
                'errors' => $e->errors(),
                'input' => $request->except('images'),
            ]);
            throw $e;
        }

        $organization = Auth::user()->organization;

        $images = [];
        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $image) {
                $images[] = $image->store('properties', 'public');
            }
        }

        $property = Property::create([
            'organization_id' => $organization->id,
            'name' => $request->name,
            'address' => $request->address,
            'location' => $request->location ?? $request->address,
            'type' => $request->type,
            'description' => $request->description,
            'images_json' => $images,
            'status' => 'active',
        ]);

        return $this->success('Property created.', $this->formatProperty($property->loadCount('units as units_count')->load('units')), 201);
    }

    public function show($id)
    {
        $property = $this->organizationQuery()->withCount('units as units_count')->with('units')->findOrFail($id);
        return $this->success('Property retrieved.', $this->formatProperty($property));
    }

    public function update(Request $request, $id)
    {
        $property = $this->organizationQuery()->findOrFail($id);

        $request->validate([
            'name' => 'nullable|string|max:255',
            'address' => 'nullable|string|max:255',
            'location' => 'nullable|string|max:255',
            'type' => 'nullable|string|max:255',
            'description' => 'nullable|string',
            'status' => 'nullable|in:active,inactive',
        ]);

        $property->update($request->only(['name', 'address', 'location', 'type', 'description', 'status']));
        return $this->success('Property updated.', $this->formatProperty($property));
    }

    public function destroy($id)
    {
        $property = $this->organizationQuery()->findOrFail($id);
        $property->delete();
        return $this->success('Property deleted.');
    }

    private function formatProperty(Property $property)
    {
        $images = $property->images_json ?? [];
        $occupiedUnits = $property->units->where('status', 'occupied')->count();
        $unitsCount = $property->units_count ?? $property->units->count();

        return [
            'id' => $property->id,
            'name' => $property->name,
            'address' => $property->address,
            'location' => $property->location,
            'type' => $property->type,
            'description' => $property->description,
            'status' => $property->status,
            'units_count' => $unitsCount,
            'occupied_units' => $occupiedUnits,
            'vacant_units' => max(0, $unitsCount - $occupiedUnits),
            'image_url' => $images ? Storage::url($images[0]) : null,
            'images' => array_map(fn ($img) => Storage::url($img), $images),
            'created_at' => $property->created_at,
            'updated_at' => $property->updated_at,
        ];
    }
}
