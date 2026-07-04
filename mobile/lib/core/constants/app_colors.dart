import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF059669); // Emerald 600
  static const Color primaryDark = Color(0xFF047857); // Emerald 700
  static const Color primaryLight = Color(0xFF10B981); // Emerald 500
  static const Color gold = Color(0xFFFACC15); // Gold
  static const Color goldDark = Color(0xFFEAB308);

  // Semantic colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Text
  static const Color textDark = Color(0xFF111827);
  static const Color textLight = Color(0xFF6B7280);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Light theme backgrounds
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightInput = Color(0xFFF3F4F6);

  // Dark theme backgrounds
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkInput = Color(0xFF334155);

  static AppColorTheme themeFor(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return AppColorTheme(
      background: isDark ? darkBackground : lightBackground,
      surface: isDark ? darkSurface : lightSurface,
      card: isDark ? darkCard : lightCard,
      input: isDark ? darkInput : lightInput,
      textPrimary: isDark ? textWhite : textDark,
      textSecondary: isDark ? Colors.white70 : textLight,
      divider: isDark ? Colors.white12 : Colors.grey.shade200,
    );
  }
}

class AppColorTheme {
  final Color background;
  final Color surface;
  final Color card;
  final Color input;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;

  const AppColorTheme({
    required this.background,
    required this.surface,
    required this.card,
    required this.input,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
  });
}
