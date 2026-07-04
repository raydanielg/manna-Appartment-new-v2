<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\Request;

class SettingsController extends Controller
{
    public function __construct()
    {
        $this->middleware(['auth']);
    }

    public function index(Request $request)
    {
        $settings = Setting::orderBy('group')->orderBy('label')->get()->groupBy('group');
        return view('admin.settings.index', compact('settings'));
    }

    public function update(Request $request)
    {
        $data = $request->except(['_token', '_method']);

        foreach ($data as $key => $value) {
            Setting::where('key', $key)->update(['value' => $value]);
        }

        return redirect()->route('admin.settings')->with('success', 'Settings updated successfully.');
    }

    public function store(Request $request)
    {
        $request->validate([
            'key' => 'required|string|unique:settings,key',
            'value' => 'nullable|string',
            'group' => 'required|string',
            'label' => 'required|string',
            'type' => 'required|in:text,textarea,boolean,number',
        ]);

        Setting::create($request->all());

        return redirect()->route('admin.settings')->with('success', 'Setting added successfully.');
    }

    public function destroy($id)
    {
        Setting::findOrFail($id)->delete();
        return redirect()->route('admin.settings')->with('success', 'Setting deleted successfully.');
    }
}
