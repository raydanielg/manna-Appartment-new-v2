import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';

class RouteGuard {
  static String? redirect(BuildContext context, GoRouterState state, AuthState authState) {
    final loc = state.matchedLocation;
    final isAuthenticated = authState.isAuthenticated;
    final isAuthRoute = loc.startsWith('/auth');
    final isPublicRoute = loc == '/splash' || loc == '/onboarding' || loc == '/settings' || loc == '/settings/language' || loc == '/settings/about' || loc == '/notifications';

    if (isPublicRoute) return null;
    if (!isAuthenticated && !isAuthRoute) return '/auth/login';
    if (isAuthenticated && isAuthRoute) {
      return authState.role == 'landlord' ? '/landlord/home' : '/tenant/home';
    }
    return null;
  }
}
