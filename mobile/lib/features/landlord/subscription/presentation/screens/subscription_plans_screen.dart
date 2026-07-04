import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/subscription_provider.dart';
import '../widgets/plan_card.dart';

class SubscriptionPlansScreen extends ConsumerWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final currentPlanAsync = ref.watch(currentPlanProvider);
    final currentPlanId = currentPlanAsync.maybeWhen(data: (d) => d['plan_id'], orElse: () => null);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Subscription Plans'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: plansAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(subscriptionPlansProvider)),
        data: (plans) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return PlanCard(
              plan: plan,
              isCurrent: plan['id'] == currentPlanId,
              onSelect: () => context.push('/landlord/subscription/checkout?plan_id=${plan['id']}'),
            );
          },
        ),
      ),
    );
  }
}
