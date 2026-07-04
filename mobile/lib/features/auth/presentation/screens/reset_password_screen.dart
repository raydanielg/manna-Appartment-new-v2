import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  String _phone = '';

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_passwordController.text.isEmpty) {
      _showError('Enter a new password');
      return;
    }
    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      _showError('Passwords do not match');
      return;
    }
    final success = await ref.read(authProvider.notifier)
        .resetPassword(_phone, _passwordController.text);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully! Please login.'),
          backgroundColor: const Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/auth/login');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final query = GoRouterState.of(context).uri.queryParameters;
    _phone = query['phone'] ?? '';

    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),

                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.go('/auth/login'),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                ),

                // Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                  ),
                  child: const Icon(Icons.lock_person_rounded, size: 36, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'Reset Password',
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8)],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter your new password below',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                    shadows: [Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6)],
                  ),
                ),
                const SizedBox(height: 28),

                // Card
                AuthCard(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: AuthBackground.isDarkMode,
                    builder: (context, isDark, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('New Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AuthColors.label)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscure,
                            style: TextStyle(fontSize: 15, color: AuthColors.text),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: TextStyle(color: AuthColors.hintText),
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2563EB), size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AuthColors.suffixIcon),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                              filled: true,
                              fillColor: AuthColors.input,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AuthColors.inputBorder)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('Confirm Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AuthColors.label)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _confirmController,
                            obscureText: _obscureConfirm,
                            style: TextStyle(fontSize: 15, color: AuthColors.text),
                            onSubmitted: (_) => _resetPassword(),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: TextStyle(color: AuthColors.hintText),
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2563EB), size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AuthColors.suffixIcon),
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                              filled: true,
                              fillColor: AuthColors.input,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AuthColors.inputBorder)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                          if (authState.error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AuthColors.errorBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AuthColors.errorBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(authState.error!, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13))),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: authState.isLoading ? null : _resetPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: authState.isLoading
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_rounded, size: 20),
                                        SizedBox(width: 8),
                                        Text('Reset Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
