import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_landlord_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/verify_otp_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/landlord/contracts/presentation/screens/contract_detail_screen.dart';
import '../../features/landlord/contracts/presentation/screens/contracts_list_screen.dart';
import '../../features/landlord/contracts/presentation/screens/create_contract_screen.dart';
import '../../features/landlord/dashboard/presentation/screens/landlord_home_screen.dart';
import '../../features/landlord/kyc/presentation/screens/kyc_intro_screen.dart';
import '../../features/landlord/kyc/presentation/screens/kyc_status_screen.dart';
import '../../features/landlord/kyc/presentation/screens/kyc_upload_documents_screen.dart';
import '../../features/landlord/kyc/presentation/screens/kyc_verified_screen.dart';
import '../../features/landlord/maintenance/presentation/screens/landlord_more_screen.dart';
import '../../features/landlord/maintenance/presentation/screens/maintenance_requests_screen.dart';
import '../../features/landlord/payments/presentation/screens/payment_detail_screen.dart';
import '../../features/landlord/payments/presentation/screens/payments_list_screen.dart';
import '../../features/landlord/payments/presentation/screens/record_payment_screen.dart';
import '../../features/landlord/properties/presentation/screens/add_edit_property_screen.dart';
import '../../features/landlord/properties/presentation/screens/properties_list_screen.dart';
import '../../features/landlord/properties/presentation/screens/property_detail_screen.dart';
import '../../features/landlord/sms/presentation/screens/sms_broadcast_screen.dart';
import '../../features/landlord/sms/presentation/screens/sms_logs_screen.dart';
import '../../features/landlord/staff_management/presentation/screens/add_staff_screen.dart';
import '../../features/landlord/staff_management/presentation/screens/staff_list_screen.dart';
import '../../features/landlord/staff_management/presentation/screens/staff_permissions_screen.dart';
import '../../features/landlord/subscription/presentation/screens/current_plan_screen.dart';
import '../../features/landlord/subscription/presentation/screens/payment_checkout_screen.dart';
import '../../features/landlord/subscription/presentation/screens/subscription_plans_screen.dart';
import '../../features/landlord/tenants/presentation/screens/add_tenant_screen.dart';
import '../../features/landlord/tenants/presentation/screens/move_out_screen.dart';
import '../../features/landlord/tenants/presentation/screens/tenant_detail_screen.dart';
import '../../features/landlord/tenants/presentation/screens/tenants_list_screen.dart';
import '../../features/landlord/units/presentation/screens/add_edit_unit_screen.dart';
import '../../features/landlord/units/presentation/screens/unit_detail_screen.dart';
import '../../features/landlord/units/presentation/screens/units_list_screen.dart';
import '../../features/tenant/dashboard/presentation/screens/tenant_home_screen.dart';
import '../../features/tenant/maintenance/presentation/screens/my_maintenance_requests_screen.dart';
import '../../features/tenant/maintenance/presentation/screens/submit_maintenance_screen.dart';
import '../../features/tenant/contract/presentation/screens/contract_pdf_viewer_screen.dart';
import '../../features/tenant/contract/presentation/screens/my_contract_screen.dart';
import '../../features/tenant/payments/presentation/screens/my_payments_screen.dart';
import '../../features/tenant/payments/presentation/screens/payment_receipt_screen.dart';
import '../../features/tenant/profile/presentation/screens/change_password_screen.dart';
import '../../features/tenant/profile/presentation/screens/tenant_more_screen.dart';
import '../../features/tenant/profile/presentation/screens/tenant_profile_screen.dart';
import '../../features/tenant/unit/presentation/screens/my_unit_detail_screen.dart';
import '../../shared/notifications/presentation/screens/notifications_screen.dart';
import '../../shared/settings/presentation/screens/about_screen.dart';
import '../../shared/settings/presentation/screens/language_toggle_screen.dart';
import '../../shared/settings/presentation/screens/settings_screen.dart';
import '../router/route_guard.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) => RouteGuard.redirect(context, state, ref.read(authProvider)),
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/auth/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/auth/register-landlord', builder: (context, state) => const RegisterLandlordScreen()),
      GoRoute(path: '/auth/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/auth/verify-otp', builder: (context, state) => const VerifyOtpScreen()),
      GoRoute(path: '/auth/reset-password', builder: (context, state) => const ResetPasswordScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/settings/language', builder: (context, state) => const LanguageToggleScreen()),
      GoRoute(path: '/settings/about', builder: (context, state) => const AboutScreen()),
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),

      // Landlord KYC flow (outside shell to hide bottom nav)
      GoRoute(path: '/landlord/kyc', builder: (context, state) => const KycIntroScreen()),
      GoRoute(path: '/landlord/kyc/upload', builder: (context, state) => const KycUploadDocumentsScreen()),
      GoRoute(path: '/landlord/kyc/under-review', builder: (context, state) => const KycStatusScreen()),
      GoRoute(path: '/landlord/kyc/verified', builder: (context, state) => const KycVerifiedScreen()),

      // Landlord routes
      ShellRoute(
        builder: (context, state, child) => LandlordScaffold(child: child),
        routes: [
          GoRoute(path: '/landlord/home', builder: (context, state) => const LandlordHomeScreen()),
          GoRoute(path: '/landlord/properties', builder: (context, state) => const PropertiesListScreen()),
          GoRoute(path: '/landlord/properties/add', builder: (context, state) => const AddEditPropertyScreen()),
          GoRoute(path: '/landlord/properties/:id', builder: (context, state) => const PropertyDetailScreen()),
          GoRoute(path: '/landlord/tenants', builder: (context, state) => const TenantsListScreen()),
          GoRoute(path: '/landlord/tenants/add', builder: (context, state) => const AddTenantScreen()),
          GoRoute(path: '/landlord/tenants/:id', builder: (context, state) => const TenantDetailScreen()),
          GoRoute(path: '/landlord/tenants/:id/move-out', builder: (context, state) => const MoveOutScreen()),
          GoRoute(path: '/landlord/units', builder: (context, state) => const UnitsListScreen()),
          GoRoute(path: '/landlord/units/add', builder: (context, state) => AddEditUnitScreen(propertyId: state.uri.queryParameters['propertyId'])),
          GoRoute(path: '/landlord/units/:id', builder: (context, state) => const UnitDetailScreen()),
          GoRoute(path: '/landlord/payments', builder: (context, state) => const PaymentsListScreen()),
          GoRoute(path: '/landlord/payments/record', builder: (context, state) => const RecordPaymentScreen()),
          GoRoute(path: '/landlord/payments/:id', builder: (context, state) => const PaymentDetailScreen()),
          GoRoute(path: '/landlord/contracts', builder: (context, state) => const ContractsListScreen()),
          GoRoute(path: '/landlord/contracts/create', builder: (context, state) => const CreateContractScreen()),
          GoRoute(path: '/landlord/contracts/:id', builder: (context, state) => const ContractDetailScreen()),
          GoRoute(path: '/landlord/sms', builder: (context, state) => const SmsBroadcastScreen()),
          GoRoute(path: '/landlord/sms/logs', builder: (context, state) => const SmsLogsScreen()),
          GoRoute(path: '/landlord/maintenance', builder: (context, state) => const MaintenanceRequestsScreen()),
          GoRoute(path: '/landlord/subscription', builder: (context, state) => const CurrentPlanScreen()),
          GoRoute(path: '/landlord/subscription/plans', builder: (context, state) => const SubscriptionPlansScreen()),
          GoRoute(path: '/landlord/subscription/checkout', builder: (context, state) => const PaymentCheckoutScreen()),
          GoRoute(path: '/landlord/staff', builder: (context, state) => const StaffListScreen()),
          GoRoute(path: '/landlord/staff/add', builder: (context, state) => const AddStaffScreen()),
          GoRoute(path: '/landlord/staff/:id/permissions', builder: (context, state) => const StaffPermissionsScreen()),
          GoRoute(path: '/landlord/more', builder: (context, state) => const LandlordMoreScreen()),
        ],
      ),

      // Tenant routes
      ShellRoute(
        builder: (context, state, child) => TenantScaffold(child: child),
        routes: [
          GoRoute(path: '/tenant/home', builder: (context, state) => const TenantHomeScreen()),
          GoRoute(path: '/tenant/my-unit', builder: (context, state) => const MyUnitDetailScreen()),
          GoRoute(path: '/tenant/contract', builder: (context, state) => const MyContractScreen()),
          GoRoute(path: '/tenant/contract/pdf', builder: (context, state) => const ContractPdfViewerScreen()),
          GoRoute(path: '/tenant/payments', builder: (context, state) => const MyPaymentsScreen()),
          GoRoute(path: '/tenant/payments/:id/receipt', builder: (context, state) => const PaymentReceiptScreen()),
          GoRoute(path: '/tenant/maintenance', builder: (context, state) => const SubmitMaintenanceScreen()),
          GoRoute(path: '/tenant/maintenance/submit', builder: (context, state) => const SubmitMaintenanceScreen()),
          GoRoute(path: '/tenant/maintenance/my', builder: (context, state) => const MyMaintenanceRequestsScreen()),
          GoRoute(path: '/tenant/profile', builder: (context, state) => const TenantProfileScreen()),
          GoRoute(path: '/tenant/profile/change-password', builder: (context, state) => const ChangePasswordScreen()),
          GoRoute(path: '/tenant/more', builder: (context, state) => const TenantMoreScreen()),
        ],
      ),
    ],
  );
});

