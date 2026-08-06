import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/config/app_config.dart';
import '../../../../../core/localization/app_localizations.dart';
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
        title: Text(context.tr('more'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(context, user?.fullName ?? context.tr('landlord'), user?.phone ?? '', user?.avatar),
          const SizedBox(height: 20),
          planAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (plan) => _buildPlanCard(context, plan),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(context, context.tr('management')),
          _buildMenuItem(context, icon: Icons.apartment, customIcon: 'assets/icons/propertiesicon.png', title: context.tr('properties'), subtitle: context.tr('manage_properties'), onTap: () => context.push('/landlord/properties')),
          _buildMenuItem(context, icon: Icons.people, customIcon: 'assets/icons/tenantsicon.png', title: context.tr('tenants'), subtitle: context.tr('view_tenants'), onTap: () => context.push('/landlord/tenants')),
          _buildMenuItem(context, icon: Icons.description_outlined, customIcon: 'assets/icons/contracts.png', title: context.tr('contracts'), subtitle: context.tr('view_contracts'), onTap: () => context.push('/landlord/contracts')),
          _buildMenuItem(context, icon: Icons.payments, customIcon: 'assets/icons/incomeicon.png', title: context.tr('payments'), subtitle: context.tr('record_view_payments'), onTap: () => context.push('/landlord/payments')),
          _buildMenuItem(context, icon: Icons.sms_outlined, customIcon: 'assets/icons/sms.png', title: context.tr('sms_broadcast'), subtitle: context.tr('send_reminders'), onTap: () => context.push('/landlord/sms')),
          _buildMenuItem(context, icon: Icons.build_outlined, customIcon: 'assets/icons/maintainance.png', title: context.tr('maintenance'), subtitle: context.tr('respond_requests'), onTap: () => context.push('/landlord/maintenance')),
          if (user?.role == 'super_admin') ...[
            const SizedBox(height: 20),
            _buildSectionTitle(context, context.tr('admin')),
            _buildMenuItem(context, icon: Icons.admin_panel_settings, title: context.tr('manage_landlords'), subtitle: context.tr('view_all_owners'), onTap: () => context.push('/admin/landlords')),
          ],
          const SizedBox(height: 20),
          _buildSectionTitle(context, context.tr('account')),
          _buildMenuItem(context, icon: Icons.subscriptions_outlined, title: context.tr('subscription'), subtitle: context.tr('current_plan'), onTap: () => context.push('/landlord/subscription')),
          _buildMenuItem(context, icon: Icons.settings_outlined, title: context.tr('settings'), subtitle: context.tr('app_preferences'), onTap: () => context.push('/settings')),
          _buildMenuItem(context, icon: Icons.help_outline, title: context.tr('how_to_use'), subtitle: context.tr('help_subtitle'), onTap: () => context.push('/landlord/help')),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: context.tr('logout'),
            subtitle: context.tr('sign_out_account'),
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
              title: Text(context.tr('logout'), style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800)),
              content: Text(context.tr('confirm_logout'), textAlign: TextAlign.center, style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textLight)),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                SizedBox(
                  width: 120,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(context.tr('cancel'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
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
                        : Text(context.tr('logout'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: Colors.white)),
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

  Widget _buildProfileHeader(BuildContext context, String name, String phone, String? avatarUrl) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.info]),
        borderRadius: BorderRadius.circular(8),
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
            child: ClipOval(
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? Image.network(
                      avatarUrl.startsWith('http') ? avatarUrl : '${AppConfig.apiBaseUrl.replaceAll(RegExp(r'/api/?$'), '')}/$avatarUrl',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset('assets/icons/avatar.png'),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset('assets/icons/avatar.png'),
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
                  Text(context.tr('current_plan'), style: GoogleFonts.nunito(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
                  Text(planName, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: isActive ? AppColors.success.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(
                isActive ? context.tr('active') : context.tr('inactive'),
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
    String? customIcon,
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1), borderRadius: BorderRadius.circular(8)),
          child: customIcon != null
              ? Image.asset(customIcon, width: 20, height: 20, errorBuilder: (_, __, ___) => Icon(icon, color: iconColor))
              : Icon(icon, color: iconColor),
        ),
        title: Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: color ?? (isDark ? Colors.white : AppColors.textDark))),
        subtitle: Text(subtitle, style: GoogleFonts.nunito(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
