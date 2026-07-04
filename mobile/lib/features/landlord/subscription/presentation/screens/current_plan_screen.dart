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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final planAsync = ref.watch(currentPlanProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Current Plan'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: planAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(currentPlanProvider)),
        data: (plan) => SingleChildScrollView(
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
                    Text(plan['plan_name'] ?? 'Free Plan', style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('TZS ${plan['price'] ?? 0}/month', style: const TextStyle(fontSize: 16, color: Colors.white70)),
                    const SizedBox(height: 12),
                    Text('Renews on ${plan['renews_at'] ?? 'N/A'}', style: const TextStyle(fontSize: 12, color: Colors.white60)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(text: 'Upgrade Plan', icon: const Icon(Icons.arrow_upward), onPressed: () => context.push('/landlord/subscription/plans')),
            ],
          ),
        ),
      ),
    );
  }
}
