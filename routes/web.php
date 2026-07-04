<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

use App\Http\Controllers\Admin\AnalyticsController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\KycController;
use App\Http\Controllers\Admin\OrganizationController;
use App\Http\Controllers\Admin\PlanController;
use App\Http\Controllers\Admin\NotificationController;
use App\Http\Controllers\Admin\RevenueController;
use App\Http\Controllers\Admin\SettingsController;
use App\Http\Controllers\Admin\SmsLogController;
use App\Http\Controllers\Admin\TenantController;
use App\Models\User;
use Illuminate\Http\Request;

Route::post('/check-phone', function (Request $request) {
    return response()->json(['exists' => User::where('phone', $request->phone)->exists()]);
})->name('api.check.phone');

Route::get('/', function () {
    if (auth()->check() && auth()->user()->role === 'super_admin') {
        return redirect('/admin/dashboard');
    }
    if (auth()->check()) {
        return redirect('/home');
    }
    return redirect()->route('login');
});

// Static pages
Route::get('/privacy', [App\Http\Controllers\StaticPageController::class, 'privacy'])->name('privacy');
Route::get('/terms', [App\Http\Controllers\StaticPageController::class, 'terms'])->name('terms');

// Custom SMS OTP password reset
Route::get('forgot-password', [App\Http\Controllers\Auth\ForgotPasswordController::class, 'showForgotForm'])->name('password.request');
Route::post('forgot-password', [App\Http\Controllers\Auth\ForgotPasswordController::class, 'sendOtp'])->name('password.send.otp');
Route::get('verify-otp', [App\Http\Controllers\Auth\ForgotPasswordController::class, 'showVerifyForm'])->name('password.verify.form');
Route::post('verify-otp', [App\Http\Controllers\Auth\ForgotPasswordController::class, 'verifyOtp'])->name('password.verify.otp');
Route::get('reset-password', [App\Http\Controllers\Auth\ForgotPasswordController::class, 'showResetForm'])->name('password.reset.form');
Route::post('reset-password', [App\Http\Controllers\Auth\ForgotPasswordController::class, 'resetPassword'])->name('password.update.reset');

Auth::routes(['reset' => false]);

Route::get('/home', [App\Http\Controllers\HomeController::class, 'index'])->name('home');

Route::middleware(['auth', 'role:super_admin'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
    Route::get('/organizations', [OrganizationController::class, 'index'])->name('organizations');
    Route::get('/organizations/create', [OrganizationController::class, 'create'])->name('organizations.create');
    Route::post('/organizations', [OrganizationController::class, 'store'])->name('organizations.store');
    Route::get('/organizations/{id}', [OrganizationController::class, 'show'])->name('organizations.show');
    Route::post('/organizations/{id}/assign-plan', [OrganizationController::class, 'assignPlan'])->name('organizations.assign-plan');
    Route::patch('/organizations/{id}/status', [OrganizationController::class, 'updateStatus'])->name('organizations.update-status');
    Route::patch('/organizations/{id}/kyc', [OrganizationController::class, 'updateKycStatus'])->name('organizations.update-kyc');
    Route::delete('/organizations/{id}', [OrganizationController::class, 'destroy'])->name('organizations.destroy');
    Route::get('/properties', [\App\Http\Controllers\Admin\PropertyController::class, 'index'])->name('properties');
    Route::get('/properties/{id}', [\App\Http\Controllers\Admin\PropertyController::class, 'show'])->name('properties.show');
    Route::get('/kyc', [KycController::class, 'index'])->name('kyc');
    Route::post('/kyc/{id}/review', [KycController::class, 'review'])->name('kyc.review');
    Route::get('/plans', [PlanController::class, 'index'])->name('plans');
    Route::put('/plans/{id}', [PlanController::class, 'update'])->name('plans.update');
    Route::get('/revenue', [RevenueController::class, 'index'])->name('revenue');
    Route::get('/analytics', [AnalyticsController::class, 'index'])->name('analytics');
    Route::get('/sms-logs', [SmsLogController::class, 'index'])->name('sms_logs');
    Route::get('/settings', [SettingsController::class, 'index'])->name('settings');
    Route::put('/settings', [SettingsController::class, 'update'])->name('settings.update');
    Route::post('/settings', [SettingsController::class, 'store'])->name('settings.store');
    Route::delete('/settings/{id}', [SettingsController::class, 'destroy'])->name('settings.destroy');

    Route::get('/tenants', [TenantController::class, 'index'])->name('tenants.index');
    Route::get('/tenants/{id}', [TenantController::class, 'show'])->name('tenants.show');
    Route::delete('/tenants/{id}', [TenantController::class, 'destroy'])->name('tenants.destroy');

    Route::get('/notifications', [NotificationController::class, 'index'])->name('notifications.index');
    Route::post('/notifications', [NotificationController::class, 'store'])->name('notifications.store');
    Route::delete('/notifications/{id}', [NotificationController::class, 'destroy'])->name('notifications.destroy');
});
