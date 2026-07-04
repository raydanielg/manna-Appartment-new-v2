# MANNA APARTMENT — MOBILE APP STRUCTURE (FLUTTER)
## Complete Mobile App Blueprint — Used by Landlord & Tenant Only

---

## 1. OVERVIEW

The **Manna Apartment Mobile App** is built with **Flutter** (single codebase for Android & iOS). It is used by **two roles only**:

- **Landlord** — full management of their properties, tenants, contracts, payments, SMS, subscription
- **Tenant** — view their unit, contract, payments, and submit maintenance requests

After login, the app detects the user's role from the API response and loads a **completely different navigation flow/UI** for each — same app, same codebase, two experiences.

```
                 ┌───────────────────────┐
                 │   Manna Apartment App   │
                 │        (Flutter)         │
                 └───────────┬─────────────┘
                             │
                     Login (phone + password)
                             │
              ┌──────────────┴──────────────┐
              │                              │
     role == "landlord"              role == "tenant"
              │                              │
   ┌──────────▼──────────┐         ┌─────────▼──────────┐
   │  Landlord Home Flow   │         │   Tenant Home Flow    │
   │  (Bottom Nav: 5 tabs) │         │  (Bottom Nav: 4 tabs) │
   └───────────────────────┘         └───────────────────────┘
```

No 2FA anywhere — login screen only asks for **Phone Number + Password**.

---

## 2. TECH STACK (MOBILE)

- **Framework:** Flutter 3.x (Dart 3.x)
- **State Management:** Riverpod (recommended — clean, testable, scales well) *(Bloc/Cubit is a valid alternative if the team prefers it)*
- **Networking:** Dio (HTTP client with interceptors for auth token + error handling)
- **Local Storage:** flutter_secure_storage (auth token), Hive or SharedPreferences (cached app data, e.g. last-viewed dashboard stats for offline view)
- **Routing/Navigation:** go_router (declarative routing, handles role-based redirect cleanly)
- **Forms & Validation:** flutter_form_builder + form validation
- **Push Notifications:** Firebase Cloud Messaging (FCM) — for in-app notifications (payment confirmations, contract expiry, maintenance updates) in addition to SMS
- **Charts (Landlord finance dashboard):** fl_chart or syncfusion_flutter_charts
- **PDF Viewing:** flutter_pdfview or syncfusion_flutter_pdfviewer (view contracts)
- **Image Handling:** image_picker (KYC docs, property photos), cached_network_image
- **Localization:** flutter_localizations + intl (Swahili & English toggle)
- **Environment Config:** flutter_dotenv or --dart-define for API base URLs (dev/staging/prod)
- **Testing:** flutter_test + mockito
- **CI/CD:** Codemagic or GitHub Actions + Fastlane (for Play Store/App Store builds)

---

## 3. FLUTTER PROJECT STRUCTURE (Feature-First Architecture)

