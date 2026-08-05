<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Providers\RouteServiceProvider;
use Illuminate\Foundation\Auth\AuthenticatesUsers;

class LoginController extends Controller
{
    /*
    |--------------------------------------------------------------------------
    | Login Controller
    |--------------------------------------------------------------------------
    |
    | This controller handles authenticating users for the application and
    | redirecting them to your home screen. The controller uses a trait
    | to conveniently provide its functionality to your applications.
    |
    */

    use AuthenticatesUsers;

    /**
     * Where to redirect users after login.
     *
     * @var string
     */
    protected $redirectTo = RouteServiceProvider::HOME;

    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware('guest')->except('logout');
    }

    public function username()
    {
        return 'phone';
    }

    protected function credentials(\Illuminate\Http\Request $request)
    {
        $phone = $request->input('phone');
        
        // Remove any non-digits
        $phone = preg_replace('/\D/', '', $phone);
        
        // If it starts with 0, replace with 255
        if (str_starts_with($phone, '0')) {
            $phone = '255' . substr($phone, 1);
        }
        
        // If it's exactly 9 digits, prepend 255
        if (strlen($phone) === 9) {
            $phone = '255' . $phone;
        }

        return [
            'phone' => $phone,
            'password' => $request->input('password'),
        ];
    }

    protected function redirectTo()
    {
        if (auth()->user()->role === 'super_admin') {
            return '/admin/dashboard';
        }
        return '/home';
    }
}
