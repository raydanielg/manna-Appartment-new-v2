<?php

namespace App\Http\Controllers;

class StaticPageController extends Controller
{
    public function privacy()
    {
        return view('static.privacy');
    }

    public function terms()
    {
        return view('static.terms');
    }
}
