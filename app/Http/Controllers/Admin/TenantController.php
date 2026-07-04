<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Tenant;
use Illuminate\Http\Request;

class TenantController extends Controller
{
    public function __construct()
    {
        $this->middleware(['auth']);
    }

    public function index(Request $request)
    {
        $search = $request->input('search');

        $tenants = Tenant::with(['user', 'organization', 'unit'])
            ->when($search, function ($query) use ($search) {
                $query->whereHas('user', function ($q) use ($search) {
                    $q->where('full_name', 'like', "%{$search}%")
                      ->orWhere('phone', 'like', "%{$search}%");
                });
            })
            ->latest()
            ->paginate(15)
            ->withQueryString();

        return view('admin.tenants.index', compact('tenants', 'search'));
    }

    public function show($id)
    {
        $tenant = Tenant::with(['user', 'organization', 'unit', 'payments', 'contracts'])->findOrFail($id);
        return view('admin.tenants.show', compact('tenant'));
    }

    public function destroy($id)
    {
        $tenant = Tenant::findOrFail($id);
        $tenant->delete();

        return redirect()->route('admin.tenants.index')
            ->with('success', 'Tenant removed successfully.');
    }
}
