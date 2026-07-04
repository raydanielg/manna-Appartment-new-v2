import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../features/auth/providers/auth_provider.dart';
import '../../../../../features/landlord/subscription/providers/subscription_provider.dart';

class LandlordMoreScreen extends ConsumerWidget {
  LandlordMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final planAsync = ref.watch(currentPlanProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('More', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(context, user?.fullName ?? 'Landlord', user?.phone ?? ''),
          const SizedBox(height: 20),
          planAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (plan) => _buildPlanCard(context, plan),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(context, 'Management'),
          _buildMenuItem(context, icon: Icons.apartment, title: 'Properties', subtitle: 'Manage your properties & units', onTap: () => context.push('/landlord/properties')),
          _buildMenuItem(context, icon: Icons.people, title: 'Tenants', subtitle: 'View and manage tenants', onTap: () => context.push('/landlord/tenants')),
          _buildMenuItem(context, icon: Icons.description_outlined, title: 'Contracts', subtitle: 'View and create contracts', onTap: () => context.push('/landlord/contracts')),
          _buildMenuItem(context, icon: Icons.payments, title: 'Payments', subtitle: 'Record and view payments', onTap: () => context.push('/landlord/payments')),
          _buildMenuItem(context, icon: Icons.sms_outlined, title: 'SMS Broadcast', subtitle: 'Send reminders and messages', onTap: () => context.push('/landlord/sms')),
          _buildMenuItem(context, icon: Icons.build_outlined, title: 'Maintenance', subtitle: 'Respond to tenant requests', onTap: () => context.push('/landlord/maintenance')),
          if (user?.role == 'super_admin') ...[
            const SizedBox(height: 20),
            _buildSectionTitle(context, 'Admin'),
            _buildMenuItem(context, icon: Icons.admin_panel_settings, title: 'Manage Landlords', subtitle: 'View all owners & organizations', onTap: () => context.push('/admin/landlords')),
          ],
          const SizedBox(height: 20),
          _buildSectionTitle(context, 'Account'),
          _buildMenuItem(context, icon: Icons.subscriptions_outlined, title: 'Subscription Plan', subtitle: 'View and manage your plan', onTap: () => context.push('/landlord/subscription')),
          _buildMenuItem(context, icon: Icons.settings_outlined, title: 'Settings', subtitle: 'App preferences', onTap: () => context.push('/settings')),
          _buildMenuItem(context, icon: Icons.help_outline, title: 'How to Use', subtitle: 'Quick guide for landlords', onTap: () => context.push('/landlord/help')),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            color: AppColors.error,
            onTap: () => _showLogoutConfirmation(context, ref),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.logout, color: AppColors.error, size: 32),
              ),
              title: Text('Logout', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800)),
              content: Text('Are you sure you want to sign out of your account?', textAlign: TextAlign.center, style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textLight)),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                SizedBox(
                  width: 120,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text('Cancel', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                    onPressed: () async {
                      setDialogState(() => _isLoggingOut = true);
                      await ref.read(authProvider.notifier).logout();
                      setDialogState(() => _isLoggingOut = false);
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                      if (context.mounted) {
                        context.go('/auth/login');
                      }
                    },
                    child: _isLoggingOut
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Logout', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _isLoggingOut = false;

  Widget _buildProfileHeader(BuildContext context, String name, String phone) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.info]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'L',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
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
                  style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: GoogleFonts.nunito(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white70),
            onPressed: () => context.push('/landlord/profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, Map<String, dynamic> plan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final planName = plan['plan']?['name'] ?? plan['plan_name'] ?? 'No Plan';
    final status = plan['status']?.toString() ?? 'inactive';
    final isActive = status == 'active';
    return InkWell(
      onTap: () => context.push('/landlord/subscription'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.workspace_premium, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Plan', style: GoogleFonts.nunito(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
                  Text(planName, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: isActive ? AppColors.success.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(
                isActive ? 'Active' : 'Inactive',
                style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: isActive ? AppColors.success : Colors.red),
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
        style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white60 : AppColors.textLight, letterSpacing: 0.5),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: color ?? (isDark ? Colors.white : AppColors.textDark))),
        subtitle: Text(subtitle, style: GoogleFonts.nunito(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
