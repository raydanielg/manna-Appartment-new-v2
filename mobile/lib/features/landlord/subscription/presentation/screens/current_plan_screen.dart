import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/error_state.dart';
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
    final planAsync = ref.watch(currentPlanProvider);
    final freeTrialState = ref.watch(freeTrialNotifierProvider);
    final isTrialLoading = freeTrialState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Subscription',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: const Color(0xFF111827), fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF111827)),
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
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
        error: (e, _) => ErrorState(message: AppError.getMessage(e), onRetry: () => ref.invalidate(currentPlanProvider)),
        data: (plan) {
          final hasActivePlan = plan.isNotEmpty && _isActive(plan);
          final planName = plan['plan']?['name'] ?? plan['plan_name'] ?? 'No Plan';
          final price = (plan['plan']?['price'] ?? plan['price'] ?? 0);
          final priceFormatted = (price is num
                  ? price.toDouble()
                  : double.tryParse(price.toString()) ?? 0.0)
              .toStringAsFixed(0);
          final billingCycle = plan['plan']?['billing_cycle'] ?? plan['billing_cycle'] ?? 'monthly';
          final endDate = plan['end_date'];
          final isTrial = planName.toLowerCase().contains('trial') || billingCycle == 'trial';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Your current plan',
                  style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your subscription and billing details below.',
                  style: GoogleFonts.nunito(fontSize: 14, color: const Color(0xFF6B7280)),
                ),
                const SizedBox(height: 32),
                
                // Active Plan Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            hasActivePlan ? planName : 'No Active Plan',
                            style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
                          ),
                          if (hasActivePlan)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF166534), letterSpacing: 0.5),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (hasActivePlan) ...[
                        Text(
                          isTrial ? 'Free Trial Period' : 'TZS $priceFormatted / ${billingCycle.toLowerCase()}',
                          style: GoogleFonts.nunito(fontSize: 15, color: const Color(0xFF374151), fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isTrial ? 'Expires on: $endDate' : 'Next renewal: $endDate',
                          style: GoogleFonts.nunito(fontSize: 12, color: const Color(0xFF6B7280), fontWeight: FontWeight.w600),
                        ),
                      ] else ...[
                        Text(
                          'Your account is currently inactive. Subscribe to a plan to start managing your properties.',
                          style: GoogleFonts.nunito(fontSize: 14, color: const Color(0xFF4B5563), height: 1.4),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                if (!hasActivePlan || isTrial) ...[
                  // Free Trial Option
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome_rounded, color: Color(0xFF2563EB), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Start Free Trial',
                              style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF1D4ED8)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try all premium features for 3 days at no cost.',
                          style: GoogleFonts.nunito(fontSize: 13, color: const Color(0xFF2563EB).withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isTrialLoading ? null : () async {
                              final success = await ref.read(freeTrialNotifierProvider.notifier).activate();
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(context.tr('free_trial_activated_dashboard')), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
                                );
                                context.go('/landlord/home');
                              } else if (context.mounted) {
                                final errState = ref.read(freeTrialNotifierProvider);
                                final errMsg = errState.maybeWhen(
                                  error: (e, _) => AppError.getMessage(e),
                                  orElse: () => 'Failed to activate free trial. You may already have an active subscription.',
                                );
                                ref.read(freeTrialNotifierProvider.notifier).clearError();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errMsg),
                                    backgroundColor: AppColors.error,
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFF2563EB),
                              disabledForegroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.35),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: isTrialLoading 
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(context.tr('activate_trial'), style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.push('/landlord/subscription/plans'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasActivePlan ? Colors.white : const Color(0xFF2563EB),
                      foregroundColor: hasActivePlan ? const Color(0xFF2563EB) : Colors.white,
                      elevation: hasActivePlan ? 0 : 4,
                      shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.35),
                      side: hasActivePlan ? const BorderSide(color: Color(0xFF2563EB), width: 1.5) : BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      hasActivePlan ? 'Change My Plan' : 'View Subscriptions',
                      style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                Text(
                  'Billing History',
                  style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
                ),
                const SizedBox(height: 12),
                _buildHistoryList(context, ref),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(subscriptionInvoicesProvider);
    return invoicesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
      error: (e, _) => Text(context.tr('could_not_load_history'), style: GoogleFonts.nunito(color: const Color(0xFF6B7280))),
      data: (invoices) {
        if (invoices.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              'No billing history yet.',
              style: GoogleFonts.nunito(color: const Color(0xFF6B7280), fontWeight: FontWeight.w600, fontSize: 13),
              textAlign: TextAlign.center,
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
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: ListTile(
                tileColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: paid ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(paid ? Icons.check_rounded : Icons.priority_high_rounded, size: 18, color: paid ? const Color(0xFF166534) : const Color(0xFFB91C1C)),
                ),
                title: Text(planName, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF111827))),
                subtitle: Text(
                  date.isNotEmpty ? date.substring(0, 10) : '-',
                  style: GoogleFonts.nunito(fontSize: 12, color: const Color(0xFF6B7280), fontWeight: FontWeight.w600),
                ),
                trailing: Text(
                  amountFormatted == '0' ? 'FREE' : 'TZS $amountFormatted',
                  style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF111827)),
                ),
                onTap: () => context.push('/landlord/subscription/invoice', extra: invoice),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
