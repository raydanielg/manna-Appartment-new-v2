import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../features/auth/providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
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
    final initials = name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF059669), Color(0xFF047857)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              initials,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $name',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Welcome back to your dashboard',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white54 : AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => context.push('/notifications'),
            icon: const Icon(Icons.notifications_none_rounded, size: 20),
            color: isDark ? Colors.white70 : AppColors.textLight,
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
