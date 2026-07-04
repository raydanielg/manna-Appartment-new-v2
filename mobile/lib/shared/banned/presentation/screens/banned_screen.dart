import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/auth/providers/auth_provider.dart';

class BannedScreen extends ConsumerWidget {
  const BannedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final status = user?.organizationStatus ?? 'unknown';
    final reason = user?.suspensionReason;
    final isUserSuspended = user?.status != 'active';

    final (title, subtitle, color, icon) = _resolveState(isUserSuspended, status);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 80, color: color),
                ),
                const SizedBox(height: 32),
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(context, 'Account Status', user?.status ?? 'unknown'),
                      const Divider(height: 16),
                      _buildInfoRow(context, 'Organization Status', status),
                      if (reason != null && reason.isNotEmpty) ...[
                        const Divider(height: 16),
                        _buildInfoRow(context, 'Reason', reason),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => _contactSupport(context),
                  icon: const Icon(Icons.support_agent),
                  label: const Text('Contact Support'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/auth/login');
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (String, String, Color, IconData) _resolveState(bool isUserSuspended, String status) {
    if (isUserSuspended) {
      return ('Account Suspended', 'Your user account has been suspended by the administrator. Please contact support.', AppColors.error, Icons.block);
    }
    switch (status) {
      case 'suspended':
        return ('Organization Suspended', 'Your organization has been suspended. Please contact support to resolve this issue.', AppColors.warning, Icons.warning);
      case 'deactivated':
        return ('Account Deactivated', 'Your organization account has been deactivated. Contact support to reactivate.', Colors.grey, Icons.cancel);
      case 'active':
        return ('Account Active', 'Your account should be active. If you keep seeing this screen, please contact support.', AppColors.success, Icons.check_circle);
      default:
        return ('Account Restricted', 'There is an issue with your account. Please contact support for assistance.', AppColors.error, Icons.block);
    }
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: GoogleFonts.nunito(fontSize: 13, color: isDark ? Colors.white60 : AppColors.textLight)),
        ),
        Expanded(
          flex: 3,
          child: Text(value, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
        ),
      ],
    );
  }

  void _contactSupport(BuildContext context) async {
    final uri = Uri.parse('mailto:support@manna.co.tz?subject=Account%20Access%20Issue');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app. Please contact support@manna.co.tz')),
        );
      }
    }
  }
}
