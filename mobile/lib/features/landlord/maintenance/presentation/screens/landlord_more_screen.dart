import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../features/auth/providers/auth_provider.dart';

class LandlordMoreScreen extends ConsumerWidget {
  const LandlordMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('More'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(context, user?.fullName ?? 'Landlord', user?.phone ?? ''),
          const SizedBox(height: 20),
          _buildSectionTitle(context, 'Management'),
          _buildMenuItem(context, icon: Icons.apartment, title: 'Properties', subtitle: 'Manage your properties & units', onTap: () => context.push('/landlord/properties')),
          _buildMenuItem(context, icon: Icons.people, title: 'Tenants', subtitle: 'View and manage tenants', onTap: () => context.push('/landlord/tenants')),
          _buildMenuItem(context, icon: Icons.description_outlined, title: 'Contracts', subtitle: 'View and create contracts', onTap: () => context.push('/landlord/contracts')),
          _buildMenuItem(context, icon: Icons.payments, title: 'Payments', subtitle: 'Record and view payments', onTap: () => context.push('/landlord/payments')),
          _buildMenuItem(context, icon: Icons.sms_outlined, title: 'SMS', subtitle: 'Broadcast messages and view logs', onTap: () => context.push('/landlord/sms')),
          _buildMenuItem(context, icon: Icons.build_outlined, title: 'Maintenance', subtitle: 'Respond to tenant requests', onTap: () => context.push('/landlord/maintenance')),
          const SizedBox(height: 20),
          _buildSectionTitle(context, 'Account'),
          _buildMenuItem(context, icon: Icons.settings_outlined, title: 'Settings', subtitle: 'App preferences', onTap: () => context.push('/settings')),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            color: AppColors.error,
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/auth/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String phone) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'L',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phone,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white60 : AppColors.textLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = color ?? AppColors.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: color ?? (isDark ? Colors.white : AppColors.textDark),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white60 : AppColors.textLight,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
