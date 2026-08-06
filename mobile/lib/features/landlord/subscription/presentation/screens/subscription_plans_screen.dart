import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/widgets/error_state.dart';
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
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final currentPlanAsync = ref.watch(currentPlanProvider);
    final currentPlanId = currentPlanAsync.maybeWhen(data: (d) => d['plan_id'], orElse: () => null);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          context.tr('subscription_plans'),
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: AppColors.textDark, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
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
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(subscriptionPlansProvider)),
        data: (plans) => ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
          SnackBar(content: Text(context.tr('free_trial_activated')), backgroundColor: AppColors.primary, behavior: SnackBarBehavior.floating),
        );
        context.go('/landlord/home');
      }
      return;
    }
    context.push('/landlord/subscription/checkout?plan_id=${plan['id']}');
  }
}