```
manna_apartment_mobile/
│
├── lib/
│   ├── main.dart                          # App entry point
│   ├── app.dart                           # MaterialApp + theme + router setup
│   │
│   ├── core/                              # Shared foundation, used across all features
│   │   ├── config/
│   │   │   ├── app_config.dart            # API base URL, environment flags
│   │   │   └── env.dart
│   │   │
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   ├── app_strings.dart           # Swahili + English string keys
│   │   │   └── app_assets.dart
│   │   │
│   │   ├── network/
│   │   │   ├── api_client.dart            # Dio instance + interceptors
│   │   │   ├── auth_interceptor.dart      # attaches Bearer token + X-Platform: mobile header
│   │   │   ├── error_interceptor.dart     # global error handling/mapping
│   │   │   └── api_endpoints.dart         # all endpoint path constants
│   │   │
│   │   ├── storage/
│   │   │   ├── secure_storage_service.dart  # stores auth token
│   │   │   └── local_cache_service.dart     # Hive boxes for offline cache
│   │   │
│   │   ├── router/
│   │   │   ├── app_router.dart            # go_router config
│   │   │   └── route_guard.dart           # redirects based on role + auth state
│   │   │
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   │
│   │   ├── widgets/                       # Shared reusable widgets
│   │   │   ├── primary_button.dart
│   │   │   ├── app_text_field.dart
│   │   │   ├── loading_indicator.dart
│   │   │   ├── empty_state.dart
│   │   │   ├── error_state.dart
│   │   │   ├── status_badge.dart          # e.g., "Paid"/"Overdue"/"Active" chips
│   │   │   └── confirm_dialog.dart
│   │   │
│   │   ├── utils/
│   │   │   ├── currency_formatter.dart    # formats TZS amounts
│   │   │   ├── date_formatter.dart
│   │   │   ├── validators.dart            # phone number, password rules
│   │   │   └── snackbar_helper.dart
│   │   │
│   │   └── localization/
│   │       ├── app_localizations.dart
│   │       ├── sw.json                    # Swahili translations
│   │       └── en.json                    # English translations
│   │
│   ├── features/
│   │   │
│   │   ├── auth/                          # SHARED: used by both Landlord & Tenant
│   │   │   ├── data/
│   │   │   │   ├── auth_repository.dart
│   │   │   │   └── models/
│   │   │   │       └── login_response_model.dart
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart     # Riverpod: current user, auth state
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── splash_screen.dart
│   │   │       │   ├── login_screen.dart
│   │   │       │   ├── register_landlord_screen.dart
│   │   │       │   ├── forgot_password_screen.dart
│   │   │       │   ├── verify_otp_screen.dart
│   │   │       │   └── reset_password_screen.dart
│   │   │       └── widgets/
│   │   │           └── login_form.dart
│   │   │
│   │   ├── landlord/                      # LANDLORD-ONLY FEATURES
│   │   │   ├── dashboard/
│   │   │   │   ├── data/
│   │   │   │   │   └── dashboard_repository.dart
│   │   │   │   ├── providers/
│   │   │   │   │   └── dashboard_provider.dart
│   │   │   │   └── presentation/
│   │   │   │       ├── screens/
│   │   │   │       │   └── landlord_home_screen.dart
│   │   │   │       └── widgets/
│   │   │   │           ├── summary_cards.dart
│   │   │   │           ├── income_chart.dart
│   │   │   │           └── recent_activity_list.dart
│   │   │   │
│   │   │   ├── properties/
│   │   │   │   ├── data/
│   │   │   │   │   ├── properties_repository.dart
│   │   │   │   │   └── models/property_model.dart
│   │   │   │   ├── providers/
│   │   │   │   │   └── properties_provider.dart
│   │   │   │   └── presentation/
│   │   │   │       ├── screens/
│   │   │   │       │   ├── properties_list_screen.dart
│   │   │   │       │   ├── property_detail_screen.dart
│   │   │   │       │   └── add_edit_property_screen.dart
│   │   │   │       └── widgets/
│   │   │   │           └── property_card.dart
│   │   │   │
│   │   │   ├── units/
│   │   │   │   ├── data/
│   │   │   │   ├── providers/
│   │   │   │   └── presentation/
│   │   │   │       ├── screens/
│   │   │   │       │   ├── units_list_screen.dart
│   │   │   │       │   ├── unit_detail_screen.dart
│   │   │   │       │   └── add_edit_unit_screen.dart
│   │   │   │       └── widgets/
│   │   │   │           └── unit_card.dart
│   │   │   │
│   │   │   ├── tenants/
│   │   │   │   ├── data/
│   │   │   │   ├── providers/
│   │   │   │   └── presentation/
│   │   │   │       ├── screens/
│   │   │   │       │   ├── tenants_list_screen.dart
│   │   │   │       │   ├── tenant_detail_screen.dart
│   │   │   │       │   ├── add_tenant_screen.dart
│   │   │   │       │   └── move_out_screen.dart
│   │   │   │       └── widgets/
│   │   │   │           └── tenant_card.dart
│   │   │   │
│   │   │   ├── contracts/
│   │   │   │   ├── data/
│   │   │   │   ├── providers/
│   │   │   │   └── presentation/
│   │   │   │       ├── screens/
│   │   │   │       │   ├── contracts_list_screen.dart
│   │   │   │       │   ├── contract_detail_screen.dart
│   │   │   │       │   ├── create_contract_screen.dart   # duration: 3/6/12 months, lifetime, custom
│   │   │   │       │   └── contract_pdf_viewer_screen.dart
│   │   │   │       └── widgets/
│   │   │   │           ├── contract_card.dart
│   │   │   │           └── duration_selector.dart
│   │   │   │
│   │   │   ├── payments/
│   │   │   │   ├── data/
│   │   │   │   ├── providers/
│   │   │   │   └── presentation/
│   │   │   │       ├── screens/
│   │   │   │       │   ├── payments_list_screen.dart
│   │   │   │       │   ├── record_payment_screen.dart
│   │   │   │       │   └── payment_detail_screen.dart
│   │   │   │       └── widgets/
│   │   │   │           └── payment_row.dart
│   │   │   │
│   │   │   ├── finance/
│   │   │   │   ├── data/
│   │   │   │   ├── providers/
│   │   │   │   └── presentation/
│   │   │   │       ├── screens/
│   │   │   │       │   └── finance_report_screen.dart
│   │   │   │       └── widgets/
│   │   │   │           ├── outstanding_balance_list.dart
│   │   │   │           └── export_report_button.dart
│   │   │   │
│   │   │   ├── sms/
│   │   │   │   ├── data/
│   │   │   │   ├── providers/
│   │   │   │   └── presentation/
│   │   │   │       ├── screens/
│   │   │   │       │   ├── sms_broadcast_screen.dart
│   │   │   │       │   └── sms_logs_screen.dart
│   │   │   │       └── widgets/
│   │   │   │           └── sms_log_tile.dart
│   │   │   │
│   │   │   ├── subscription/
│   │   │   │   ├── data/
│   │   │   │   ├── providers/
│   │   │   │   └── presentation/
│   │   │   │       ├── screens/
│   │   │   │       │   ├── subscription_plans_screen.dart
│   │   │   │       │   ├── current_plan_screen.dart
│   │   │   │       │   └── payment_checkout_screen.dart   # mobile money checkout
│   │   │   │       └── widgets/
│   │   │   │           └── plan_card.dart
│   │   │   │
│   │   │   ├── staff_management/
│   │   │   │   ├── data/
│   │   │   │   ├── providers/
│   │   │   │   └── presentation/
│   │   │   │       ├── screens/
│   │   │   │       │   ├── staff_list_screen.dart
│   │   │   │       │   ├── add_staff_screen.dart
│   │   │   │       │   └── staff_permissions_screen.dart
│   │   │   │       └── widgets/
│   │   │   │
│   │   │   ├── kyc/
│   │   │   │   ├── data/
│   │   │   │   ├── providers/
│   │   │   │   └── presentation/
│   │   │   │       ├── screens/
│   │   │   │       │   ├── kyc_intro_screen.dart
│   │   │   │       │   ├── kyc_upload_documents_screen.dart
│   │   │   │       │   ├── kyc_selfie_capture_screen.dart
│   │   │   │       │   └── kyc_status_screen.dart
│   │   │   │       └── widgets/
│   │   │   │
│   │   │   └── maintenance/
│   │   │       ├── data/
│   │   │       ├── providers/
│   │   │       └── presentation/
│   │   │           ├── screens/
│   │   │           │   ├── maintenance_requests_screen.dart
│   │   │           │   └── maintenance_detail_screen.dart
│   │   │           └── widgets/
│   │   │
│   │   └── tenant/                        # TENANT-ONLY FEATURES
│   │       ├── dashboard/
│   │       │   ├── data/
│   │       │   ├── providers/
│   │       │   └── presentation/
│   │       │       ├── screens/
│   │       │       │   └── tenant_home_screen.dart
│   │       │       └── widgets/
│   │       │           ├── my_unit_card.dart
│   │       │           └── balance_summary_card.dart
│   │       │
│   │       ├── unit/
│   │       │   ├── data/
│   │       │   ├── providers/
│   │       │   └── presentation/
│   │       │       └── screens/
│   │       │           └── my_unit_detail_screen.dart
│   │       │
│   │       ├── contract/
│   │       │   ├── data/
│   │       │   ├── providers/
│   │       │   └── presentation/
│   │       │       └── screens/
│   │       │           ├── my_contract_screen.dart
│   │       │           └── contract_pdf_viewer_screen.dart
│   │       │
│   │       ├── payments/
│   │       │   ├── data/
│   │       │   ├── providers/
│   │       │   └── presentation/
│   │       │       └── screens/
│   │       │           ├── my_payments_screen.dart
│   │       │           └── payment_receipt_screen.dart
│   │       │
│   │       ├── maintenance/
│   │       │   ├── data/
│   │       │   ├── providers/
│   │       │   └── presentation/
│   │       │       ├── screens/
│   │       │       │   ├── submit_maintenance_screen.dart
│   │       │       │   └── my_maintenance_requests_screen.dart
│   │       │       └── widgets/
│   │       │
│   │       └── profile/
│   │           ├── data/
│   │           ├── providers/
│   │           └── presentation/
│   │               └── screens/
│   │                   ├── tenant_profile_screen.dart
│   │                   └── change_password_screen.dart
│   │
│   └── shared/                            # Used by BOTH landlord & tenant
│       ├── notifications/
│       │   ├── data/
│       │   │   └── notifications_repository.dart
│       │   ├── providers/
│       │   │   └── notifications_provider.dart
│       │   └── presentation/
│       │       └── screens/
│       │           └── notifications_screen.dart
│       │
│       └── settings/
│           ├── presentation/
│           │   └── screens/
│           │       ├── settings_screen.dart
│           │       ├── language_toggle_screen.dart   # Swahili / English
│           │       └── about_screen.dart
│
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── test/
│   ├── unit/
│   └── widget/
│
├── android/
├── ios/
├── pubspec.yaml
└── README.md
```

