import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/subscription_provider.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final planAsync = ref.watch(currentPlanProvider);
    final freeTrialState = ref.watch(freeTrialNotifierProvider);
    final isTrialLoading = freeTrialState.isLoading;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Current Plan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/landlord/home');
            }
          },
        ),
      ),
      body: planAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(currentPlanProvider)),
        data: (plan) {
          final hasActivePlan = plan.isNotEmpty && _isActive(plan);
          final planName = plan['plan']?['name'] ?? plan['plan_name'] ?? 'No Plan';
          final price = plan['plan']?['price'] ?? plan['price'] ?? 0;
          final billingCycle = plan['plan']?['billing_cycle'] ?? plan['billing_cycle'] ?? 'monthly';
          final endDate = plan['end_date'];
          final isTrial = planName.toLowerCase().contains('trial') || billingCycle == 'trial';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              hasActivePlan ? planName : 'No Active Plan',
                              style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ),
                          if (hasActivePlan)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Active',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (hasActivePlan) ...[
                        Text(
                          isTrial ? 'Free Trial' : 'TZS $price/${billingCycle.replaceAll('ly', '')}',
                          style: const TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isTrial ? 'Expires on $endDate' : 'Renews on $endDate',
                          style: const TextStyle(fontSize: 12, color: Colors.white60),
                        ),
                      ] else ...[
                        Text(
                          'Your subscription is inactive. Choose a plan or start a free trial.',
                          style: const TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (!hasActivePlan || isTrial) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.card_giftcard, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Free Trial',
                              style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enjoy full access for 3 days at no cost. No payment required.',
                          style: GoogleFonts.nunito(fontSize: 13, color: isDark ? Colors.white70 : AppColors.textLight),
                        ),
                        const SizedBox(height: 16),
                        if (freeTrialState.hasError)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              freeTrialState.error.toString(),
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        PrimaryButton(
                          text: isTrialLoading ? 'Activating...' : 'Activate Free Trial',
                          icon: isTrialLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.bolt),
                          onPressed: isTrialLoading
                              ? null
                              : () async {
                                  final success = await ref.read(freeTrialNotifierProvider.notifier).activate();
                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Free trial activated! You can now use the dashboard.'), backgroundColor: AppColors.primary),
                                    );
                                    context.go('/landlord/home');
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                PrimaryButton(
                  text: hasActivePlan ? 'Change Plan' : 'Choose Plan',
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: () => context.push('/landlord/subscription/plans'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
