<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Property;
use Illuminate\Http\Request;

class PropertyController extends Controller
{
    public function __construct()
    {
        $this->middleware(['auth']);
    }

    public function index(Request $request)
    {
        $properties = Property::with(['organization', 'units'])
            ->withCount('units as units_count')
            ->latest()
            ->paginate(20);
        return view('admin.properties.index', compact('properties'));
    }

    public function show($id)
    {
        $property = Property::with(['organization', 'units'])
            ->withCount('units as units_count')
            ->findOrFail($id);
        return view('admin.properties.show', compact('property'));
    }
}
