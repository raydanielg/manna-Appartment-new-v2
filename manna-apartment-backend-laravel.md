# MANNA APARTMENT — BACKEND ARCHITECTURE (LARAVEL EDITION)
## Complete Backend Blueprint — Laravel API + Flutter Mobile App + Web Admin Panel

---

## 1. UPDATED ARCHITECTURE OVERVIEW

**Important correction to platform/role mapping:**

| Platform | Who logs in here |
|----------|-------------------|
| **Web Admin Panel** | Super Admin ONLY, and Staff ONLY |
| **Mobile App (Flutter)** | Landlord ONLY, and Tenant ONLY |

So the Landlord does **NOT** use the web panel at all — the landlord manages everything (properties, tenants, contracts, payments) from the **Flutter mobile app**, same as tenants. The **Web Admin Panel** is reserved strictly for **Super Admin** (platform owner) and **Staff** (landlord's employees, if the landlord chooses to add them — staff still log in via web, e.g., if a landlord hires an office-based accountant/caretaker who prefers a desktop).

```
                     ┌───────────────────────────┐
                     │   MANNA APARTMENT API       │
                     │        (Laravel)             │
                     └──────────────┬───────────────┘
                                     │
             ┌───────────────────────┼───────────────────────┐
             │                                                │
   ┌─────────▼──────────┐                          ┌──────────▼─────────────┐
   │   WEB ADMIN PANEL    │                          │      MOBILE APP           │
   │  (React.js / Blade)  │                          │      (Flutter)            │
   │                       │                          │                           │
   │  - Super Admin login  │                          │  - Landlord login          │
   │  - Staff login        │                          │  - Tenant login            │
   └───────────────────────┘                          └───────────────────────────┘
```

**Login is still simple: phone number + password. No 2FA anywhere in the system.**

---

## 2. TECH STACK (UPDATED)

- **Backend Framework:** Laravel 11 (PHP 8.3+)
- **API Auth:** Laravel Sanctum (token-based, perfect for both SPA web panel + Flutter mobile app)
- **Database:** MySQL (or PostgreSQL — MySQL is more common in Laravel hosting environments)
- **Queue System:** Laravel Queues + Redis (for SMS sending, PDF generation, reminders)
- **Task Scheduling:** Laravel Task Scheduler (cron-based) — for rent reminders, contract expiry checks, subscription expiry
- **File Storage:** Laravel Filesystem → AWS S3 / local disk (KYC documents, property photos, contract PDFs)
- **PDF Generation:** barryvdh/laravel-dompdf or Spatie's PDF package
- **SMS Gateway:** Beem Africa / Africa's Talking (via Laravel HTTP Client)
- **Mobile App:** Flutter (Dart) — single codebase for Android & iOS, used by Landlord + Tenant
- **Web Admin Panel Frontend:** React.js (calling Laravel API) OR Laravel Blade + Livewire (simpler, fully server-rendered — good option since only Admin + Staff use it, less need for a heavy SPA)
- **API Documentation:** Laravel Scribe or Swagger (l5-swagger)
- **Testing:** PHPUnit / Pest
- **Containerization:** Docker + docker-compose (Laravel Sail optional for local dev)

---

## 3. LARAVEL FOLDER STRUCTURE

```
manna-apartment-backend/
│
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── Api/
│   │   │   │   ├── Auth/
│   │   │   │   │   ├── LoginController.php
│   │   │   │   │   ├── RegisterLandlordController.php
│   │   │   │   │   ├── ForgotPasswordController.php
│   │   │   │   │   └── LogoutController.php
│   │   │   │   │
│   │   │   │   ├── SuperAdmin/                     # Web-only endpoints
│   │   │   │   │   ├── OrganizationController.php
│   │   │   │   │   ├── KycReviewController.php
│   │   │   │   │   ├── SubscriptionPlanController.php
│   │   │   │   │   ├── RevenueController.php
│   │   │   │   │   └── AnalyticsController.php
│   │   │   │   │
│   │   │   │   ├── Staff/                          # Web-only endpoints
│   │   │   │   │   ├── StaffDashboardController.php
│   │   │   │   │   ├── StaffPaymentController.php
│   │   │   │   │   └── StaffTenantController.php
│   │   │   │   │
│   │   │   │   ├── Landlord/                       # Mobile-only endpoints
│   │   │   │   │   ├── PropertyController.php
│   │   │   │   │   ├── UnitController.php
│   │   │   │   │   ├── TenantController.php
│   │   │   │   │   ├── ContractController.php
│   │   │   │   │   ├── PaymentController.php
│   │   │   │   │   ├── FinanceController.php
│   │   │   │   │   ├── SmsController.php
│   │   │   │   │   ├── SubscriptionController.php
│   │   │   │   │   ├── StaffManagementController.php
│   │   │   │   │   └── KycController.php
│   │   │   │   │
│   │   │   │   └── Tenant/                         # Mobile-only endpoints
│   │   │   │       ├── MyUnitController.php
│   │   │   │       ├── MyContractController.php
│   │   │   │       ├── MyPaymentController.php
│   │   │   │       ├── MaintenanceRequestController.php
│   │   │   │       └── ProfileController.php
│   │   │   │
│   │   │   └── Controller.php
│   │   │
│   │   ├── Middleware/
│   │   │   ├── EnsureRole.php                      # checks role: super_admin/staff/landlord/tenant
│   │   │   ├── EnsurePlatform.php                  # blocks landlord/tenant from web, admin/staff from mobile
│   │   │   ├── ScopeToOrganization.php             # injects organization_id filter automatically
│   │   │   ├── CheckSubscriptionActive.php
│   │   │   └── CheckKycApproved.php
│   │   │
│   │   ├── Requests/                               # Form Request validation classes
│   │   │   ├── Auth/
│   │   │   │   ├── LoginRequest.php
│   │   │   │   └── RegisterLandlordRequest.php
│   │   │   ├── Property/
│   │   │   │   ├── StorePropertyRequest.php
│   │   │   │   └── UpdatePropertyRequest.php
│   │   │   ├── Tenant/
│   │   │   ├── Contract/
│   │   │   └── Payment/
│   │   │
│   │   └── Resources/                              # API Resource transformers (response formatting)
│   │       ├── UserResource.php
│   │       ├── PropertyResource.php
│   │       ├── UnitResource.php
│   │       ├── TenantResource.php
│   │       ├── ContractResource.php
│   │       ├── PaymentResource.php
│   │       └── OrganizationResource.php
│   │
│   ├── Models/
│   │   ├── User.php
│   │   ├── Organization.php
│   │   ├── KycDocument.php
│   │   ├── Property.php
│   │   ├── Unit.php
│   │   ├── Tenant.php
│   │   ├── Contract.php
│   │   ├── Payment.php
│   │   ├── SubscriptionPlan.php
│   │   ├── Subscription.php
│   │   ├── SmsLog.php
│   │   ├── StaffPermission.php
│   │   └── MaintenanceRequest.php
│   │
│   ├── Services/                                   # Business logic layer (keep controllers thin)
│   │   ├── AuthService.php
│   │   ├── KycService.php
│   │   ├── ContractService.php
│   │   ├── ContractPdfService.php
│   │   ├── PaymentService.php
│   │   ├── FinanceReportService.php
│   │   ├── SmsService.php
│   │   ├── SubscriptionService.php
│   │   └── OtpService.php
│   │
│   ├── Jobs/                                       # Queued background jobs
│   │   ├── SendSmsJob.php
│   │   ├── GenerateContractPdfJob.php
│   │   ├── SendRentReminderJob.php
│   │   └── SendPaymentReceiptJob.php
│   │
│   ├── Console/
│   │   └── Commands/
│   │       ├── CheckRentDueCommand.php             # scheduled daily
│   │       ├── CheckContractExpiryCommand.php      # scheduled daily
│   │       ├── CheckSubscriptionExpiryCommand.php  # scheduled daily
│   │       └── CheckOverduePaymentsCommand.php     # scheduled daily
│   │
│   ├── Notifications/
│   │   ├── OtpNotification.php
│   │   ├── WelcomeTenantNotification.php
│   │   ├── RentReminderNotification.php
│   │   ├── PaymentReceiptNotification.php
│   │   └── ContractExpiryNotification.php
│   │
│   ├── Providers/
│   │   └── AppServiceProvider.php
│   │
│   └── Traits/
│       └── BelongsToOrganization.php               # auto-scopes Eloquent models by organization_id
│
├── routes/
│   ├── api.php                                     # main API routes (versioned)
│   ├── web.php                                     # (minimal, mostly unused since it's API-first)
│   └── console.php                                 # scheduled task definitions
│
├── database/
│   ├── migrations/
│   │   ├── create_users_table.php
│   │   ├── create_organizations_table.php
│   │   ├── create_kyc_documents_table.php
│   │   ├── create_properties_table.php
│   │   ├── create_units_table.php
│   │   ├── create_tenants_table.php
│   │   ├── create_contracts_table.php
│   │   ├── create_payments_table.php
│   │   ├── create_subscription_plans_table.php
│   │   ├── create_subscriptions_table.php
│   │   ├── create_sms_logs_table.php
│   │   ├── create_staff_permissions_table.php
│   │   └── create_maintenance_requests_table.php
│   ├── seeders/
│   │   ├── SubscriptionPlanSeeder.php
│   │   └── SuperAdminSeeder.php
│   └── factories/
│
├── config/
│   ├── sanctum.php
│   ├── sms.php                                     # custom config for SMS gateway
│   └── subscription.php                            # custom config for plan limits
│
├── storage/
│   └── app/public/                                 # KYC docs, property photos (or use S3)
│
├── tests/
│   ├── Feature/
│   └── Unit/
│
├── docker-compose.yml
├── Dockerfile
├── .env.example
├── composer.json
└── README.md
```

---

## 4. AUTHENTICATION FLOW (LARAVEL SANCTUM, NO 2FA)

### 4.1 Login — Two Separate Guarded Entry Points

Even though it's the same `/login` logic under the hood, the middleware enforces **which platform each role is allowed to use**:

```
POST /api/v1/auth/login
Body: { phone, password, platform: "web" | "mobile" }
```

- If `role = super_admin` or `role = staff` → only allowed when `platform = web`. Mobile login attempt is rejected with `403 Forbidden: "This account must be accessed via the Web Admin Panel."`
- If `role = landlord` or `role = tenant` → only allowed when `platform = mobile`. Web login attempt is rejected with `403 Forbidden: "This account must be accessed via the Mobile App."`

This is enforced in `EnsurePlatform` middleware right after credentials are validated, **before** issuing the Sanctum token.

### 4.2 Registration (Landlord — via Mobile App only)
```
POST /api/v1/auth/register-landlord
Body: { full_name, phone, password, business_name? }
```
- Creates `User` (role: landlord) + `Organization` record.
- Sends OTP once via SMS to confirm phone ownership (one-time only, not required again).
- After confirmation → account active → prompted to complete KYC directly inside the Flutter app.

### 4.3 Tenant Account Creation (by Landlord, via Mobile App)
```
POST /api/v1/landlord/tenants
```
- Landlord (inside Flutter app) adds tenant → system auto-generates password → SMS sent to tenant with login credentials.
- Tenant opens the same Flutter app → logs in with phone + given password → prompted to set new password on first login.

### 4.4 Staff Account Creation (by Landlord, but Staff logs in via Web)
```
POST /api/v1/landlord/staff
```
- Landlord (from mobile app) creates a staff account and assigns permissions.
- System sends staff their login credentials via SMS.
- Staff logs in **only through the Web Admin Panel** (`platform: "web"`), with permissions limited to what the landlord granted (e.g., record payments, view tenants — no delete, no subscription access).

### 4.5 Forgot Password (both platforms)
```
POST /api/v1/auth/forgot-password   { phone }
POST /api/v1/auth/verify-otp        { phone, otp }
POST /api/v1/auth/reset-password    { phone, otp, new_password }
```

### 4.6 Token Handling (Sanctum)
```
POST /api/v1/auth/logout            (revokes current token)
```
- Sanctum issues a personal access token per login/device.
- Tokens can be scoped with **abilities** (e.g., `staff` tokens get limited abilities like `payments:create`, `tenants:view` — no `contracts:delete`).
- No refresh token complexity needed — Sanctum tokens are simple long-lived API tokens (can be set to expire and require re-login, e.g., every 60 days for mobile).

---

## 5. ROLE & PLATFORM ENFORCEMENT TABLE

| Role | Platform Allowed | Login Credential | Key Permissions |
|------|-------------------|-------------------|------------------|
| **Super Admin** | Web only | phone + password | Manage all organizations, KYC approvals, subscription plans, platform revenue |
| **Staff** | Web only | phone + password | Limited actions under one landlord's organization (set by landlord) |
| **Landlord** | Mobile only (Flutter) | phone + password | Full control of their own organization: properties, units, tenants, contracts, payments, SMS, subscription |
| **Tenant** | Mobile only (Flutter) | phone + password | View own unit, contract, payments, submit maintenance requests |

Enforced via:
```php
// EnsurePlatform middleware (simplified)
public function handle($request, Closure $next)
{
    $user = $request->user();
    $platform = $request->header('X-Platform'); // "web" or "mobile"

    $webOnlyRoles = ['super_admin', 'staff'];
    $mobileOnlyRoles = ['landlord', 'tenant'];

    if (in_array($user->role, $webOnlyRoles) && $platform !== 'web') {
        abort(403, 'This account must be accessed via the Web Admin Panel.');
    }

    if (in_array($user->role, $mobileOnlyRoles) && $platform !== 'mobile') {
        abort(403, 'This account must be accessed via the Mobile App.');
    }

    return $next($request);
}
```
The Flutter app and the Web Admin Panel each send a fixed `X-Platform` header (`mobile` / `web`) with every request, so the backend always knows the origin.

---

## 6. MULTI-TENANCY ENFORCEMENT (LARAVEL)

Every model that belongs to a landlord's organization uses a **global scope** so queries are automatically filtered — no risk of one landlord seeing another's data.

```php
// app/Traits/BelongsToOrganization.php
trait BelongsToOrganization
{
    protected static function bootBelongsToOrganization()
    {
        static::addGlobalScope('organization', function (Builder $builder) {
            if (auth()->check() && auth()->user()->role !== 'super_admin') {
                $builder->where('organization_id', auth()->user()->organization_id);
            }
        });

        static::creating(function ($model) {
            if (auth()->check() && !$model->organization_id) {
                $model->organization_id = auth()->user()->organization_id;
            }
        });
    }
}
```
Applied to: `Property`, `Unit`, `Tenant`, `Contract`, `Payment`, `SmsLog`, `StaffPermission`, `MaintenanceRequest`.

Super Admin bypasses this scope entirely (can view across all organizations from the Web Admin Panel).

---

## 7. FULL API ENDPOINT LIST (v1, Laravel routes/api.php)

### Auth (shared, but platform-checked)
```
POST   /api/v1/auth/login
POST   /api/v1/auth/register-landlord         # mobile only
POST   /api/v1/auth/forgot-password
POST   /api/v1/auth/verify-otp
POST   /api/v1/auth/reset-password
POST   /api/v1/auth/logout
```

### Super Admin (WEB ONLY)
```
GET    /api/v1/admin/organizations
GET    /api/v1/admin/organizations/{id}
PATCH  /api/v1/admin/organizations/{id}/suspend
PATCH  /api/v1/admin/organizations/{id}/activate
GET    /api/v1/admin/kyc/pending
PATCH  /api/v1/admin/kyc/{id}/review
GET    /api/v1/admin/plans
POST   /api/v1/admin/plans
PATCH  /api/v1/admin/plans/{id}
GET    /api/v1/admin/revenue
GET    /api/v1/admin/analytics
GET    /api/v1/admin/sms-usage
```

### Staff (WEB ONLY — scoped to their assigned landlord's organization)
```
GET    /api/v1/staff/dashboard
GET    /api/v1/staff/tenants
GET    /api/v1/staff/tenants/{id}
POST   /api/v1/staff/payments
GET    /api/v1/staff/payments
GET    /api/v1/staff/units
```
*(Exact endpoints visible to staff depend on permissions granted by the landlord — enforced via ability-based Sanctum tokens.)*

### Landlord (MOBILE ONLY — Flutter app)
```
GET    /api/v1/landlord/organization
PATCH  /api/v1/landlord/organization
GET    /api/v1/landlord/organization/usage

POST   /api/v1/landlord/kyc/submit
GET    /api/v1/landlord/kyc/status

GET    /api/v1/landlord/properties
POST   /api/v1/landlord/properties
GET    /api/v1/landlord/properties/{id}
PATCH  /api/v1/landlord/properties/{id}
DELETE /api/v1/landlord/properties/{id}

GET    /api/v1/landlord/properties/{propertyId}/units
POST   /api/v1/landlord/properties/{propertyId}/units
PATCH  /api/v1/landlord/units/{id}
DELETE /api/v1/landlord/units/{id}

GET    /api/v1/landlord/tenants
POST   /api/v1/landlord/tenants
GET    /api/v1/landlord/tenants/{id}
PATCH  /api/v1/landlord/tenants/{id}
POST   /api/v1/landlord/tenants/{id}/move-out

GET    /api/v1/landlord/contracts
POST   /api/v1/landlord/contracts
PATCH  /api/v1/landlord/contracts/{id}
POST   /api/v1/landlord/contracts/{id}/renew
POST   /api/v1/landlord/contracts/{id}/terminate
GET    /api/v1/landlord/contracts/{id}/pdf

GET    /api/v1/landlord/payments
POST   /api/v1/landlord/payments
GET    /api/v1/landlord/tenants/{id}/payments

GET    /api/v1/landlord/finance/summary
GET    /api/v1/landlord/finance/income-trend
GET    /api/v1/landlord/finance/outstanding-balances
GET    /api/v1/landlord/finance/export

POST   /api/v1/landlord/sms/send
GET    /api/v1/landlord/sms/logs
GET    /api/v1/landlord/sms/balance

GET    /api/v1/landlord/subscriptions/plans
GET    /api/v1/landlord/subscriptions/current
POST   /api/v1/landlord/subscriptions/subscribe
GET    /api/v1/landlord/subscriptions/invoices

GET    /api/v1/landlord/staff
POST   /api/v1/landlord/staff
PATCH  /api/v1/landlord/staff/{id}/permissions
DELETE /api/v1/landlord/staff/{id}

GET    /api/v1/landlord/maintenance
PATCH  /api/v1/landlord/maintenance/{id}/status
```

### Tenant (MOBILE ONLY — Flutter app)
```
GET    /api/v1/tenant/profile
PATCH  /api/v1/tenant/profile
GET    /api/v1/tenant/unit
GET    /api/v1/tenant/contract
GET    /api/v1/tenant/contract/pdf
GET    /api/v1/tenant/payments
POST   /api/v1/tenant/maintenance
GET    /api/v1/tenant/maintenance
GET    /api/v1/tenant/notifications
```

### Payment Gateway (webhooks — server to server, no platform header needed)
```
POST   /api/v1/payments-gateway/initiate
POST   /api/v1/payments-gateway/callback
GET    /api/v1/payments-gateway/verify/{ref}
```

### Uploads
```
POST   /api/v1/uploads/image
POST   /api/v1/uploads/document
```

---

## 8. MIDDLEWARE STACK PER ROUTE GROUP

```php
// routes/api.php (structure)

Route::prefix('v1')->group(function () {

    // Public
    Route::post('/auth/login', [LoginController::class, 'login']);
    Route::post('/auth/register-landlord', [RegisterLandlordController::class, 'register']);
    Route::post('/auth/forgot-password', [ForgotPasswordController::class, 'forgot']);
    Route::post('/auth/verify-otp', [ForgotPasswordController::class, 'verifyOtp']);
    Route::post('/auth/reset-password', [ForgotPasswordController::class, 'reset']);

    // Super Admin — WEB ONLY
    Route::middleware(['auth:sanctum', 'ensure.platform:web', 'role:super_admin'])
        ->prefix('admin')->group(function () {
            // organizations, kyc review, plans, revenue...
        });

    // Staff — WEB ONLY
    Route::middleware(['auth:sanctum', 'ensure.platform:web', 'role:staff'])
        ->prefix('staff')->group(function () {
            // limited dashboard, tenants, payments...
        });

    // Landlord — MOBILE ONLY
    Route::middleware(['auth:sanctum', 'ensure.platform:mobile', 'role:landlord'])
        ->prefix('landlord')->group(function () {
            // properties, units, tenants, contracts, payments, sms, subscriptions...
        });

    // Tenant — MOBILE ONLY
    Route::middleware(['auth:sanctum', 'ensure.platform:mobile', 'role:tenant'])
        ->prefix('tenant')->group(function () {
            // profile, unit, contract, payments, maintenance...
        });
});
```

---

## 9. GUARDS / MIDDLEWARE LOGIC SUMMARY

| Middleware | Purpose |
|------------|---------|
| `auth:sanctum` | Validates the Bearer token on every protected request |
| `ensure.platform:web` / `ensure.platform:mobile` | Confirms the request's `X-Platform` header matches what the role is allowed to use |
| `role:super_admin` / `role:staff` / `role:landlord` / `role:tenant` | Confirms the authenticated user's role matches the route group |
| `subscription.active` | Blocks landlord actions (create property, send SMS, generate contract PDF) if subscription expired or plan limit reached |
| `kyc.approved` | Blocks sensitive landlord actions (SMS sending, online payments) until KYC status is `approved` |
| Sanctum **token abilities** | For staff tokens specifically — restricts exactly which endpoints a staff token can call, based on permissions the landlord granted |

---

## 10. BACKGROUND JOBS & SCHEDULED TASKS (Laravel Scheduler)

```php
// routes/console.php or App\Console\Kernel
Schedule::command('rent:check-due')->dailyAt('08:00');
Schedule::command('contracts:check-expiry')->dailyAt('08:00');
Schedule::command('subscriptions:check-expiry')->dailyAt('00:00');
Schedule::command('payments:check-overdue')->dailyAt('09:00');
```

| Command | Action |
|---------|--------|
| `CheckRentDueCommand` | Finds tenants with rent due in X days → dispatches `SendSmsJob` |
| `CheckContractExpiryCommand` | Flags contracts ending in 30/15/7 days → notifies landlord & tenant via SMS + in-app notification |
| `CheckSubscriptionExpiryCommand` | Downgrades/locks landlord accounts with expired subscriptions, sends renewal SMS |
| `CheckOverduePaymentsCommand` | Flags missed payments → sends overdue SMS, updates dashboard flags |

All SMS sending is dispatched through `SendSmsJob` (queued via Redis) so it never blocks the main request/response cycle.

---

## 11. DATABASE SCHEMA (Laravel Migrations — condensed)

```php
Schema::create('users', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->string('full_name');
    $table->string('phone')->unique();
    $table->string('email')->nullable()->unique();
    $table->string('password');
    $table->enum('role', ['super_admin', 'staff', 'landlord', 'tenant']);
    $table->uuid('organization_id')->nullable();
    $table->string('status')->default('active');
    $table->timestamps();
});

Schema::create('organizations', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->uuid('owner_user_id');
    $table->string('business_name')->nullable();
    $table->string('kyc_status')->default('pending');
    $table->uuid('subscription_id')->nullable();
    $table->integer('sms_balance')->default(0);
    $table->timestamps();
});

Schema::create('kyc_documents', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->uuid('organization_id');
    $table->string('id_number');
    $table->string('id_photo_front');
    $table->string('id_photo_back');
    $table->string('selfie_photo');
    $table->string('ownership_proof')->nullable();
    $table->string('status')->default('pending');
    $table->uuid('reviewed_by')->nullable();
    $table->timestamp('reviewed_at')->nullable();
    $table->timestamps();
});

Schema::create('properties', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->uuid('organization_id');
    $table->string('name');
    $table->string('location');
    $table->string('type');
    $table->text('description')->nullable();
    $table->timestamps();
});

Schema::create('units', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->uuid('property_id');
    $table->string('name');
    $table->string('type');
    $table->decimal('rent_amount', 12, 2);
    $table->string('status')->default('vacant');
    $table->text('description')->nullable();
    $table->timestamps();
});

Schema::create('tenants', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->uuid('organization_id');
    $table->uuid('user_id')->unique();
    $table->uuid('unit_id')->nullable()->unique();
    $table->string('id_number')->nullable();
    $table->string('emergency_contact')->nullable();
    $table->date('moved_in_date')->nullable();
    $table->date('moved_out_date')->nullable();
    $table->string('status')->default('active');
    $table->timestamps();
});

Schema::create('contracts', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->uuid('tenant_id');
    $table->uuid('unit_id');
    $table->string('contract_number')->unique();
    $table->enum('duration_type', ['3_months', '6_months', '12_months', 'lifetime', 'custom']);
    $table->date('start_date');
    $table->date('end_date')->nullable();
    $table->decimal('rent_amount', 12, 2);
    $table->decimal('deposit_amount', 12, 2);
    $table->string('status')->default('draft');
    $table->string('pdf_url')->nullable();
    $table->timestamps();
});

Schema::create('payments', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->uuid('contract_id');
    $table->uuid('tenant_id');
    $table->decimal('amount', 12, 2);
    $table->string('method');
    $table->string('reference_number')->nullable();
    $table->date('payment_date');
    $table->string('month_covered');
    $table->uuid('recorded_by');
    $table->string('status')->default('confirmed');
    $table->timestamps();
});

Schema::create('subscription_plans', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->string('name');
    $table->decimal('price', 12, 2);
    $table->string('billing_cycle');
    $table->integer('property_limit');
    $table->integer('unit_limit');
    $table->integer('sms_included');
    $table->json('features_json')->nullable();
    $table->timestamps();
});

Schema::create('subscriptions', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->uuid('organization_id');
    $table->uuid('plan_id');
    $table->date('start_date');
    $table->date('end_date');
    $table->string('status')->default('active');
    $table->string('payment_reference')->nullable();
    $table->timestamps();
});

Schema::create('sms_logs', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->uuid('organization_id');
    $table->string('recipient_phone');
    $table->text('message');
    $table->string('type');
    $table->string('status')->default('queued');
    $table->timestamp('sent_at')->nullable();
    $table->timestamps();
});

Schema::create('staff_permissions', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->uuid('organization_id');
    $table->uuid('staff_user_id');
    $table->json('permissions_json');
    $table->timestamps();
});

Schema::create('maintenance_requests', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->uuid('tenant_id');
    $table->uuid('unit_id');
    $table->text('description');
    $table->string('status')->default('open');
    $table->timestamp('resolved_at')->nullable();
    $table->timestamps();
});
```

---

## 12. ENVIRONMENT VARIABLES (`.env.example`)

```env
APP_NAME="Manna Apartment"
APP_ENV=production
APP_URL=https://api.mannaapartment.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=manna_apartment
DB_USERNAME=root
DB_PASSWORD=

QUEUE_CONNECTION=redis
REDIS_HOST=127.0.0.1
REDIS_PORT=6379

SANCTUM_STATEFUL_DOMAINS=admin.mannaapartment.com

FILESYSTEM_DISK=s3
AWS_BUCKET=manna-apartment-uploads
AWS_ACCESS_KEY_ID=xxxxx
AWS_SECRET_ACCESS_KEY=xxxxx
AWS_DEFAULT_REGION=af-south-1

SMS_PROVIDER=beem
SMS_API_KEY=xxxxx
SMS_SENDER_ID=MANNA

PAYMENT_PROVIDER=azampay
PAYMENT_API_KEY=xxxxx
PAYMENT_CALLBACK_URL=https://api.mannaapartment.com/api/v1/payments-gateway/callback
```

---

## 13. API RESPONSE FORMAT (via Laravel API Resources)

**Success:**
```json
{
  "success": true,
  "message": "Property created successfully",
  "data": { "id": "uuid", "name": "Sunrise Apartments" }
}
```

**Error:**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": { "phone": ["Phone number already in use"] }
}
```

**Paginated List (Laravel's native paginator wrapped):**
```json
{
  "success": true,
  "data": [ ... ],
  "meta": { "current_page": 1, "per_page": 20, "total": 143, "last_page": 8 }
}
```

---

## 14. SECURITY CHECKLIST (LARAVEL-SPECIFIC)

- Passwords hashed with Laravel's default **bcrypt** (via `Hash::make`)
- Sanctum tokens stored hashed in `personal_access_tokens` table
- Rate limiting via Laravel's `throttle` middleware on `/auth/login` and `/auth/forgot-password` (e.g., `throttle:5,15`) — replaces need for 2FA
- All input validated via **Form Request classes**, never raw `$request->all()` without validation
- Eloquent ORM protects against SQL injection by default (parameterized queries)
- `organization_id` scoping enforced via global scope trait — never trusted from client-submitted IDs
- File upload validation (`mimes:jpg,png,pdf`, `max:5120`) before storing KYC docs
- CORS configured (`config/cors.php`) to allow only the Web Admin Panel domain; mobile app uses token auth, not cookies, so CORS is less critical there
- `X-Platform` header required and validated on every authenticated request to enforce the web/mobile role split
- Audit logging (via a simple `activity_logs` table or Spatie Activitylog package) for KYC review, subscription changes, tenant deletion, contract termination
- Daily automated MySQL backups (e.g., via `spatie/laravel-backup`)

---

## 15. DEPLOYMENT STRUCTURE

```
┌─────────────────────────────┐
│     Nginx (Reverse Proxy)    │ → SSL termination, routes to Laravel (PHP-FPM)
└───────────┬───────────────────┘
            │
