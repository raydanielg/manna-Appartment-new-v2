import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';

class RouteGuard {
  static String? redirect(BuildContext context, GoRouterState state, AuthState authState) {
    final isAuthenticated = authState.isAuthenticated;
    final isAuthRoute = state.matchedLocation.startsWith('/auth');

    if (!isAuthenticated && !isAuthRoute) return '/auth/login';
    if (isAuthenticated && isAuthRoute) {
      return authState.role == 'landlord' ? '/landlord/home' : '/tenant/home';
    }
    return null;
  }
}
