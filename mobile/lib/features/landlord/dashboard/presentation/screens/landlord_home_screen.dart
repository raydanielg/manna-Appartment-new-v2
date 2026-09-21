import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../../core/config/app_config.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/theme_mode_button.dart';
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
    final user = ref.watch(authProvider).user;
    final dashboardAsync = ref.watch(landlordDashboardProvider);
    final unreadCount = ref.watch(unreadCountProvider).value ?? 0;
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(landlordDashboardProvider),
          color: colors.primary,
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
                    final message = AppError.getMessage(e);
                    final isSetup = AppError.isSetupError(e);
                    return ErrorState(
                      message: message,
                      onRetry: () => ref.invalidate(landlordDashboardProvider),
                      onAction: isSetup ? () => context.go('/landlord/subscription') : null,
                      actionLabel: context.tr('complete_setup'),
                    );
                  },
                  data: (data) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SummaryCards(data: data),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('income_overview'),
                            style: typography.display.lg.copyWith(fontWeight: FontWeight.w700),
                          ),
                          FButton(
                            variant: .ghost,
                            size: .sm,
                            mainAxisSize: MainAxisSize.min,
                            onPress: () => context.push('/landlord/finance-report'),
                            suffix: context.theme.icons.chevronRight(context),
                            child: Text(context.tr('view_report')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      IncomeChart(data: data),
                      const SizedBox(height: 24),
                      _buildTenantsSection(context, ref),
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
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final name = user?.fullName ?? context.tr('landlord');
    final avatarUrl = user?.avatar;
    final initials = name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();

    return Row(
      children: [
        FTappable(
          onPress: () => context.push('/landlord/profile'),
          child: FAvatar.raw(
            size: 46,
            child: avatarUrl != null && avatarUrl.isNotEmpty
                ? Image.network(
                    _avatarUrl(avatarUrl),
                    key: ValueKey(avatarUrl),
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Text(initials),
                  )
                : Text(initials),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${context.tr('hello')}, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.body.lg.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                context.tr('welcome_back'),
                style: typography.body.xs.copyWith(color: colors.mutedForeground),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            FButton.icon(
              variant: .outline,
              size: .sm,
              onPress: () => context.push('/notifications'),
              child: const HugeIcon(icon: HugeIcons.strokeRoundedNotification02, size: null),
            ),
            if (unreadCount > 0)
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.background, width: 1.5),
                  ),
                  constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: TextStyle(
                      color: colors.errorForeground,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
        const ThemeModeButton(),
      ],
    );
  }

  Widget _buildTenantsSection(BuildContext context, WidgetRef ref) {
    final tenantsAsync = ref.watch(tenantsListProvider(null));
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('tenants'),
              style: typography.display.lg.copyWith(fontWeight: FontWeight.w700),
            ),
            FButton(
              variant: .ghost,
              size: .sm,
              mainAxisSize: MainAxisSize.min,
              onPress: () => context.push('/landlord/tenants'),
              suffix: context.theme.icons.chevronRight(context),
              child: Text(context.tr('view_all')),
            ),
          ],
        ),
        const SizedBox(height: 12),
        tenantsAsync.when(
          loading: () => const LoadingIndicator(),
          error: (_, _) => const SizedBox.shrink(),
          data: (tenants) {
            if (tenants.isEmpty) {
              return FCard(
                child: Center(
                  child: Column(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedUserGroup,
                        size: 36,
                        color: colors.mutedForeground.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        context.tr('no_tenants_yet'),
                        style: typography.body.xs.copyWith(color: colors.mutedForeground),
                      ),
                    ],
                  ),
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
    final base = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/api(/v1)?/?$'), '');
    final separator = avatar.startsWith('/') ? '' : '/';
    return '$base$separator$avatar';
  }
}
