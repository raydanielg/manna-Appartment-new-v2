import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../providers/payments_provider.dart';

class MyPaymentsScreen extends ConsumerWidget {
  const MyPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(myPaymentsProvider);
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('my_payments'),
          style: typography.display.md.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: FButton.icon(
          variant: .ghost,
          size: .sm,
          onPress: () => context.pop(),
          child: context.theme.icons.arrowLeft(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myPaymentsProvider),
        color: colors.primary,
        child: paymentsAsync.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) {
            if (e is DioException && e.response?.statusCode == 404) {
              return EmptyState(
                icon: Icons.payments_outlined,
                message:
                    '${context.tr('no_payments_yet')}\n${context.tr('no_payments_desc')}',
              );
            }
            return ErrorState(
              message: AppError.getMessage(e),
              onRetry: () => ref.invalidate(myPaymentsProvider),
            );
          },
          data: (payments) {
            if (payments.isEmpty) {
              return EmptyState(
                icon: Icons.payments_outlined,
                message: context.tr('no_payment_records'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final p = payments[index];
                final amount = p['amount'] ?? 0;
                final amountNum = amount is num
                    ? amount
                    : double.tryParse(amount.toString()) ?? 0;
                final status = (p['status'] ?? 'confirmed').toString();
                final paid =
                    status == 'confirmed' || status == 'paid' || status == 'active';
                final statusColor = paid
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFD97706);
                final meta = (p['month_covered']?.toString().isNotEmpty == true)
                    ? p['month_covered'].toString()
                    : (p['payment_date']?.toString() ?? '');

                return DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: colors.border.withValues(alpha: 0.5)),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TZS ${NumberFormat('#,###').format(amountNum)}',
                                style: typography.body.sm
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                meta,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: typography.body.xs3.copyWith(
                                    color: colors.mutedForeground),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          status.toUpperCase(),
                          style: typography.body.xs3.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
