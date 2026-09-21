import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../providers/subscription_provider.dart';

import 'package:manna_apartment/core/utils/app_toast.dart';

class CurrentPlanScreen extends ConsumerWidget {
  const CurrentPlanScreen({super.key});

  bool _isActive(Map<String, dynamic> plan) {
    final status = plan['status']?.toString();
    final endDate = plan['end_date'];
    if (status != 'active') return false;
    if (endDate == null) return true;
    try {
      final expiry = DateTime.parse(endDate.toString());
      return expiry.isAfter(DateTime.now().subtract(const Duration(days: 1)));
    } catch (_) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(currentPlanProvider);
    final freeTrialState = ref.watch(freeTrialNotifierProvider);
    final isTrialLoading = freeTrialState.isLoading;
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Subscription',
          style: typography.display.md.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: FButton.icon(
          variant: .ghost,
          size: .sm,
          onPress: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/landlord/home');
            }
          },
          child: context.theme.icons.arrowLeft(context),
        ),
      ),
      body: planAsync.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (e, _) => ErrorState(
          message: AppError.getMessage(e),
          onRetry: () => ref.invalidate(currentPlanProvider),
        ),
        data: (plan) {
          final hasActivePlan = plan.isNotEmpty && _isActive(plan);
          final planName =
              plan['plan']?['name'] ?? plan['plan_name'] ?? 'No Plan';
          final price = (plan['plan']?['price'] ?? plan['price'] ?? 0);
          final priceFormatted = (price is num
                  ? price.toDouble()
                  : double.tryParse(price.toString()) ?? 0.0)
              .toStringAsFixed(0);
          final billingCycle =
              plan['plan']?['billing_cycle'] ?? plan['billing_cycle'] ?? 'monthly';
          final endDate = plan['end_date'];
          final isTrial =
              planName.toLowerCase().contains('trial') || billingCycle == 'trial';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your current plan',
                  style:
                      typography.display.lg.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage your subscription and billing details below.',
                  style: typography.body.xs2
                      .copyWith(color: colors.mutedForeground),
                ),
                const SizedBox(height: 20),

                // Active plan card
                FCard(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                hasActivePlan ? planName : 'No Active Plan',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: typography.body.lg
                                    .copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            if (hasActivePlan)
                              _pill(context, 'ACTIVE', const Color(0xFF16A34A)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (hasActivePlan) ...[
                          Text(
                            isTrial
                                ? 'Free Trial Period'
                                : 'TZS $priceFormatted / ${billingCycle.toLowerCase()}',
                            style: typography.body.sm
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isTrial
                                ? 'Expires on: $endDate'
                                : 'Next renewal: $endDate',
                            style: typography.body.xs3
                                .copyWith(color: colors.mutedForeground),
                          ),
                        ] else ...[
                          Text(
                            'Your account is currently inactive. Subscribe to a plan to start managing your properties.',
                            style: typography.body.xs2.copyWith(
                                color: colors.mutedForeground, height: 1.5),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (!hasActivePlan || isTrial) ...[
                  FCard(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedZap,
                                size: 18,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Start Free Trial',
                                style: typography.body.sm
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try all premium features for 3 days at no cost.',
                            style: typography.body.xs2.copyWith(
                                color: colors.mutedForeground, height: 1.4),
                          ),
                          const SizedBox(height: 14),
                          FButton(
                            variant: .primary,
                            size: .sm,
                            onPress: isTrialLoading
                                ? null
                                : () async {
                                    final success = await ref
                                        .read(freeTrialNotifierProvider.notifier)
                                        .activate();
                                    if (success && context.mounted) {
                                      AppToast.success(
                                          context,
                                          context.tr(
                                              'free_trial_activated_dashboard'));
                                      context.go('/landlord/home');
                                    } else if (context.mounted) {
                                      final errState = ref
                                          .read(freeTrialNotifierProvider);
                                      final errMsg = errState.maybeWhen(
                                        error: (e, _) =>
                                            AppError.getMessage(e),
                                        orElse: () =>
                                            'Failed to activate free trial. You may already have an active subscription.',
                                      );
                                      ref
                                          .read(freeTrialNotifierProvider
                                              .notifier)
                                          .clearError();
                                      AppToast.error(context, errMsg);
                                    }
                                  },
                            child: isTrialLoading
                                ? const FCircularProgress()
                                : Text(context.tr('activate_trial')),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                FButton(
                  variant: hasActivePlan ? .outline : .primary,
                  onPress: () =>
                      context.push('/landlord/subscription/plans'),
                  child: Text(hasActivePlan
                      ? 'Change My Plan'
                      : 'View Subscriptions'),
                ),

                const SizedBox(height: 28),
                Text(
                  'Billing History',
                  style: typography.display.sm
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _buildHistoryList(context, ref, colors, typography),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _pill(BuildContext context, String label, Color color) {
    final typography = context.theme.typography;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: context.theme.style.borderRadius.pill,
      ),
      child: Text(
        label,
        style: typography.body.xs3.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: color,
        ),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, WidgetRef ref, FColors colors,
      FTypography typography) {
    final invoicesAsync = ref.watch(subscriptionInvoicesProvider);
    return invoicesAsync.when(
      loading: () => const Center(child: FCircularProgress()),
      error: (e, _) => Text(
        context.tr('could_not_load_history'),
        style: typography.body.xs2.copyWith(color: colors.mutedForeground),
      ),
      data: (invoices) {
        if (invoices.isEmpty) {
          return FCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Text(
                  'No billing history yet.',
                  style: typography.body.xs2
                      .copyWith(color: colors.mutedForeground),
                ),
              ),
            ),
          );
        }
        return Column(
          children: invoices.map((invoice) {
            final planName = invoice['plan']?['name'] ?? 'Subscription';
            final amount = invoice['amount'] ?? 0;
            final amountDouble = (amount is num
                ? amount.toDouble()
                : double.tryParse(amount.toString()) ?? 0.0);
            final amountFormatted = amountDouble.toStringAsFixed(0);
            final status = invoice['status']?.toString() ?? 'unknown';
            final paid = status == 'active' || status == 'paid';
            final date = invoice['created_at']?.toString() ?? '';
            final statusColor =
                paid ? const Color(0xFF16A34A) : colors.error;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FTappable(
                onPress: () => context.push('/landlord/subscription/invoice',
                    extra: invoice),
                child: FCard(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: HugeIcon(
                              icon: paid
                                  ? HugeIcons.strokeRoundedCheckmarkCircle02
                                  : HugeIcons.strokeRoundedAlert02,
                              size: 16,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                planName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: typography.body.sm.copyWith(
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                date.isNotEmpty ? date.substring(0, 10) : '-',
                                style: typography.body.xs3.copyWith(
                                    color: colors.mutedForeground),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          amountFormatted == '0' ? 'FREE' : 'TZS $amountFormatted',
                          style: typography.body.sm
                              .copyWith(fontWeight: FontWeight.w800),
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
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
