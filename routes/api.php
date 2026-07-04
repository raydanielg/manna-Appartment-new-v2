<?php

use App\Http\Controllers\Api\Auth\ForgotPasswordController;
use App\Http\Controllers\Api\Auth\LoginController;
use App\Http\Controllers\Api\Auth\LogoutController;
use App\Http\Controllers\Api\Auth\RegisterLandlordController;
use App\Http\Controllers\Api\Landlord\ContractController;
use App\Http\Controllers\Api\Landlord\FinanceController;
use App\Http\Controllers\Api\Landlord\LandlordDashboardController;
use App\Http\Controllers\Api\Landlord\OrganizationController as LandlordOrganizationController;
use App\Http\Controllers\Api\Landlord\PaymentController;
use App\Http\Controllers\Api\Landlord\PropertyController;
use App\Http\Controllers\Api\Landlord\SmsController;
use App\Http\Controllers\Api\Landlord\StaffManagementController;
use App\Http\Controllers\Api\Landlord\SubscriptionController;
use App\Http\Controllers\Api\Landlord\TenantController;
use App\Http\Controllers\Api\Landlord\UnitController;
use App\Http\Controllers\Api\PaymentGatewayController;
use App\Http\Controllers\Api\Staff\StaffDashboardController;
use App\Http\Controllers\Api\Staff\StaffPaymentController;
use App\Http\Controllers\Api\Staff\StaffTenantController;
use App\Http\Controllers\Api\SuperAdmin\AnalyticsController;
use App\Http\Controllers\Api\SuperAdmin\KycReviewController;
use App\Http\Controllers\Api\SuperAdmin\OrganizationController;
use App\Http\Controllers\Api\SuperAdmin\RevenueController;
use App\Http\Controllers\Api\SuperAdmin\SubscriptionPlanController;
use App\Http\Controllers\Api\Tenant\MaintenanceRequestController as TenantMaintenanceRequestController;
use App\Http\Controllers\Api\Tenant\MyContractController;
use App\Http\Controllers\Api\Tenant\TenantDashboardController;
use App\Http\Controllers\Api\Tenant\MyPaymentController;
use App\Http\Controllers\Api\Tenant\MyUnitController;
use App\Http\Controllers\Api\Tenant\ProfileController as TenantProfileController;
use App\Http\Controllers\Api\UploadController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Health check at /api root
Route::get('/', function () {
    return response()->json([
        'status' => 'ok',
        'service' => 'Manna Apartment API',
        'version' => 'v1',
        'endpoints' => [
            'login' => '/api/v1/auth/login',
            'register' => '/api/v1/auth/register-landlord',
            'forgot_password' => '/api/v1/auth/forgot-password',
            'verify_otp' => '/api/v1/auth/verify-otp',
            'reset_password' => '/api/v1/auth/reset-password',
        ],
    ]);
});

