import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../features/auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final currentLanguage = locale.languageCode == 'sw' ? 'Swahili' : 'English';

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
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
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle(context, context.tr('about')),
          _buildMenuItem(
            context,
            icon: Icons.language,
            title: context.tr('language'),
            subtitle: 'Current: $currentLanguage',
            onTap: () => context.push('/settings/language'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: context.tr('about'),
            subtitle: 'Manna Apartment v1.0.0',
            onTap: () => context.push('/settings/about'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: context.tr('help_support'),
            subtitle: 'Get help and contact support',
            onTap: () => context.push('/settings/help-support'),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(context, context.tr('legal')),
          _buildMenuItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: context.tr('privacy_policy'),
            subtitle: 'Read our privacy policy',
            onTap: () => context.push('/settings/privacy'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.description_outlined,
            title: context.tr('terms_of_service'),
            subtitle: 'Read our terms of service',
            onTap: () => context.push('/settings/terms'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textLight,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

