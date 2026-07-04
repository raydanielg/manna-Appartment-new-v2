<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\KycDocument;
use Illuminate\Http\Request;

class KycController extends Controller
{
    public function __construct()
    {
        $this->middleware(['auth']);
    }

    public function index(Request $request)
    {
        $documents = KycDocument::with(['organization', 'reviewer'])->latest()->paginate(20);
        return view('admin.kyc.index', compact('documents'));
    }
}
