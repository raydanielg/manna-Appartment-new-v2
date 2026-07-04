import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../providers/auth_provider.dart';

class RegisterLandlordScreen extends ConsumerStatefulWidget {
  const RegisterLandlordScreen({super.key});

  @override
  ConsumerState<RegisterLandlordScreen> createState() =>
      _RegisterLandlordScreenState();
}

class _RegisterLandlordScreenState extends ConsumerState<RegisterLandlordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _businessController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _businessController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final phone = '255${_phoneController.text.trim()}';
    final success = await ref.read(authProvider.notifier).register(
          name: _nameController.text.trim(),
          phone: phone,
          password: _passwordController.text,
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          businessName: _businessController.text.trim().isEmpty
              ? null
              : _businessController.text.trim(),
        );
    if (success && mounted) {
      context.go('/landlord/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
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

                  const SizedBox(height: 24),
                  Text(
                    'Create Account',
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Register as a landlord to get started',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                      shadows: [
                        Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Card
                  AuthCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      _buildLabel('Full Name'),
                      _buildField(
                        controller: _nameController,
                        hint: 'John Doe',
                        icon: Icons.person_outline,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Phone Number'),
                      _buildPhoneField(),
                      const SizedBox(height: 16),
                      _buildLabel('Email (optional)'),
                      _buildField(
                        controller: _emailController,
                        hint: 'you@example.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          if (!RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(v)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Business Name (optional)'),
                      _buildField(
                        controller: _businessController,
                        hint: 'Manna Properties Ltd',
                        icon: Icons.business_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Password'),
                      _buildPasswordField(
                        controller: _passwordController,
                        obscure: _obscure,
                        toggle: () => setState(() => _obscure = !_obscure),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password is required';
                          if (v.length < 6) return 'Min 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Confirm Password'),
                      _buildPasswordField(
                        controller: _confirmController,
                        obscure: _obscureConfirm,
                        toggle: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (v != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
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
                              Expanded(
                                child: Text(
                                  authState.error!,
                                  style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: authState.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_add_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Register',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                          shadows: [
                            Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/auth/login'),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Color(0xFF60A5FA),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ValueListenableBuilder<bool>(
        valueListenable: AuthBackground.isDarkMode,
        builder: (context, isDark, _) {
          return Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AuthColors.label,
            ),
          );
        },
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthBackground.isDarkMode,
      builder: (context, isDark, _) {
        return TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(fontSize: 15, color: AuthColors.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AuthColors.hintText),
            prefixIcon: Icon(icon, color: const Color(0xFF2563EB), size: 20),
            filled: true,
            fillColor: AuthColors.input,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AuthColors.inputBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        );
      },
    );
  }

  Widget _buildPhoneField() {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthBackground.isDarkMode,
      builder: (context, isDark, _) {
        return TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Phone number is required';
            if (!RegExp(r'^[0-9]{9}$').hasMatch(v.trim())) return 'Enter a valid 9-digit number';
            return null;
          },
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AuthColors.text),
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
        );
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback toggle,
    String? Function(String?)? validator,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthBackground.isDarkMode,
      builder: (context, isDark, _) {
        return TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: TextStyle(fontSize: 15, color: AuthColors.text),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(color: AuthColors.hintText),
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2563EB), size: 20),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AuthColors.suffixIcon),
              onPressed: toggle,
            ),
            filled: true,
            fillColor: AuthColors.input,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AuthColors.inputBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        );
      },
    );
  }
}
