import 'dart:async';
import 'package:flutter/material.dart';

class AuthBackground extends StatefulWidget {
  final Widget child;
  final bool showToggle;

  const AuthBackground({
    super.key,
    required this.child,
    this.showToggle = true,
  });

  @override
  State<AuthBackground> createState() => AuthBackgroundState();

  static ValueNotifier<bool> get isDarkMode => _darkModeNotifier;
}

final ValueNotifier<bool> _darkModeNotifier = ValueNotifier<bool>(false);

class AuthBackgroundState extends State<AuthBackground> {
  final _images = [
    'assets/images/managepropers.jpg',
    'assets/images/trackpayemnts.jpg',
    'assets/images/connectwithtenent.jpg',
  ];
  int _currentImage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (t) {
      if (mounted) {
        setState(() {
          _currentImage = (_currentImage + 1) % _images.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Rotating background images
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 1500),
          child: Image.asset(
            _images[_currentImage],
            key: ValueKey(_currentImage),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        // Blue gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.3, 0.7, 1.0],
              colors: [
                const Color(0xFF1E3A8A).withValues(alpha: 0.65),
                const Color(0xFF1E40AF).withValues(alpha: 0.55),
                const Color(0xFF1E3A8A).withValues(alpha: 0.80),
                const Color(0xFF172554).withValues(alpha: 0.95),
              ],
            ),
          ),
        ),

        // Dark/Light toggle
        if (widget.showToggle)
          Positioned(
            top: 12,
            right: 16,
            child: ValueListenableBuilder<bool>(
              valueListenable: _darkModeNotifier,
              builder: (context, dark, _) {
                return GestureDetector(
                  onTap: () => _darkModeNotifier.value = !dark,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubicEmphasized,
                    width: 64,
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: dark
                          ? const Color(0xFF1E293B)
                          : Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: dark
                            ? const Color(0xFF2563EB).withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: dark
                              ? const Color(0xFF2563EB).withValues(alpha: 0.3)
                              : Colors.black.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOutCubicEmphasized,
                          alignment: dark
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: dark
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFFBBF24),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (dark
                                          ? const Color(0xFF2563EB)
                                          : const Color(0xFFFBBF24))
                                      .withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              dark
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        // Content
        SafeArea(
          child: widget.child,
        ),
      ],
    );
  }

}

/// Reusable auth card that responds to dark/light mode
class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _darkModeNotifier,
      builder: (context, isDark, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
            border: isDark
                ? Border.all(color: Colors.white.withValues(alpha: 0.08))
                : null,
          ),
          child: child,
        );
      },
    );
  }
}

/// Helper to get colors based on dark mode
class AuthColors {
  static bool get isDark => _darkModeNotifier.value;

  static Color get card => isDark ? const Color(0xFF1E293B) : Colors.white;
  static Color get text => isDark ? Colors.white : const Color(0xFF1E293B);
  static Color get textSecondary =>
      isDark ? Colors.white70 : const Color(0xFF64748B);
  static Color get input =>
      isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6);
  static Color get inputBorder =>
      isDark ? Colors.white24 : const Color(0xFFE5E7EB);
  static Color get inputBorderFocused => const Color(0xFF2563EB);
  static Color get hintText =>
      isDark ? Colors.white38 : const Color(0xFF9CA3AF);
  static Color get label => isDark ? Colors.white : const Color(0xFF1E293B);
  static Color get primary => const Color(0xFF2563EB);
  static Color get error => const Color(0xFFEF4444);
  static Color get errorBg =>
      isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2);
  static Color get errorBorder =>
      isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA);
  static Color get prefixIcon => const Color(0xFF2563EB);
  static Color get suffixIcon =>
      isDark ? Colors.white54 : const Color(0xFF9CA3AF);
}
