import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_landlord_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/admin/landlords/presentation/screens/add_landlord_screen.dart';
import '../../features/admin/landlords/presentation/screens/admin_landlord_detail_screen.dart';
import '../../features/admin/landlords/presentation/screens/admin_landlords_screen.dart';
import '../../features/auth/presentation/screens/verify_otp_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/banned/presentation/screens/banned_screen.dart';
import '../../shared/settings/presentation/screens/help_support_screen.dart';
import '../../shared/settings/presentation/screens/privacy_policy_screen.dart';
import '../../shared/settings/presentation/screens/terms_of_service_screen.dart';
import '../../features/landlord/finance/presentation/screens/finance_report_screen.dart';
import '../../features/landlord/finance/presentation/screens/reports_screen.dart';
import '../../features/landlord/contracts/presentation/screens/contract_detail_screen.dart';
import '../../features/landlord/contracts/presentation/screens/contract_sign_screen.dart';
import '../../features/landlord/contracts/presentation/screens/contracts_list_screen.dart';
import '../../features/landlord/contracts/presentation/screens/create_contract_screen.dart';
import '../../features/landlord/dashboard/presentation/screens/landlord_home_screen.dart';
import '../../features/landlord/help/presentation/screens/landlord_help_screen.dart';
import '../../features/landlord/kyc/presentation/screens/kyc_intro_screen.dart';
import '../../features/landlord/kyc/presentation/screens/kyc_status_screen.dart';
import '../../features/landlord/kyc/presentation/screens/kyc_upload_documents_screen.dart';
import '../../features/landlord/kyc/presentation/screens/kyc_verified_screen.dart';
import '../../features/landlord/kyc/presentation/screens/organization_setup_screen.dart';
import '../../features/landlord/maintenance/presentation/screens/landlord_more_screen.dart';
import '../../features/landlord/maintenance/presentation/screens/maintenance_detail_screen.dart';
import '../../features/landlord/maintenance/presentation/screens/maintenance_requests_screen.dart';
import '../../features/landlord/payments/presentation/screens/payment_detail_screen.dart';
import '../../features/landlord/payments/presentation/screens/payments_list_screen.dart';
import '../../features/landlord/payments/presentation/screens/record_payment_screen.dart';
import '../../features/landlord/profile/presentation/screens/landlord_profile_screen.dart';
import '../../features/landlord/properties/presentation/screens/add_edit_property_screen.dart';
import '../../features/landlord/properties/presentation/screens/properties_list_screen.dart';
import '../../features/landlord/properties/presentation/screens/property_detail_screen.dart';
import '../../features/landlord/sms/presentation/screens/sms_broadcast_screen.dart';
import '../../features/landlord/sms/presentation/screens/sms_logs_screen.dart';
import '../../features/landlord/staff_management/presentation/screens/add_staff_screen.dart';
import '../../features/landlord/staff_management/presentation/screens/staff_list_screen.dart';
import '../../features/landlord/staff_management/presentation/screens/staff_permissions_screen.dart';
import '../../features/landlord/subscription/presentation/screens/current_plan_screen.dart';
import '../../features/landlord/subscription/presentation/screens/invoice_detail_screen.dart';
import '../../features/landlord/subscription/presentation/screens/payment_checkout_screen.dart';
import '../../features/landlord/subscription/presentation/screens/subscription_plans_screen.dart';
import '../../features/landlord/tenants/presentation/screens/add_tenant_screen.dart';
import '../../features/landlord/tenants/presentation/screens/move_out_screen.dart';
import '../../features/landlord/tenants/presentation/screens/tenant_detail_screen.dart';
import '../../features/landlord/tenants/presentation/screens/tenant_payments_screen.dart';
import '../../features/landlord/tenants/presentation/screens/tenants_list_screen.dart';
import '../../features/landlord/units/presentation/screens/add_edit_unit_screen.dart';
import '../../features/landlord/units/presentation/screens/unit_detail_screen.dart';
import '../../features/landlord/units/presentation/screens/units_list_screen.dart';
import '../../features/tenant/dashboard/presentation/screens/tenant_home_screen.dart';
import '../../features/tenant/maintenance/presentation/screens/my_maintenance_requests_screen.dart';
import '../../features/tenant/maintenance/presentation/screens/submit_maintenance_screen.dart';
import '../../features/tenant/contract/presentation/screens/contract_pdf_viewer_screen.dart';
import '../../features/tenant/contract/presentation/screens/my_contract_screen.dart';
import '../../features/tenant/contract/presentation/screens/tenant_contract_sign_screen.dart';
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
import '../localization/app_localizations.dart';

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
      GoRoute(path: '/admin/landlords', builder: (context, state) => const AdminLandlordsScreen()),
      GoRoute(path: '/admin/landlords/create', builder: (context, state) => const AddLandlordScreen()),
      GoRoute(path: '/admin/landlords/:id', builder: (context, state) => const AdminLandlordDetailScreen()),
      GoRoute(path: '/banned', builder: (context, state) => const BannedScreen()),
      GoRoute(path: '/settings/about', builder: (context, state) => const AboutScreen()),
      GoRoute(path: '/settings/help-support', builder: (context, state) => const HelpSupportScreen()),
      GoRoute(path: '/settings/privacy', builder: (context, state) => const PrivacyPolicyScreen()),
      GoRoute(path: '/settings/terms', builder: (context, state) => const TermsOfServiceScreen()),
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),

      // Landlord KYC flow (outside shell to hide bottom nav)
      GoRoute(path: '/landlord/kyc', builder: (context, state) => const KycIntroScreen()),
      GoRoute(path: '/landlord/kyc/upload', builder: (context, state) => const KycUploadDocumentsScreen()),
      GoRoute(path: '/landlord/kyc/under-review', builder: (context, state) => const KycStatusScreen()),
      GoRoute(path: '/landlord/kyc/verified', builder: (context, state) => const KycVerifiedScreen()),
      GoRoute(path: '/landlord/kyc/organization-setup', builder: (context, state) => const OrganizationSetupScreen()),

      // Landlord routes
      ShellRoute(
        builder: (context, state, child) => LandlordScaffold(child: child),
        routes: [
          GoRoute(path: '/landlord/home', builder: (context, state) => const LandlordHomeScreen()),
          GoRoute(path: '/landlord/properties', builder: (context, state) => const PropertiesListScreen()),
          GoRoute(path: '/landlord/properties/add', builder: (context, state) => AddEditPropertyScreen(propertyId: state.uri.queryParameters['id'] ?? '')),
          GoRoute(path: '/landlord/properties/:id', builder: (context, state) => const PropertyDetailScreen()),
          GoRoute(path: '/landlord/tenants', builder: (context, state) => const TenantsListScreen()),
          GoRoute(path: '/landlord/tenants/add', builder: (context, state) => AddTenantScreen(tenantId: state.uri.queryParameters['id'])),
          GoRoute(path: '/landlord/tenants/:id', builder: (context, state) => const TenantDetailScreen()),
          GoRoute(path: '/landlord/tenants/:id/payments', builder: (context, state) => const TenantPaymentsScreen()),
          GoRoute(path: '/landlord/tenants/:id/move-out', builder: (context, state) => const MoveOutScreen()),
          GoRoute(path: '/landlord/units', builder: (context, state) => UnitsListScreen(propertyId: state.uri.queryParameters['propertyId'])),
          GoRoute(path: '/landlord/units/add', builder: (context, state) => AddEditUnitScreen(propertyId: state.uri.queryParameters['propertyId'], unitId: state.uri.queryParameters['id'])),
          GoRoute(path: '/landlord/units/:id', builder: (context, state) => const UnitDetailScreen()),
          GoRoute(path: '/landlord/payments', builder: (context, state) => const PaymentsListScreen()),
          GoRoute(path: '/landlord/payments/record', builder: (context, state) => const RecordPaymentScreen()),
          GoRoute(path: '/landlord/payments/:id', builder: (context, state) => const PaymentDetailScreen()),
          GoRoute(path: '/landlord/profile', builder: (context, state) => const LandlordProfileScreen()),
          GoRoute(path: '/landlord/contracts', builder: (context, state) => const ContractsListScreen()),
          GoRoute(path: '/landlord/contracts/create', builder: (context, state) => const CreateContractScreen()),
          GoRoute(path: '/landlord/contracts/:id', builder: (context, state) => const ContractDetailScreen()),
          GoRoute(path: '/landlord/contracts/:id/sign', builder: (context, state) => const ContractSignScreen()),
          GoRoute(path: '/landlord/sms', builder: (context, state) => const SmsBroadcastScreen()),
          GoRoute(path: '/landlord/sms/logs', builder: (context, state) => const SmsLogsScreen()),
          GoRoute(path: '/landlord/maintenance', builder: (context, state) => const MaintenanceRequestsScreen()),
          GoRoute(path: '/landlord/maintenance/:id', builder: (context, state) => const MaintenanceDetailScreen()),
          GoRoute(path: '/landlord/finance-report', builder: (context, state) => const FinanceReportScreen()),
          GoRoute(path: '/landlord/reports', builder: (context, state) => const ReportsScreen()),
          GoRoute(path: '/landlord/help', builder: (context, state) => const LandlordHelpScreen()),
          GoRoute(path: '/landlord/subscription', builder: (context, state) => const CurrentPlanScreen()),
          GoRoute(path: '/landlord/subscription/plans', builder: (context, state) => const SubscriptionPlansScreen()),
          GoRoute(path: '/landlord/subscription/checkout', builder: (context, state) => const PaymentCheckoutScreen()),
          GoRoute(path: '/landlord/subscription/invoice', builder: (context, state) => InvoiceDetailScreen(invoice: state.extra as Map<String, dynamic>)),
          GoRoute(path: '/landlord/staff', builder: (context, state) => const StaffListScreen()),
          GoRoute(path: '/landlord/staff/add', builder: (context, state) => const AddStaffScreen()),
          GoRoute(path: '/landlord/staff/:id/permissions', builder: (context, state) => const StaffPermissionsScreen()),
          GoRoute(path: '/landlord/more', builder: (context, state) => LandlordMoreScreen()),
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
          GoRoute(path: '/tenant/contract/sign', builder: (context, state) => const TenantContractSignScreen()),
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
    final routes = ['/landlord/home', '/landlord/properties', '/landlord/tenants', '/landlord/payments', '/landlord/more'];

    return Scaffold(
      body: child,
      bottomNavigationBar: FBottomNavigationBar(
        index: _getIndex(context),
        onChange: (i) => context.go(routes[i]),
        children: [
          FBottomNavigationBarItem(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedHome01, size: null),
            label: Text(context.tr('home')),
          ),
          FBottomNavigationBarItem(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedBuilding03, size: null),
            label: Text(context.tr('properties')),
          ),
          FBottomNavigationBarItem(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedUserGroup, size: null),
            label: Text(context.tr('tenants')),
          ),
          FBottomNavigationBarItem(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedMoney01, size: null),
            label: Text(context.tr('payments')),
          ),
          FBottomNavigationBarItem(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedDashboardSquare01, size: null),
            label: Text(context.tr('more')),
          ),
        ],
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

class TenantScaffold extends StatelessWidget {
  final Widget child;
  const TenantScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final routes = ['/tenant/home', '/tenant/my-unit', '/tenant/payments', '/tenant/more'];

    return Scaffold(
      body: child,
      bottomNavigationBar: FBottomNavigationBar(
        index: _getIndex(context),
        onChange: (i) => context.go(routes[i]),
        children: [
          FBottomNavigationBarItem(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedHome01, size: null),
            label: Text(context.tr('home')),
          ),
          FBottomNavigationBarItem(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedDoor01, size: null),
            label: Text(context.tr('my_unit')),
          ),
          FBottomNavigationBarItem(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedMoney01, size: null),
            label: Text(context.tr('payments')),
          ),
          FBottomNavigationBarItem(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedDashboardSquare01, size: null),
            label: Text(context.tr('more')),
          ),
        ],
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
