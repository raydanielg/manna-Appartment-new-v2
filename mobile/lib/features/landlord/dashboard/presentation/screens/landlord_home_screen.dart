import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_config.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../features/auth/data/models/login_response_model.dart';
import '../../../../../features/auth/providers/auth_provider.dart';
import '../../../../../shared/notifications/providers/notifications_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../../tenants/providers/tenants_provider.dart';
import '../../../tenants/presentation/widgets/tenant_card.dart';
import '../widgets/income_chart.dart';
import '../widgets/summary_cards.dart';

class LandlordHomeScreen extends ConsumerWidget {
  const LandlordHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final dashboardAsync = ref.watch(landlordDashboardProvider);
    final unreadCount = ref.watch(unreadCountProvider).value ?? 0;

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
                _buildHeader(context, user, unreadCount),
                const SizedBox(height: 24),
                dashboardAsync.when(
                  loading: () => const LoadingIndicator(),
                  error: (e, _) {
                    final message = e.toString();
                    final isSetupError = message.toLowerCase().contains('kyc') ||
                        message.toLowerCase().contains('subscription') ||
                        message.toLowerCase().contains('organization');
                    return ErrorState(
                      message: message,
                      onRetry: () => ref.invalidate(landlordDashboardProvider),
                      onAction: isSetupError ? () => context.go('/landlord/subscription') : null,
                      actionLabel: 'Complete Setup',
                    );
                  },
                  data: (data) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SummaryCards(data: data),
                      const SizedBox(height: 24),
                      Text('Income Overview', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                      const SizedBox(height: 12),
                      IncomeChart(data: data),
                      const SizedBox(height: 24),
                      _buildTenantsSection(context, ref, isDark),
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

  Widget _buildHeader(BuildContext context, UserModel? user, int unreadCount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = user?.fullName ?? 'Landlord';
    final avatarUrl = user?.avatar;
    final initials = name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.push('/landlord/profile'),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? Image.network(
                      _avatarUrl(avatarUrl),
                      key: ValueKey(avatarUrl),
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          initials,
                          style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        initials,
                        style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () => context.push('/notifications'),
                icon: const Icon(Icons.notifications_none_rounded, size: 20),
                color: isDark ? Colors.white70 : AppColors.textLight,
                padding: EdgeInsets.zero,
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTenantsSection(BuildContext context, WidgetRef ref, bool isDark) {
    final tenantsAsync = ref.watch(tenantsListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tenants',
              style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark),
            ),
            TextButton(
              onPressed: () => context.push('/landlord/tenants'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios, size: 11, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        tenantsAsync.when(
          loading: () => const LoadingIndicator(),
          error: (_, __) => const SizedBox.shrink(),
          data: (tenants) {
            if (tenants.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.people_outline, size: 36, color: isDark ? Colors.white24 : Colors.grey.shade300),
                    const SizedBox(height: 10),
                    Text(
                      'No tenants yet',
                      style: GoogleFonts.nunito(fontSize: 13, color: isDark ? Colors.white38 : Colors.grey.shade400),
                    ),
                  ],
                ),
              );
            }
            final recent = tenants.take(3).toList();
            return Column(
              children: recent.map((t) => TenantCard(tenant: t)).toList(),
            );
          },
        ),
      ],
    );
  }

  String _avatarUrl(String avatar) {
    if (avatar.isEmpty) return avatar;
    if (avatar.startsWith('http://') || avatar.startsWith('https://')) return avatar;
    final base = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/api/?$'), '');
    final separator = avatar.startsWith('/') ? '' : '/';
    return '$base$separator$avatar';
  }
}
