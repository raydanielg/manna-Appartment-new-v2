import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
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
    final user = ref.watch(authProvider).user;
    final unreadCount = ref.watch(unreadCountProvider).value ?? 0;
    final dashboardAsync = ref.watch(tenantDashboardProvider);
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(tenantDashboardProvider),
          color: colors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(
                    context, colors, typography,
                    user?.fullName ?? context.tr('tenant'), unreadCount),
                const SizedBox(height: 20),
                dashboardAsync.when(
                  loading: () => const LoadingIndicator(),
                  error: (e, _) {
                    if (e is DioException && e.response?.statusCode == 403) {
                      final data = e.response?.data;
                      if (data is Map && data['must_change_password'] == true) {
                        return _buildMustChangePassword(
                            context, colors, typography);
                      }
                      return ErrorState(
                        message: data is Map
                            ? (data['message'] ?? context.tr('access_denied'))
                            : context.tr('access_denied'),
                        onRetry: () => ref.invalidate(tenantDashboardProvider),
                      );
                    }
                    return ErrorState(
                      message: AppError.getMessage(e),
                      onRetry: () => ref.invalidate(tenantDashboardProvider),
                    );
                  },
                  data: (data) {
                    final unit = data['unit'] as Map<String, dynamic>?;
                    final contract = data['contract'] as Map<String, dynamic>?;
                    final balance = (data['balance'] is num
                        ? (data['balance'] as num).toDouble()
                        : double.tryParse(data['balance']?.toString() ?? '0') ??
                            0.0);
                    final totalPaid = (data['total_paid'] is num
                        ? (data['total_paid'] as num).toDouble()
                        : double.tryParse(
                                data['total_paid']?.toString() ?? '0') ??
                            0.0);
                    final rentAmount = (contract?['rent_amount'] is num
                        ? (contract?['rent_amount'] as num).toDouble()
                        : double.tryParse(
                                contract?['rent_amount']?.toString() ?? '0') ??
                            0.0);
                    final recentPayments = data['recent_payments'] as List? ?? [];
                    final maintenanceRequests =
                        data['maintenance_requests'] as List? ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyUnitCard(
                            unit: unit,
                            rentAmount: rentAmount,
                            balance: balance),
                        const SizedBox(height: 16),
                        BalanceSummaryCard(
                            totalPaid: totalPaid,
                            totalDue: rentAmount,
                            balance: balance),
                        const SizedBox(height: 24),
                        Text(
                          context.tr('quick_actions').toUpperCase(),
                          style: typography.body.xs3.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: colors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _actionRow(
                          context,
                          colors,
                          typography,
                          icon: HugeIcons.strokeRoundedMoney01,
                          title: context.tr('my_payments'),
                          subtitle: context.tr('view_history'),
                          onTap: () => context.push('/tenant/payments'),
                        ),
                        _actionRow(
                          context,
                          colors,
                          typography,
                          icon: HugeIcons.strokeRoundedFile01,
                          title: context.tr('my_contract'),
                          subtitle: context.tr('view_details'),
                          onTap: () => context.push('/tenant/contract'),
                        ),
                        _actionRow(
                          context,
                          colors,
                          typography,
                          icon: HugeIcons.strokeRoundedWrench01,
                          title: context.tr('maintenance'),
                          subtitle: context.tr('submit_track'),
                          onTap: () => context.push('/tenant/maintenance/my'),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          context.tr('recent_updates').toUpperCase(),
                          style: typography.body.xs3.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: colors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (recentPayments.isEmpty && maintenanceRequests.isEmpty)
                          _updateRow(context, colors, typography,
                              title: context.tr('no_updates_yet'),
                              subtitle: context.tr('notifications_appear'))
                        else ...[
                          ...recentPayments.take(3).map((p) => _updateRow(
                                context,
                                colors,
                                typography,
                                title:
                                    'Payment: TZS ${(p['amount'] ?? 0).toStringAsFixed(0)}',
                                subtitle: p['date']?.toString() ?? '',
                                icon: HugeIcons.strokeRoundedMoney01,
                                iconColor: const Color(0xFF16A34A),
                              )),
                          ...maintenanceRequests.take(2).map((m) => _updateRow(
                                context,
                                colors,
                                typography,
                                title: m['description']?.toString() ??
                                    'Maintenance request',
                                subtitle:
                                    '${m['status'] ?? ''} · ${m['created_at'] ?? ''}',
                                icon: HugeIcons.strokeRoundedWrench01,
                                iconColor: const Color(0xFFD97706),
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

  Widget _buildHeader(BuildContext context, FColors colors,
      FTypography typography, String name, int unreadCount) {
    final initials = name
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: context.theme.style.borderRadius.md,
          ),
          child: Center(
            child: Text(
              initials,
              style: typography.body.sm.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.primaryForeground,
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
                '${context.tr('hello')}, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    typography.body.md.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                context.tr('welcome_tenant'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.body.xs3
                    .copyWith(color: colors.mutedForeground),
              ),
            ],
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            FButton.icon(
              variant: .ghost,
              size: .sm,
              onPress: () => context.push('/notifications'),
              child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedNotification01, size: null),
            ),
            if (unreadCount > 0)
              Positioned(
                top: 4,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: colors.error, shape: BoxShape.circle),
                  constraints:
                      const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _actionRow(
    BuildContext context,
    FColors colors,
    FTypography typography, {
    required List<List<dynamic>> icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return FTappable(
      onPress: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              HugeIcon(icon: icon, size: 17, color: colors.mutedForeground),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.sm
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.xs3
                          .copyWith(color: colors.mutedForeground),
                    ),
                  ],
                ),
              ),
              HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 14,
                color: colors.mutedForeground.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _updateRow(
    BuildContext context,
    FColors colors,
    FTypography typography, {
    required String title,
    required String subtitle,
    List<List<dynamic>>? icon,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: HugeIcon(
              icon: icon ?? HugeIcons.strokeRoundedNotification01,
              size: 15,
              color: iconColor ?? colors.mutedForeground,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: typography.body.sm
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.body.xs3
                      .copyWith(color: colors.mutedForeground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMustChangePassword(
      BuildContext context, FColors colors, FTypography typography) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          HugeIcon(
            icon: HugeIcons.strokeRoundedLockPassword,
            size: 40,
            color: const Color(0xFFD97706),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('password_change_required'),
            style: typography.body.lg.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('password_change_desc'),
            textAlign: TextAlign.center,
            style: typography.body.xs2
                .copyWith(color: colors.mutedForeground, height: 1.5),
          ),
          const SizedBox(height: 20),
          FButton(
            variant: .primary,
            onPress: () => context.go('/tenant/profile/change-password'),
            child: Text(context.tr('change_password')),
          ),
        ],
      ),
    );
  }
}