---

## 4. APP NAVIGATION STRUCTURE (Bottom Navigation per Role)

### 4.1 Landlord Bottom Navigation (5 tabs)
```
┌────────┬────────────┬────────────┬────────────┬──────────┐
│  Home  │ Properties  │  Tenants    │  Finance    │  More    │
│ (dash) │ (& Units)   │ (& Contracts)│ (& Payments)│ (SMS,    │
│        │             │             │             │ Staff,   │
│        │             │             │             │ Subs,    │
│        │             │             │             │ KYC,     │
│        │             │             │             │ Settings)│
└────────┴────────────┴────────────┴────────────┴──────────┘
```

### 4.2 Tenant Bottom Navigation (4 tabs)
```
┌────────┬────────────┬────────────┬──────────────┐
│  Home  │  My Unit    │  Payments   │   More        │
│ (dash) │ (& Contract)│  (history)  │ (Maintenance, │
│        │             │             │  Notifications,│
│        │             │             │  Settings)     │
└────────┴────────────┴────────────┴──────────────┘
```

---

## 5. AUTH & ROLE-BASED ROUTING LOGIC (go_router)

```dart
// core/router/app_router.dart (simplified logic)

final appRouter = GoRouter(
  redirect: (context, state) {
    final authState = ref.read(authProvider);

    final isLoggedIn = authState.isAuthenticated;
    final isAuthRoute = state.matchedLocation.startsWith('/auth');

    if (!isLoggedIn && !isAuthRoute) {
      return '/auth/login';
    }

    if (isLoggedIn && isAuthRoute) {
      // redirect based on role after login
      return authState.role == 'landlord' ? '/landlord/home' : '/tenant/home';
    }

    // Guard: prevent a tenant from ever navigating into a landlord/* route and vice versa
    if (isLoggedIn) {
      if (authState.role == 'tenant' && state.matchedLocation.startsWith('/landlord')) {
        return '/tenant/home';
      }
      if (authState.role == 'landlord' && state.matchedLocation.startsWith('/tenant')) {
        return '/landlord/home';
      }
    }

    return null;
  },
  routes: [
    // /auth/login, /auth/register-landlord, /auth/forgot-password, ...
    // /landlord/home, /landlord/properties, /landlord/tenants, ...
    // /tenant/home, /tenant/unit, /tenant/payments, ...
  ],
);
```

