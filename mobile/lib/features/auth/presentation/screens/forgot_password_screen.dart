import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || !RegExp(r'^[0-9]{9}$').hasMatch(phone)) {
      _showError('Enter a valid 9-digit phone number');
      return;
    }
    final fullPhone = '255$phone';
    final success =
        await ref.read(authProvider.notifier).forgotPassword(fullPhone);
    if (success && mounted) {
      context.go('/auth/verify-otp?phone=$fullPhone');
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
                  child: const Icon(Icons.lock_reset_rounded, size: 36, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'Forgot Password',
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8)],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter your phone number and we\'ll\nsend you a verification code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.5,
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
                          Text('Phone Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AuthColors.label)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            autofocus: true,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: AuthColors.text),
                            onSubmitted: (_) => _sendOtp(),
                            decoration: InputDecoration(
                              hintText: '7XX XXX XXX',
                              hintStyle: TextStyle(color: AuthColors.hintText, letterSpacing: 1.5),
                              prefixIcon: Container(
                                margin: const EdgeInsets.only(right: 6, left: 10, top: 12, bottom: 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('+255', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AuthColors.text)),
                                    const SizedBox(width: 4),
                                    Container(width: 1, height: 22, color: AuthColors.inputBorder),
                                  ],
                                ),
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
                              onPressed: authState.isLoading ? null : _sendOtp,
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
                                        Icon(Icons.send_rounded, size: 20),
                                        SizedBox(width: 8),
                                        Text('Send OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => context.go('/auth/login'),
                  child: Text(
                    'Back to Login',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      shadows: [Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6)],
                    ),
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
