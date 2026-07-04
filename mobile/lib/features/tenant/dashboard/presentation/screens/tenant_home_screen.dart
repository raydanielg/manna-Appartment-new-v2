import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../features/auth/providers/auth_provider.dart';
import '../widgets/balance_summary_card.dart';
import '../widgets/my_unit_card.dart';

class TenantHomeScreen extends ConsumerWidget {
  const TenantHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, user?.fullName ?? 'Tenant'),
              const SizedBox(height: 24),
              const MyUnitCard(),
              const SizedBox(height: 24),
              const BalanceSummaryCard(),
              const SizedBox(height: 24),
              Text('Quick Actions', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
              const SizedBox(height: 12),
              _buildQuickAction(context, icon: Icons.payments_outlined, title: 'My Payments', subtitle: 'View history', color: AppColors.success),
              _buildQuickAction(context, icon: Icons.description_outlined, title: 'My Contract', subtitle: 'View details', color: AppColors.info),
              _buildQuickAction(context, icon: Icons.build_outlined, title: 'Maintenance', subtitle: 'Submit request', color: AppColors.warning),
              const SizedBox(height: 24),
              Text('Recent Updates', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
              const SizedBox(height: 12),
              _buildUpdate(context, title: 'No updates yet', subtitle: 'Notifications will appear here'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, ', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
              const SizedBox(height: 4),
              Text('Welcome to your tenant portal', style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : AppColors.textLight)),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.push('/settings'),
          icon: const Icon(Icons.settings_outlined),
          color: isDark ? Colors.white : AppColors.textDark,
        ),
      ],
    );
  }

  Widget _buildQuickAction(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: isDark ? 0.15 : 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }

  Widget _buildUpdate(BuildContext context, {required String title, required String subtitle}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
      ),
    );
  }
}
