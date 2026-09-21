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

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(tenantDetailProvider(id)),
            color: colors.primary,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Tenant name
                Text(
                  name,
                  style: typography.display.sm.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),

                // Summary card
                FCard(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Row(
                      children: [
                        _stat(
                          colors,
                          typography,
                          context.tr('rent'),
                          'TZS ${_formatAmount(tenant['rent_amount'])}',
                        ),
                        _vDivider(colors),
                        _stat(
                          colors,
                          typography,
                          context.tr('total_paid'),
                          'TZS ${_formatAmount(tenant['total_paid'])}',
                          color: const Color(0xFF16A34A),
                        ),
                        _vDivider(colors),
                        _stat(
                          colors,
                          typography,
                          context.tr('balance_due'),
                          'TZS ${_formatAmount(balance)}',
                          color: balance > 0 ? colors.error : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  context.tr('payments'),
                  style: typography.body.sm.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),

                if (payments.isEmpty)
                  EmptyState(message: context.tr('no_payments_recorded'))
                else
                  FCard(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        children: [
                          for (var i = 0; i < payments.length; i++) ...[
                            _paymentTile(context, colors, typography, payments[i]),
                            if (i < payments.length - 1)
                              Divider(
                                height: 1,
                                indent: 36,
                                color: colors.border.withValues(alpha: 0.6),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _stat(
    FColors colors,
    FTypography typography,
    String label,
    String value, {
    Color? color,
  }) {
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
            style: typography.body.xs3.copyWith(color: colors.mutedForeground),
          ),
        ],
      ),
    );
  }

  Widget _vDivider(FColors colors) => Container(
        width: 1,
        height: 32,
        color: colors.border.withValues(alpha: 0.6),
      );

  Widget _paymentTile(
    BuildContext context,
    FColors colors,
    FTypography typography,
    dynamic raw,
  ) {
    final payment =
        raw is Map<String, dynamic> ? raw : <String, dynamic>{};
    final status = (payment['status'] ?? 'paid').toString();
    final isPaid = status == 'paid' || status == 'confirmed' || status == 'completed';
    final paymentId = payment['id']?.toString() ?? '';
    final method = (payment['method'] ?? payment['payment_method'] ?? '').toString();

    return FTappable(
      onPress: paymentId.isEmpty
          ? null
          : () => context.push('/landlord/payments/$paymentId'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (isPaid ? const Color(0xFF16A34A) : colors.error)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: HugeIcon(
                  icon: isPaid
                      ? HugeIcons.strokeRoundedCheckmarkCircle02
                      : HugeIcons.strokeRoundedAlert02,
                  size: 16,
                  color: isPaid ? const Color(0xFF16A34A) : colors.error,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TZS ${_formatAmount(payment['amount'])}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.body.sm.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      _formatDate(payment['payment_date'] ?? payment['created_at']),
                      if (method.isNotEmpty) method,
                    ].join('  ·  '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        typography.body.xs3.copyWith(color: colors.mutedForeground),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              status.toUpperCase(),
              style: typography.body.xs3.copyWith(
                fontWeight: FontWeight.w700,
                color: isPaid ? const Color(0xFF16A34A) : colors.error,
              ),
            ),
            const SizedBox(width: 4),
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              size: 16,
              color: colors.mutedForeground.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
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

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    final dt = DateTime.tryParse(date.toString());
    if (dt == null) return date.toString();
    return DateFormat('dd MMM yyyy').format(dt);
  }
}
