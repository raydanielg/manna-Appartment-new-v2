import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/tenants_provider.dart';

class TenantPaymentsScreen extends ConsumerWidget {
  const TenantPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    final tenantAsync = ref.watch(tenantDetailProvider(id));
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('payment_history'),
          style: typography.display.md.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: FButton.icon(
          variant: .ghost,
          size: .sm,
          onPress: () {
            if (context.canPop()) context.pop();
          },
          child: context.theme.icons.arrowLeft(context),
        ),
        actions: [
          FButton.icon(
            variant: .ghost,
            size: .sm,
            onPress: () => context.push('/landlord/payments/record'),
            child: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 20),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: tenantAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) {
          final message = AppError.getMessage(e);
          final isSetup = AppError.isSetupError(e);
          return ErrorState(
            message: message,
            onRetry: () => ref.invalidate(tenantDetailProvider(id)),
            onAction: isSetup ? () => context.go('/landlord/subscription') : null,
            actionLabel: context.tr('complete_setup'),
          );
        },
        data: (tenant) {
          final payments = (tenant['payments'] ?? []) as List<dynamic>;
          final balance = _parseAmount(tenant['balance_due']);
          final name = _getTenantName(tenant);

          // Sort newest first
          final sorted = List<dynamic>.from(payments)
            ..sort((a, b) {
              final da = DateTime.tryParse(
                      (a['payment_date'] ?? a['created_at'] ?? '').toString()) ??
                  DateTime(0);
              final db = DateTime.tryParse(
                      (b['payment_date'] ?? b['created_at'] ?? '').toString()) ??
                  DateTime(0);
              return db.compareTo(da);
            });

          // Group by day label
          final grouped = <String, List<dynamic>>{};
          for (final p in sorted) {
            grouped.putIfAbsent(_dayLabel(context, p), () => []).add(p);
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(tenantDetailProvider(id)),
            color: colors.primary,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                // Tenant name
                Text(
                  name,
                  style: typography.display.sm
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),

                // Summary stats — plain row
                Row(
                  children: [
                    _stat(context, context.tr('rent'),
                        'TZS ${_formatAmount(tenant['rent_amount'])}'),
                    _stat(context, context.tr('total_paid'),
                        'TZS ${_formatAmount(tenant['total_paid'])}',
                        color: const Color(0xFF16A34A)),
                    _stat(context, context.tr('balance_due'),
                        'TZS ${_formatAmount(balance)}',
                        color: balance > 0 ? colors.error : null),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(
                    height: 1,
                    color: colors.border.withValues(alpha: 0.6)),
                const SizedBox(height: 8),

                if (sorted.isEmpty)
                  EmptyState(message: context.tr('no_payments_recorded'))
                else ...[
                  Text(
                    context.tr('payments').toUpperCase(),
                    style: typography.body.xs3.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: colors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  for (final entry in grouped.entries) ...[
                    // Date header — stepper node
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(left: 5),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            entry.key.toUpperCase(),
                            style: typography.body.xs3.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: colors.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (var i = 0; i < entry.value.length; i++)
                      _paymentRow(
                        context,
                        entry.value[i],
                        isLast:
                            i == entry.value.length - 1 && entry.key == grouped.keys.last,
                        colors: colors,
                        typography: typography,
                      ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _paymentRow(
    BuildContext context,
    dynamic raw, {
    required bool isLast,
    required FColors colors,
    required FTypography typography,
  }) {
    final payment = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
    final status = (payment['status'] ?? 'paid').toString();
    final isPaid =
        status == 'paid' || status == 'confirmed' || status == 'completed';
    final paymentId = payment['id']?.toString() ?? '';
    final method =
        (payment['method'] ?? payment['payment_method'] ?? '').toString();
    final type = (payment['payment_type'] ?? 'rent').toString();
    final dotColor =
        isPaid ? const Color(0xFF16A34A) : colors.error;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline rail
          SizedBox(
            width: 20,
            child: Column(
              children: [
                const SizedBox(height: 5),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: dotColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: dotColor, width: 2),
                  ),
                ),
                Expanded(
                  child: isLast
                      ? const SizedBox()
                      : Container(
                          width: 1.5,
                          margin: const EdgeInsets.only(top: 2),
                          color: colors.border.withValues(alpha: 0.6),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FTappable(
              onPress: paymentId.isEmpty
                  ? null
                  : () => context.push('/landlord/payments/$paymentId'),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TZS ${_formatAmount(payment['amount'])}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.body.sm
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            [
                              type,
                              if (method.isNotEmpty) method,
                            ].join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.body.xs3.copyWith(
                                color: colors.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status.toUpperCase(),
                      style: typography.body.xs3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: dotColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      size: 14,
                      color: colors.mutedForeground.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value,
      {Color? color}) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: typography.body.sm.copyWith(
              fontWeight: FontWeight.w800,
              color: color ?? colors.foreground,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style:
                typography.body.xs3.copyWith(color: colors.mutedForeground),
          ),
        ],
      ),
    );
  }

  String _dayLabel(BuildContext context, dynamic payment) {
    final raw = payment['payment_date'] ?? payment['created_at'];
    if (raw == null) return '';
    final dt = DateTime.tryParse(raw.toString());
    if (dt == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return context.tr('today');
    if (diff == 1) return context.tr('yesterday');
    return DateFormat('dd MMM yyyy').format(dt);
  }

  String _getTenantName(Map<String, dynamic> t) {
    final userData = t['user'] as Map<String, dynamic>?;
    return userData?['full_name'] ?? t['full_name'] ?? t['name'] ?? 'Unknown';
  }

  double _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  String _formatAmount(dynamic value) {
    return NumberFormat('#,###').format(_parseAmount(value));
  }
}
