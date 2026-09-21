import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../../core/config/app_config.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/widgets/confirm_dialog.dart';
import '../../../../../features/auth/providers/auth_provider.dart';
import '../../../../../features/landlord/subscription/providers/subscription_provider.dart';

class LandlordMoreScreen extends ConsumerWidget {
  const LandlordMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final user = ref.watch(authProvider).user;
    final planAsync = ref.watch(currentPlanProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          context.tr('more'),
          style: typography.display.md.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          // Profile header — plain row
          _profileRow(context, colors, typography,
              user?.fullName ?? context.tr('landlord'), user?.phone ?? '',
              user?.avatar),
          const SizedBox(height: 8),

          // Current plan row
          planAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (plan) =>
                _planRow(context, colors, typography, plan),
          ),

          _sectionLabel(context, context.tr('management')),
          _row(context,
              icon: HugeIcons.strokeRoundedBuilding03,
              title: context.tr('properties'),
              onPress: () => context.push('/landlord/properties')),
          _row(context,
              icon: HugeIcons.strokeRoundedUserGroup,
              title: context.tr('tenants'),
              onPress: () => context.push('/landlord/tenants')),
          _row(context,
              icon: HugeIcons.strokeRoundedFile01,
              title: context.tr('contracts'),
              onPress: () => context.push('/landlord/contracts')),
          _row(context,
              icon: HugeIcons.strokeRoundedMoney01,
              title: context.tr('payments'),
              onPress: () => context.push('/landlord/payments')),
          _row(context,
              icon: HugeIcons.strokeRoundedAnalytics01,
              title: context.tr('revenue_report'),
              onPress: () => context.push('/landlord/finance-report')),
          _row(context,
              icon: HugeIcons.strokeRoundedFileSearch,
              title: context.tr('reports'),
              onPress: () => context.push('/landlord/reports')),
          _row(context,
              icon: HugeIcons.strokeRoundedMessage01,
              title: context.tr('sms_broadcast'),
              onPress: () => context.push('/landlord/sms')),
          _row(context,
              icon: HugeIcons.strokeRoundedWrench01,
              title: context.tr('maintenance'),
              onPress: () => context.push('/landlord/maintenance'),
              last: true),

          if (user?.role == 'super_admin') ...[
            _sectionLabel(context, context.tr('admin')),
            _row(context,
                icon: HugeIcons.strokeRoundedUserShield01,
                title: context.tr('manage_landlords'),
                onPress: () => context.push('/admin/landlords'),
                last: true),
          ],

          _sectionLabel(context, context.tr('account')),
          _row(context,
              icon: HugeIcons.strokeRoundedCrown,
              title: context.tr('subscription'),
              onPress: () => context.push('/landlord/subscription')),
          _row(context,
              icon: HugeIcons.strokeRoundedSetting07,
              title: context.tr('settings'),
              onPress: () => context.push('/settings')),
          _row(context,
              icon: HugeIcons.strokeRoundedHelpCircle,
              title: context.tr('how_to_use'),
              onPress: () => context.push('/landlord/help')),
          _row(
            context,
            icon: HugeIcons.strokeRoundedLogout01,
            title: context.tr('logout'),
            destructive: true,
            onPress: () => _logout(context, ref),
            last: true,
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: context.tr('logout'),
      message: context.tr('confirm_logout'),
      confirmText: context.tr('logout'),
      cancelText: context.tr('cancel'),
      isDestructive: true,
    );
    if (!confirmed) return;
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) context.go('/auth/login');
  }

  Widget _sectionLabel(BuildContext context, String label) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 2, left: 4),
      child: Text(
        label.toUpperCase(),
        style: typography.body.xs3.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: colors.mutedForeground,
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required List<List<dynamic>> icon,
    required String title,
    bool destructive = false,
    bool last = false,
    VoidCallback? onPress,
  }) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final fg = destructive ? colors.error : colors.foreground;
    final iconColor = destructive ? colors.error : colors.mutedForeground;

    return FTappable(
      onPress: onPress,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: last
              ? null
              : Border(
                  bottom: BorderSide(
                      color: colors.border.withValues(alpha: 0.5)),
                ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            children: [
              HugeIcon(icon: icon, size: 19, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.body.sm.copyWith(
                    fontWeight: FontWeight.w500,
                    color: fg,
                  ),
                ),
              ),
              HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 15,
                color: destructive
                    ? colors.error.withValues(alpha: 0.6)
                    : colors.mutedForeground.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _planRow(BuildContext context, FColors colors,
      FTypography typography, Map<String, dynamic> plan) {
    final planName = plan['plan']?['name'] ?? plan['plan_name'] ?? 'No Plan';
    final isActive = (plan['status']?.toString() ?? '') == 'active';
    final statusColor =
        isActive ? const Color(0xFF16A34A) : colors.error;

    return FTappable(
      onPress: () => context.push('/landlord/subscription'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCrown,
                  size: 16,
                  color: colors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    planName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.body.sm
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    context.tr('current_plan'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.body.xs3
                        .copyWith(color: colors.mutedForeground),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: context.theme.style.borderRadius.pill,
              ),
              child: Text(
                isActive
                    ? context.tr('active').toUpperCase()
                    : context.tr('inactive').toUpperCase(),
                style: typography.body.xs3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileRow(BuildContext context, FColors colors,
      FTypography typography, String name, String phone, String? avatarUrl) {
    var avatarSrc = avatarUrl != null && avatarUrl.isNotEmpty
        ? (avatarUrl.startsWith('http')
            ? avatarUrl
            : '${AppConfig.apiBaseUrl.replaceAll(RegExp(r'/api(/v1)?/?$'), '')}${avatarUrl.startsWith('/') ? '' : '/'}$avatarUrl')
        : null;
    if (avatarSrc != null &&
        avatarSrc.contains('/storage/') &&
        !avatarSrc.contains('/public/storage/')) {
      avatarSrc = avatarSrc.replaceFirst('/storage/', '/public/storage/');
    }
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'L';

    return FTappable(
      onPress: () => context.push('/landlord/profile'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            FAvatar.raw(
              size: 44,
              child: avatarSrc != null
                  ? Image.network(
                      avatarSrc,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _initial(
                          colors, typography, initial),
                    )
                  : _initial(colors, typography, initial),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.body.sm
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.body.xs3
                        .copyWith(color: colors.mutedForeground),
                  ),
                ],
              ),
            ),
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              size: 16,
              color: colors.mutedForeground.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initial(FColors colors, FTypography typography, String initial) {
    return Container(
      color: colors.secondary,
      child: Center(
        child: Text(
          initial,
          style: typography.display.sm.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.secondaryForeground,
          ),
        ),
      ),
    );
  }
}
