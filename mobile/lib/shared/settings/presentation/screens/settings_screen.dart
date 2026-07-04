import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app.dart';
import '../../../../core/constants/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle(context, 'Appearance'),
          Card(
            child: Column(
              children: [
                _ThemeOption(
                  icon: Icons.phone_android,
                  title: 'System Default',
                  value: ThemeMode.system,
                  groupValue: themeMode,
                  onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v),
                ),
                const Divider(height: 1, indent: 56),
                _ThemeOption(
                  icon: Icons.light_mode,
                  title: 'Light Mode',
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v),
                ),
                const Divider(height: 1, indent: 56),
                _ThemeOption(
                  icon: Icons.dark_mode,
                  title: 'Dark Mode',
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(context, 'App'),
          _buildMenuItem(context, icon: Icons.language, title: 'Language', subtitle: 'English / Swahili'),
          _buildMenuItem(context, icon: Icons.info_outline, title: 'About', subtitle: 'Manna Apartment v1.0.0'),
          _buildMenuItem(context, icon: Icons.help_outline, title: 'Help & Support', subtitle: 'Get help and contact support'),
          const SizedBox(height: 20),
          _buildSectionTitle(context, 'Legal'),
          _buildMenuItem(context, icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', subtitle: 'Read our privacy policy'),
          _buildMenuItem(context, icon: Icons.description_outlined, title: 'Terms of Service', subtitle: 'Read our terms of service'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white60 : AppColors.textLight,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white60 : AppColors.textLight,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final ThemeMode value;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? AppColors.primary : Colors.grey,
      ),
      onTap: () => onChanged(value),
    );
  }
}
