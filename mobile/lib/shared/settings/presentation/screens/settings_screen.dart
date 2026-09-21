import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../core/widgets/theme_mode_button.dart';
import '../../../../features/auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final currentLanguage =
        locale.languageCode == 'sw' ? 'Swahili' : 'English';
    final themeLabel = switch (themeMode) {
      ThemeMode.dark => 'Dark',
      ThemeMode.light => 'Light',
      _ => 'System',
    };

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('settings'),
          style: typography.display.md.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: FButton.icon(
          variant: .ghost,
          size: .sm,
          onPress: () {
            if (context.canPop()) {
              context.pop();
            } else {
              final authState = ref.read(authProvider);
              if (authState.role == 'tenant') {
                context.go('/tenant/home');
              } else if (authState.isKycApproved) {
                context.go('/landlord/home');
              } else {
                context.go('/landlord/kyc');
              }
            }
          },
          child: context.theme.icons.arrowLeft(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle(colors, typography, context.tr('about')),
          _menuItem(
            context,
            colors,
            typography,
            icon: HugeIcons.strokeRoundedMoon02,
            title: 'Appearance',
            subtitle: 'Theme: $themeLabel',
            trailing: const ThemeModeButton(),
            onTap: () =>
                ref.read(themeModeProvider.notifier).toggle(),
          ),
          _menuItem(
            context,
            colors,
            typography,
            icon: HugeIcons.strokeRoundedGlobe02,
            title: context.tr('language'),
            subtitle: '${context.tr('language')}: $currentLanguage',
            onTap: () => context.push('/settings/language'),
          ),
          _menuItem(
            context,
            colors,
            typography,
            icon: HugeIcons.strokeRoundedInformationCircle,
            title: context.tr('about'),
            subtitle: 'Manna Apartment v3.4.0+9',
            onTap: () => context.push('/settings/about'),
          ),
          _menuItem(
            context,
            colors,
            typography,
            icon: HugeIcons.strokeRoundedHelpCircle,
            title: context.tr('help_support'),
            subtitle: context.tr('contact_support'),
            onTap: () => context.push('/settings/help-support'),
          ),
          const SizedBox(height: 20),
          _sectionTitle(colors, typography, context.tr('legal')),
          _menuItem(
            context,
            colors,
            typography,
            icon: HugeIcons.strokeRoundedShield01,
            title: context.tr('privacy_policy'),
            subtitle: context.tr('privacy_policy'),
            onTap: () => context.push('/settings/privacy'),
          ),
          _menuItem(
            context,
            colors,
            typography,
            icon: HugeIcons.strokeRoundedFile01,
            title: context.tr('terms_of_service'),
            subtitle: context.tr('terms_of_service'),
            onTap: () => context.push('/settings/terms'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(FColors colors, FTypography typography, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: typography.body.xs3.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: colors.mutedForeground,
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    FColors colors,
    FTypography typography, {
    required List<List<dynamic>> icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return FTappable(
      onPress: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              HugeIcon(icon: icon, size: 17, color: colors.mutedForeground),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.sm
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.xs3
                          .copyWith(color: colors.mutedForeground),
                    ),
                  ],
                ),
              ),
              trailing ??
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    size: 14,
                    color: colors.mutedForeground.withValues(alpha: 0.6),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
