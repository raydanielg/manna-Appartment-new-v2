import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../providers/subscription_provider.dart';
import '../widgets/plan_card.dart';

class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  ConsumerState<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends ConsumerState<SubscriptionPlansScreen> {
  bool _isActivating = false;

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final currentPlanAsync = ref.watch(currentPlanProvider);
    final currentPlanId = currentPlanAsync.maybeWhen(data: (d) => d['plan_id'], orElse: () => null);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
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
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load plans',
                  style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textLight),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(subscriptionPlansProvider),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(context.tr('retry'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
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
                      style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select a plan that fits your needs. You can upgrade or cancel anytime.',
                      style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textLight, height: 1.4),
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

      final success = await ref.read(freeTrialNotifierProvider.notifier).activate();

      if (!mounted) return;
      setState(() => _isActivating = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('free_trial_activated')),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/landlord/home');
      } else {
        final errorState = ref.read(freeTrialNotifierProvider);
        final errorMsg = errorState.maybeWhen(
          error: (e, _) => e.toString(),
          orElse: () => 'Failed to activate free trial. You may already have an active subscription.',
        );
        ref.read(freeTrialNotifierProvider.notifier).clearError();
        _showErrorAlert(context, errorMsg);
      }
      return;
    }
    context.push('/landlord/subscription/checkout?plan_id=${plan['id']}');
  }

  void _showErrorAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, color: AppColors.error, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Oops!', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textLight, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            child: Text(context.tr('ok')),
          ),
        ],
      ),
    );
  }
}
