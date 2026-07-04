import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../features/auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/income_chart.dart';
import '../widgets/recent_activity_list.dart';
import '../widgets/summary_cards.dart';

class LandlordHomeScreen extends ConsumerWidget {
  const LandlordHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final dashboardAsync = ref.watch(landlordDashboardProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(landlordDashboardProvider),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, user?.fullName ?? 'Landlord'),
                const SizedBox(height: 24),
                dashboardAsync.when(
                  loading: () => const LoadingIndicator(),
                  error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(landlordDashboardProvider)),
                  data: (data) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SummaryCards(data: data),
                      const SizedBox(height: 24),
                      Text('Income Overview', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                      const SizedBox(height: 12),
                      IncomeChart(data: data),
                      const SizedBox(height: 24),
                      Text('Recent Activity', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                      const SizedBox(height: 12),
                      RecentActivityList(activities: data['recent_activity'] ?? []),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, $name', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
              const SizedBox(height: 4),
              Text('Welcome back to your dashboard', style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : AppColors.textLight)),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.push('/settings'),
          icon: const Icon(Icons.settings_outlined),
          color: isDark ? Colors.white : AppColors.textDark,
        ),
      ],
    );
  }
}