Route::prefix('v1')->group(function () {

    // Health check at /api/v1 root
    Route::get('/', function () {
        return response()->json([
            'status' => 'ok',
            'service' => 'Manna Apartment API',
            'version' => 'v1',
            'endpoints' => [
                'login' => '/api/v1/auth/login',
                'register' => '/api/v1/auth/register-landlord',
                'forgot_password' => '/api/v1/auth/forgot-password',
                'verify_otp' => '/api/v1/auth/verify-otp',
                'reset_password' => '/api/v1/auth/reset-password',
            ],
        ]);
    });

    // Public auth
    Route::post('/auth/login', [LoginController::class, 'login']);
    Route::post('/auth/register-landlord', [RegisterLandlordController::class, 'register']);
    Route::post('/auth/forgot-password', [ForgotPasswordController::class, 'forgot']);
    Route::post('/auth/verify-otp', [ForgotPasswordController::class, 'verifyOtp']);
    Route::post('/auth/reset-password', [ForgotPasswordController::class, 'reset']);

    // Payment gateway callbacks (public webhooks)
    Route::post('/payments-gateway/callback', [PaymentGatewayController::class, 'callback']);

    // Authenticated routes
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/auth/logout', [LogoutController::class, 'logout']);

        // Uploads
        Route::post('/uploads/image', [UploadController::class, 'image']);
        Route::post('/uploads/document', [UploadController::class, 'document']);

        // Super Admin (web only)
        Route::middleware(['ensure.platform:web', 'role:super_admin'])->prefix('admin')->group(function () {
            Route::get('/organizations', [OrganizationController::class, 'index']);
            Route::get('/organizations/{id}', [OrganizationController::class, 'show']);
            Route::patch('/organizations/{id}/suspend', [OrganizationController::class, 'suspend']);
            Route::patch('/organizations/{id}/activate', [OrganizationController::class, 'activate']);

            Route::get('/kyc/pending', [KycReviewController::class, 'pending']);
            Route::patch('/kyc/{id}/review', [KycReviewController::class, 'review']);

            Route::get('/plans', [SubscriptionPlanController::class, 'index']);
            Route::post('/plans', [SubscriptionPlanController::class, 'store']);
            Route::patch('/plans/{id}', [SubscriptionPlanController::class, 'update']);

            Route::get('/revenue', [RevenueController::class, 'index']);
            Route::get('/analytics', [AnalyticsController::class, 'index']);
            Route::get('/sms-usage', [AnalyticsController::class, 'smsUsage']);
        });

        // Staff (web only)
        Route::middleware(['ensure.platform:web', 'role:staff'])->prefix('staff')->group(function () {
            Route::get('/dashboard', [StaffDashboardController::class, 'index']);
            Route::get('/tenants', [StaffTenantController::class, 'index']);
            Route::get('/tenants/{id}', [StaffTenantController::class, 'show']);
            Route::get('/payments', [StaffPaymentController::class, 'index']);
            Route::post('/payments', [StaffPaymentController::class, 'store']);
            Route::get('/units', [\App\Http\Controllers\Api\Landlord\UnitController::class, 'allUnits']);
        });

        // Landlord (mobile only)
        Route::middleware(['ensure.platform:mobile', 'role:landlord'])->prefix('landlord')->group(function () {
            Route::get('/dashboard', [LandlordDashboardController::class, 'index']);
            Route::get('/organization', [LandlordOrganizationController::class, 'show']);
            Route::patch('/organization', [LandlordOrganizationController::class, 'update']);
            Route::get('/organization/usage', [LandlordOrganizationController::class, 'usage']);
            Route::post('/kyc/submit', [LandlordOrganizationController::class, 'submitKyc']);
            Route::get('/kyc/status', [LandlordOrganizationController::class, 'kycStatus']);

            Route::get('/properties', [PropertyController::class, 'index']);
            Route::post('/properties', [PropertyController::class, 'store']);
            Route::get('/properties/{id}', [PropertyController::class, 'show']);
            Route::patch('/properties/{id}', [PropertyController::class, 'update']);
            Route::delete('/properties/{id}', [PropertyController::class, 'destroy']);

            Route::get('/properties/{propertyId}/units', [UnitController::class, 'index']);
            Route::post('/properties/{propertyId}/units', [UnitController::class, 'store']);
            Route::patch('/units/{id}', [UnitController::class, 'update']);
            Route::delete('/units/{id}', [UnitController::class, 'destroy']);

            Route::get('/tenants', [TenantController::class, 'index']);
            Route::post('/tenants', [TenantController::class, 'store']);
            Route::get('/tenants/{id}', [TenantController::class, 'show']);
            Route::patch('/tenants/{id}', [TenantController::class, 'update']);
            Route::post('/tenants/{id}/move-out', [TenantController::class, 'moveOut']);

            Route::get('/contracts', [ContractController::class, 'index']);
            Route::post('/contracts', [ContractController::class, 'store']);
            Route::get('/contracts/{id}', [ContractController::class, 'show']);
            Route::patch('/contracts/{id}', [ContractController::class, 'update']);
            Route::post('/contracts/{id}/renew', [ContractController::class, 'renew']);
            Route::post('/contracts/{id}/terminate', [ContractController::class, 'terminate']);
            Route::get('/contracts/{id}/pdf', [ContractController::class, 'pdf']);

            Route::get('/payments', [PaymentController::class, 'index']);
            Route::post('/payments', [PaymentController::class, 'store']);
            Route::get('/tenants/{id}/payments', [PaymentController::class, 'tenantPayments']);

            Route::get('/finance/summary', [FinanceController::class, 'summary']);
            Route::get('/finance/income-trend', [FinanceController::class, 'incomeTrend']);
            Route::get('/finance/outstanding-balances', [FinanceController::class, 'outstandingBalances']);
            Route::get('/finance/export', [FinanceController::class, 'export']);

            Route::post('/sms/send', [SmsController::class, 'send']);
            Route::get('/sms/logs', [SmsController::class, 'logs']);
            Route::get('/sms/balance', [SmsController::class, 'balance']);

            Route::get('/subscriptions/plans', [SubscriptionController::class, 'plans']);
            Route::get('/subscriptions/current', [SubscriptionController::class, 'current']);
            Route::post('/subscriptions/subscribe', [SubscriptionController::class, 'subscribe']);
            Route::get('/subscriptions/invoices', [SubscriptionController::class, 'invoices']);

            Route::get('/staff', [StaffManagementController::class, 'index']);
            Route::post('/staff', [StaffManagementController::class, 'store']);
            Route::patch('/staff/{id}/permissions', [StaffManagementController::class, 'updatePermissions']);
            Route::delete('/staff/{id}', [StaffManagementController::class, 'destroy']);

            Route::get('/maintenance-requests', [\App\Http\Controllers\Api\Landlord\MaintenanceRequestController::class, 'index']);
            Route::patch('/maintenance-requests/{id}/status', [\App\Http\Controllers\Api\Landlord\MaintenanceRequestController::class, 'updateStatus']);
        });

        // Tenant (mobile only)
        Route::middleware(['ensure.platform:mobile', 'role:tenant'])->prefix('tenant')->group(function () {
            Route::get('/dashboard', [TenantDashboardController::class, 'index']);
            Route::get('/profile', [TenantProfileController::class, 'show']);
            Route::patch('/profile', [TenantProfileController::class, 'update']);
            Route::post('/profile/change-password', [TenantProfileController::class, 'changePassword']);
            Route::get('/my-unit', [MyUnitController::class, 'show']);
            Route::get('/my-contract', [MyContractController::class, 'show']);
            Route::get('/my-contract/pdf', [MyContractController::class, 'pdf']);
            Route::get('/my-payments', [MyPaymentController::class, 'index']);
            Route::post('/maintenance-requests', [TenantMaintenanceRequestController::class, 'store']);
            Route::get('/maintenance-requests', [TenantMaintenanceRequestController::class, 'index']);
            Route::get('/my-maintenance-requests', [TenantMaintenanceRequestController::class, 'index']);
            Route::get('/notifications', [TenantProfileController::class, 'notifications']);
        });
    });

    // Payment gateway (public initiate/verify)
    Route::post('/payments-gateway/initiate', [PaymentGatewayController::class, 'initiate']);
    Route::get('/payments-gateway/verify/{ref}', [PaymentGatewayController::class, 'verify']);
});