class LandlordScaffold extends StatelessWidget {
  final Widget child;
  const LandlordScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = _getIndex(context);
    final items = [
      _NavItem('Home', Icons.home_outlined, Icons.home_rounded),
      _NavItem('Properties', Icons.apartment_outlined, Icons.apartment_rounded),
      _NavItem('Tenants', Icons.people_outline, Icons.people_alt_rounded),
      _NavItem('Payments', Icons.payments_outlined, Icons.payments_rounded),
      _NavItem('More', Icons.more_horiz, Icons.more_horiz_rounded),
    ];
    final routes = ['/landlord/home', '/landlord/properties', '/landlord/tenants', '/landlord/payments', '/landlord/more'];

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          border: Border(
            top: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB), width: 1),
          ),
          boxShadow: isDark
              ? null
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final isActive = i == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.go(routes[i]),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF059669).withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isActive ? item.activeIcon : item.icon,
                            size: 22,
                            color: isActive
                                ? const Color(0xFF059669)
                                : (isDark ? Colors.white38 : Colors.grey.shade400),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive
                                ? const Color(0xFF059669)
                                : (isDark ? Colors.white38 : Colors.grey.shade400),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  int _getIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/landlord/home')) return 0;
    if (location.startsWith('/landlord/properties')) return 1;
    if (location.startsWith('/landlord/tenants')) return 2;
    if (location.startsWith('/landlord/payments') || location.startsWith('/landlord/contracts')) return 3;
    if (location.startsWith('/landlord/more') || location.startsWith('/landlord/maintenance') || location.startsWith('/landlord/sms')) return 4;
    return 0;
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  _NavItem(this.label, this.icon, this.activeIcon);
}

