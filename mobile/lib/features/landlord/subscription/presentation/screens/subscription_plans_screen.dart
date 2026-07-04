import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/subscription_provider.dart';
import '../widgets/plan_card.dart';

class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  ConsumerState<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends ConsumerState<SubscriptionPlansScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final currentPlanAsync = ref.watch(currentPlanProvider);
    final currentPlanId = currentPlanAsync.maybeWhen(data: (d) => d['plan_id'], orElse: () => null);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/landlord/subscription');
            }
          },
        ),
      ),
      body: plansAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(subscriptionPlansProvider)),
        data: (plans) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
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
      final success = await ref.read(freeTrialNotifierProvider.notifier).activate();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Free trial activated!'), backgroundColor: AppColors.primary),
        );
        context.go('/landlord/home');
      }
      return;
    }
    context.push('/landlord/subscription/checkout?plan_id=${plan['id']}');
  }
}
