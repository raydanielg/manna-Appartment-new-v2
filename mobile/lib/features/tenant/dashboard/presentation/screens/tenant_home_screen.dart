import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../features/auth/providers/auth_provider.dart';
import '../../../../../shared/notifications/providers/notifications_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../widgets/balance_summary_card.dart';
import '../widgets/my_unit_card.dart';

class TenantHomeScreen extends ConsumerWidget {
  const TenantHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final unreadCount = ref.watch(unreadCountProvider).value ?? 0;
    final dashboardAsync = ref.watch(tenantDashboardProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(tenantDashboardProvider),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, user?.fullName ?? 'Tenant', unreadCount),
                const SizedBox(height: 24),
                dashboardAsync.when(
                  loading: () => const LoadingIndicator(),
                  error: (e, _) => ErrorState(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(tenantDashboardProvider),
                  ),
                  data: (data) {
                    final unit = data['unit'] as Map<String, dynamic>?;
                    final contract = data['contract'] as Map<String, dynamic>?;
                    final balance = (data['balance'] is num ? (data['balance'] as num) : double.tryParse(data['balance']?.toString() ?? '0') ?? 0).toDouble();
                    final totalPaid = (data['total_paid'] is num ? (data['total_paid'] as num) : double.tryParse(data['total_paid']?.toString() ?? '0') ?? 0).toDouble();
                    final rentAmount = (contract?['rent_amount'] is num ? (contract?['rent_amount'] as num) : double.tryParse(contract?['rent_amount']?.toString() ?? '0') ?? 0).toDouble();
                    final recentPayments = data['recent_payments'] as List? ?? [];
                    final maintenanceRequests = data['maintenance_requests'] as List? ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyUnitCard(unit: unit, rentAmount: rentAmount, balance: balance),
                        const SizedBox(height: 24),
                        BalanceSummaryCard(totalPaid: totalPaid, totalDue: rentAmount, balance: balance),
                        const SizedBox(height: 24),
                        Text('Quick Actions', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                        const SizedBox(height: 12),
                        _buildQuickAction(context, icon: Icons.payments_outlined, title: 'My Payments', subtitle: 'View history', color: AppColors.success, onTap: () => context.push('/tenant/payments')),
                        _buildQuickAction(context, icon: Icons.description_outlined, title: 'My Contract', subtitle: 'View details', color: AppColors.info, onTap: () => context.push('/tenant/contract')),
                        _buildQuickAction(context, icon: Icons.build_outlined, title: 'Maintenance', subtitle: 'Submit request', color: AppColors.warning, onTap: () => context.push('/tenant/maintenance')),
                        const SizedBox(height: 24),
                        Text('Recent Updates', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                        const SizedBox(height: 12),
                        if (recentPayments.isEmpty && maintenanceRequests.isEmpty)
                          _buildUpdate(context, title: 'No updates yet', subtitle: 'Notifications will appear here')
                        else ...[
                          ...recentPayments.take(3).map((p) => _buildUpdate(
                                context,
                                title: 'Payment: TZS ${(p['amount'] ?? 0).toStringAsFixed(0)}',
                                subtitle: p['date'] ?? '',
                                icon: Icons.payments,
                                color: AppColors.success,
                              )),
                          ...maintenanceRequests.take(2).map((m) => _buildUpdate(
                                context,
                                title: m['description'] ?? 'Maintenance request',
                                subtitle: '${m['status'] ?? ''} - ${m['created_at'] ?? ''}',
                                icon: Icons.build,
                                color: AppColors.warning,
                              )),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, int unreadCount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF059669), Color(0xFF047857)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              initials,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $name',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Welcome to your tenant portal',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white54 : AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () => context.push('/notifications'),
                icon: const Icon(Icons.notifications_none_rounded, size: 20),
                color: isDark ? Colors.white70 : AppColors.textLight,
                padding: EdgeInsets.zero,
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color, VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: isDark ? 0.15 : 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildUpdate(BuildContext context, {required String title, required String subtitle, IconData icon = Icons.notifications, Color color = AppColors.info}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
      ),
    );
  }
}