class TenantScaffold extends StatelessWidget {
  final Widget child;
  const TenantScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = _getIndex(context);
    final items = [
      _NavItem('Home', Icons.home_outlined, Icons.home_rounded),
      _NavItem('My Unit', Icons.door_front_door_outlined, Icons.door_front_door_rounded),
      _NavItem('Payments', Icons.payments_outlined, Icons.payments_rounded),
      _NavItem('More', Icons.more_horiz, Icons.more_horiz_rounded),
    ];
    final routes = ['/tenant/home', '/tenant/my-unit', '/tenant/payments', '/tenant/more'];

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          border: Border(
            top: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB), width: 1),
          ),
          boxShadow: isDark
              ? null
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final isActive = i == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.go(routes[i]),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF059669).withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isActive ? item.activeIcon : item.icon,
                            size: 22,
                            color: isActive
                                ? const Color(0xFF059669)
                                : (isDark ? Colors.white38 : Colors.grey.shade400),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive
                                ? const Color(0xFF059669)
                                : (isDark ? Colors.white38 : Colors.grey.shade400),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  int _getIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/tenant/home')) return 0;
    if (location.startsWith('/tenant/my-unit')) return 1;
    if (location.startsWith('/tenant/payments')) return 2;
    if (location.startsWith('/tenant/more') || location.startsWith('/tenant/profile') || location.startsWith('/tenant/maintenance')) return 3;
    return 0;
  }
}
