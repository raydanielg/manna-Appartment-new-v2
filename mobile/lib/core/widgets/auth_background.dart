import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: child,
      ),
    );
  }

  static ValueNotifier<bool> get isDarkMode => _darkModeNotifier;
}

final ValueNotifier<bool> _darkModeNotifier = ValueNotifier<bool>(false);

/// Reusable auth card - simplified to just a container for the modern flat look
class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: child,
    );
  }
}

/// Helper to get colors based on dark mode (defaulting to clean light mode)
class AuthColors {
  static bool get isDark => _darkModeNotifier.value;

  static Color get card => Colors.white;
  static Color get text => const Color(0xFF111827);
  static Color get textSecondary => const Color(0xFF4B5563);
  static Color get input => const Color(0xFFF9FAFB);
  static Color get inputBorder => const Color(0xFFE5E7EB);
  static Color get inputBorderFocused => const Color(0xFF2563EB);
  static Color get hintText => const Color(0xFF9CA3AF);
  static Color get label => const Color(0xFF374151);
  static Color get primary => const Color(0xFF2563EB); // Modern Blue
  static Color get error => const Color(0xFFEF4444);
  static Color get errorBg => const Color(0xFFFEF2F2);
  static Color get errorBorder => const Color(0xFFFECACA);
  static Color get prefixIcon => const Color(0xFF6B7280);
  static Color get suffixIcon => const Color(0xFF9CA3AF);
}
