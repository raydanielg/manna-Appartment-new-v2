<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Organization;
use Illuminate\Http\Request;

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
}