Every API request automatically attaches the required header so the backend enforces the platform rule from the Laravel side too:
```dart
// core/network/auth_interceptor.dart
options.headers['Authorization'] = 'Bearer $token';
options.headers['X-Platform'] = 'mobile';   // always "mobile" from this app
```

---

## 6. KEY SCREENS — DETAILED BREAKDOWN

### 6.1 Shared (Auth)
| Screen | Purpose |
|--------|---------|
| Splash Screen | Checks stored token → auto-login or redirect to login |
| Login Screen | Phone + Password fields, "Forgot Password" link, "Register as Landlord" link |
| Register Landlord Screen | Full name, phone, password, business name (optional) |
| Verify OTP Screen | 6-digit OTP input (used only for registration & password reset) |
| Forgot/Reset Password Screen | Phone → OTP → new password |

### 6.2 Landlord Screens
| Screen | Purpose |
|--------|---------|
| Landlord Home | Summary cards (income, occupancy, outstanding), income chart, recent activity |
| Properties List/Detail | View/add/edit properties, photo gallery |
| Units List/Detail | View/add/edit units under a property, vacancy status |
| Tenants List/Detail | View/add tenants, assign to unit, move-out flow |
| Contracts List/Detail/Create | Select duration (3/6/12 months, lifetime, custom), auto-fill tenant/unit, generate PDF |
| Payments List/Record | Record new payment, view history per tenant |
| Finance Dashboard | Income trend chart, outstanding balances list, export button |
| SMS Broadcast/Logs | Send custom message to one or all tenants, view delivery logs |
| Subscription Plans/Checkout | View plans, subscribe, mobile money checkout, invoice history |
| Staff Management | Add staff, assign permissions (staff then logs in via **Web Admin Panel**, not this app) |
| KYC Upload | Upload ID photos, selfie, ownership proof, view approval status |
| Maintenance Requests | View & respond to tenant repair requests |

