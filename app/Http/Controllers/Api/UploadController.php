<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class UploadController extends Controller
{
    use ApiResponse;

    public function image(Request $request)
    {
        $request->validate(['file' => 'required|image|max:5120']);
        $path = Storage::disk('public')->put('images', $request->file('file'));
        return $this->success('Image uploaded.', ['url' => Storage::disk('public')->url($path)]);
    }

    public function document(Request $request)
    {
        $request->validate(['file' => 'required|mimes:jpg,png,pdf|max:5120']);
        $path = Storage::disk('public')->put('documents', $request->file('file'));
        return $this->success('Document uploaded.', ['url' => Storage::disk('public')->url($path)]);
    }
}