┌───────────▼───────────────────┐
│   Manna Apartment API (Laravel)│ → PHP-FPM + Laravel Octane (optional, for performance)
└───────────┬───────────────────┘
            │
   ┌────────┼─────────┐
   │        │          │
┌──▼──┐ ┌───▼───┐ ┌────▼─────┐
│ MySQL │ │ Redis │ │ S3/Cloud │
│  (DB)  │ │(Queue)│ │ Storage  │
└────────┘ └───────┘ └──────────┘

Separate queue worker process: php artisan queue:work (supervised by Supervisor/Horizon)
Separate scheduler cron: * * * * * php artisan schedule:run
```

- **Web Admin Panel**: deployed separately (React build served via Nginx, or same server on a subdomain like `admin.mannaapartment.com`)
- **Flutter Mobile App**: built and published to Google Play Store / Apple App Store, communicates only with the Laravel API over HTTPS
- **Laravel Horizon** recommended for monitoring queued SMS/PDF jobs in production
- CI/CD via GitHub Actions: run PHPUnit/Pest tests → deploy via SSH/Forge/Envoyer

---

## 16. SUMMARY OF WHAT CHANGED FROM THE PREVIOUS VERSION

- **Backend framework switched:** Node.js/NestJS → **Laravel (PHP)**
- **Mobile app confirmed:** **Flutter**, used by **Landlord + Tenant only**
- **Web Admin Panel restricted:** now used by **Super Admin + Staff only** — landlords no longer access the web panel at all
- **New `EnsurePlatform` middleware** added specifically to hard-enforce which role is allowed on which platform, using an `X-Platform` header sent by each client
- **Authentication still simple:** phone + password, no 2FA, OTP reserved only for registration verification and password reset
- Database schema, SMS system, contract logic (3/6/12 months, lifetime), subscription/SaaS billing, and multi-tenant isolation remain the same as the original specification — only the framework and platform-role mapping changed

This document replaces the previous Node.js/NestJS backend structure as the official backend reference for Manna Apartment.
