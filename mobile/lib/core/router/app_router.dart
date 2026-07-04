import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_landlord_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/verify_otp_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/landlord/contracts/presentation/screens/contracts_list_screen.dart';
import '../../features/landlord/dashboard/presentation/screens/landlord_home_screen.dart';
import '../../features/landlord/maintenance/presentation/screens/landlord_more_screen.dart';
import '../../features/landlord/maintenance/presentation/screens/maintenance_requests_screen.dart';
import '../../features/landlord/payments/presentation/screens/payments_list_screen.dart';
import '../../features/landlord/payments/presentation/screens/record_payment_screen.dart';
import '../../features/landlord/properties/presentation/screens/add_edit_property_screen.dart';
import '../../features/landlord/properties/presentation/screens/properties_list_screen.dart';
import '../../features/landlord/properties/presentation/screens/property_detail_screen.dart';
import '../../features/landlord/sms/presentation/screens/sms_broadcast_screen.dart';
import '../../features/landlord/sms/presentation/screens/sms_logs_screen.dart';
import '../../features/landlord/tenants/presentation/screens/tenants_list_screen.dart';
import '../../features/tenant/dashboard/presentation/screens/tenant_home_screen.dart';
import '../../features/tenant/maintenance/presentation/screens/my_maintenance_requests_screen.dart';
import '../../features/tenant/maintenance/presentation/screens/submit_maintenance_screen.dart';
import '../../features/tenant/contract/presentation/screens/my_contract_screen.dart';
import '../../features/tenant/payments/presentation/screens/my_payments_screen.dart';
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
      GoRoute(path: '/auth/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/auth/register-landlord', builder: (context, state) => const RegisterLandlordScreen()),
      GoRoute(path: '/auth/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/auth/verify-otp', builder: (context, state) => const VerifyOtpScreen()),
      GoRoute(path: '/auth/reset-password', builder: (context, state) => const ResetPasswordScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/settings/language', builder: (context, state) => const LanguageToggleScreen()),
      GoRoute(path: '/settings/about', builder: (context, state) => const AboutScreen()),
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),

      // Landlord routes
      ShellRoute(
        builder: (context, state, child) => LandlordScaffold(child: child),
        routes: [
          GoRoute(path: '/landlord/home', builder: (context, state) => const LandlordHomeScreen()),
          GoRoute(path: '/landlord/properties', builder: (context, state) => const PropertiesListScreen()),
          GoRoute(path: '/landlord/properties/add', builder: (context, state) => const AddEditPropertyScreen()),
          GoRoute(path: '/landlord/properties/:id', builder: (context, state) => const PropertyDetailScreen()),
          GoRoute(path: '/landlord/tenants', builder: (context, state) => const TenantsListScreen()),
          GoRoute(path: '/landlord/tenants/add', builder: (context, state) => const Placeholder()),
          GoRoute(path: '/landlord/payments', builder: (context, state) => const PaymentsListScreen()),
          GoRoute(path: '/landlord/payments/record', builder: (context, state) => const RecordPaymentScreen()),
          GoRoute(path: '/landlord/contracts', builder: (context, state) => const ContractsListScreen()),
          GoRoute(path: '/landlord/sms', builder: (context, state) => const SmsBroadcastScreen()),
          GoRoute(path: '/landlord/sms/logs', builder: (context, state) => const SmsLogsScreen()),
          GoRoute(path: '/landlord/maintenance', builder: (context, state) => const MaintenanceRequestsScreen()),
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
          GoRoute(path: '/tenant/payments', builder: (context, state) => const MyPaymentsScreen()),
          GoRoute(path: '/tenant/maintenance', builder: (context, state) => const SubmitMaintenanceScreen()),
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
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getIndex(context),
        onTap: (index) {
          final routes = ['/landlord/home', '/landlord/properties', '/landlord/tenants', '/landlord/payments', '/landlord/more'];
          context.go(routes[index]);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.apartment_outlined), activeIcon: Icon(Icons.apartment), label: 'Properties'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Tenants'),
          BottomNavigationBarItem(icon: Icon(Icons.payments_outlined), activeIcon: Icon(Icons.payments), label: 'Payments'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), activeIcon: Icon(Icons.more_horiz), label: 'More'),
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
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getIndex(context),
        onTap: (index) {
          final routes = ['/tenant/home', '/tenant/my-unit', '/tenant/payments', '/tenant/more'];
          context.go(routes[index]);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.door_front_door_outlined), activeIcon: Icon(Icons.door_front_door), label: 'My Unit'),
          BottomNavigationBarItem(icon: Icon(Icons.payments_outlined), activeIcon: Icon(Icons.payments), label: 'Payments'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), activeIcon: Icon(Icons.more_horiz), label: 'More'),
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
