import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../providers/subscription_provider.dart';
import '../widgets/plan_card.dart';

import 'package:manna_apartment/core/utils/app_toast.dart';

class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  ConsumerState<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState
    extends ConsumerState<SubscriptionPlansScreen> {
  bool _isActivating = false;

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final currentPlanAsync = ref.watch(currentPlanProvider);
    final currentPlanId =
        currentPlanAsync.maybeWhen(data: (d) => d['plan_id'], orElse: () => null);
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('subscription_plans'),
          style: typography.display.md.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: FButton.icon(
          variant: .ghost,
          size: .sm,
          onPress: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/landlord/subscription');
            }
          },
          child: context.theme.icons.arrowLeft(context),
        ),
      ),
      body: plansAsync.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedAlert02,
                      size: 24,
                      color: colors.error,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load plans',
                  style:
                      typography.body.md.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: typography.body.xs2
                      .copyWith(color: colors.mutedForeground),
                ),
                const SizedBox(height: 20),
                FButton(
                  variant: .outline,
                  size: .sm,
                  mainAxisSize: MainAxisSize.min,
                  prefix: const HugeIcon(
                      icon: HugeIcons.strokeRoundedRefresh, size: null),
                  onPress: () => ref.invalidate(subscriptionPlansProvider),
                  child: Text(context.tr('retry')),
                ),
              ],
            ),
          ),
        ),
        data: (plans) => ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          itemCount: plans.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Your Plan',
                      style: typography.display.lg
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select a plan that fits your needs. You can upgrade or cancel anytime.',
                      style: typography.body.xs2
                          .copyWith(color: colors.mutedForeground, height: 1.5),
                    ),
                  ],
                ),
              );
            }
            final plan = plans[index - 1];
            final isTrial = plan['billing_cycle']?.toString() == 'trial';
            return PlanCard(
              plan: plan,
              isCurrent: plan['id'] == currentPlanId,
              onSelect: () => _selectPlan(plan, isTrial),
            );
          },
        ),
      ),
    );
  }

  Future<void> _selectPlan(Map<String, dynamic> plan, bool isTrial) async {
    if (isTrial) {
      if (_isActivating) return;
      setState(() => _isActivating = true);

      final success =
          await ref.read(freeTrialNotifierProvider.notifier).activate();

      if (!mounted) return;
      setState(() => _isActivating = false);

      if (success) {
        AppToast.success(context, context.tr('free_trial_activated'));
        context.go('/landlord/home');
      } else {
        final errorState = ref.read(freeTrialNotifierProvider);
        final errorMsg = errorState.maybeWhen(
          error: (e, _) => e.toString(),
          orElse: () =>
              'Failed to activate free trial. You may already have an active subscription.',
        );
        ref.read(freeTrialNotifierProvider.notifier).clearError();
        _showErrorAlert(context, errorMsg);
      }
      return;
    }
    context.push('/landlord/subscription/checkout?plan_id=${plan['id']}');
  }

  void _showErrorAlert(BuildContext context, String message) {
    showFDialog<void>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        builder: (context, style) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: context.theme.colors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedAlert02,
                        size: 16,
                        color: context.theme.colors.error,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Oops!', style: style.titleTextStyle),
                ],
              ),
              const SizedBox(height: 10),
              Text(message, style: style.bodyTextStyle),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: FButton(
                  variant: .primary,
                  size: .sm,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () => Navigator.pop(context),
                  child: Text(context.tr('ok')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
