import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/theme_mode_provider.dart';

/// Icon button that toggles between light and dark mode.
class ThemeModeButton extends ConsumerWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.theme.colors.brightness == .dark;

    return FButton.icon(
      variant: .outline,
      size: .sm,
      onPress: () => ref.read(themeModeProvider.notifier).toggle(),
      child: HugeIcon(
        icon: isDark ? HugeIcons.strokeRoundedSun01 : HugeIcons.strokeRoundedMoon02,
        size: null,
      ),
    );
  }
}