### 6.3 Tenant Screens
| Screen | Purpose |
|--------|---------|
| Tenant Home | My unit summary card, balance due, quick links |
| My Unit Detail | Photos, rent amount, property info |
| My Contract | View contract details, download/view PDF |
| My Payments | Payment history table, receipts |
| Submit Maintenance Request | Description + photo upload |
| My Maintenance Requests | Status tracking (Open/In Progress/Resolved) |
| Notifications | In-app feed (mirrors SMS: reminders, receipts, announcements) |
| Profile/Change Password | Edit profile photo/contact, change password |

---

## 7. STATE MANAGEMENT PATTERN (Riverpod Example)

```dart
// features/landlord/tenants/providers/tenants_provider.dart

final tenantsRepositoryProvider = Provider((ref) => TenantsRepository(ref.read(apiClientProvider)));

final tenantsListProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.read(tenantsRepositoryProvider);
  return repo.getTenants();
});

final addTenantProvider = FutureProvider.family.autoDispose((ref, TenantFormData data) async {
  final repo = ref.read(tenantsRepositoryProvider);
  final result = await repo.addTenant(data);
  ref.invalidate(tenantsListProvider); // refresh list after adding
  return result;
});
```

Each feature module follows the same pattern: `repository` (talks to API) → `provider` (Riverpod state) → `screen/widget` (consumes provider with `ref.watch`).

---

## 8. OFFLINE / POOR-CONNECTIVITY HANDLING

Since many landlords/tenants may be in areas with unstable internet:
- Cache last-fetched dashboard data locally (Hive) → show cached data with a "last updated" timestamp when offline
- Queue actions like "Record Payment" locally if offline, auto-sync when connection returns (optional advanced feature)
- Always show clear network error states (`error_state.dart` widget) with a "Retry" button
- SMS remains the fallback channel for critical alerts even if the app itself isn't opened

---

## 9. PUSH NOTIFICATIONS (Firebase Cloud Messaging)

In addition to SMS, the app registers an FCM token per device so the backend can also send **in-app push notifications** for:
- Payment confirmation
- Rent due reminder
- Contract expiring soon
- New maintenance request (to landlord) / status update (to tenant)
- New announcement/broadcast from landlord

```dart
// On login success:
final fcmToken = await FirebaseMessaging.instance.getToken();
await authRepository.registerDeviceToken(fcmToken);
```

---

## 10. APP FLOW DIAGRAM (High-Level)

```
Splash
  │
  ▼
Login (phone + password) ──> Forgot Password ──> OTP ──> Reset Password
  │
  ├── role: landlord ──► Landlord Home
  │                         ├─ Properties ─ Units
  │                         ├─ Tenants ─ Contracts (3/6/12mo, lifetime)
  │                         ├─ Payments ─ Finance Dashboard
  │                         ├─ SMS Broadcast/Logs
  │                         ├─ Subscription Plans/Checkout
  │                         ├─ Staff Management
  │                         ├─ KYC Upload
  │                         └─ Maintenance Requests
  │
  └── role: tenant ──► Tenant Home
                          ├─ My Unit
                          ├─ My Contract (view/download PDF)
                          ├─ My Payments
                          ├─ Submit/Track Maintenance
                          └─ Notifications / Profile
```

---

## 11. SUMMARY

The **Manna Apartment Flutter app** is structured using a clean **feature-first architecture**, with a hard separation between `features/landlord/` and `features/tenant/` folders, sharing only `core/` (network, storage, theme, routing) and `shared/` (notifications, settings) modules.

- **Single codebase, two experiences** — role detected at login, routed via `go_router` with guards preventing cross-role navigation.
- **Riverpod** manages state cleanly per feature, with repositories isolating all API/Dio logic.
- Every request automatically sends `X-Platform: mobile`, working together with the Laravel backend's `EnsurePlatform` middleware to guarantee Super Admin and Staff can never log in from this app — only Landlord and Tenant.
- Firebase push notifications complement the SMS system for real-time in-app alerts.
- Offline caching and clear error states keep the app usable even with unreliable internet — common in the target market.

This document completes the full technical picture of Manna Apartment: system specification → Laravel backend → Flutter mobile app.
