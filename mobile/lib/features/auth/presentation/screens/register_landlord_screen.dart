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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Back button
                IconButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).clearError();
                    context.go('/auth/login');
                  },
                  icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF111827), size: 22),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  constraints: const BoxConstraints(),
                ),

                const SizedBox(height: 32),
                Text(
                  'Create Account',
                  style: GoogleFonts.nunito(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join Manna Apartment as a landlord.',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 32),

                if (authState.error != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: GoogleFonts.nunito(color: const Color(0xFFB91C1C), fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => ref.read(authProvider.notifier).clearError(),
                          child: const Icon(Icons.close_rounded, color: Color(0xFFEF4444), size: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                _buildLabel('Full Name'),
                _buildField(
                  controller: _nameController,
                  hint: 'Enter your full name',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                
                const SizedBox(height: 16),
                _buildLabel('Phone Number'),
                _buildPhoneField(),

                const SizedBox(height: 16),
                _buildLabel('Business Name'),
                _buildField(
                  controller: _businessController,
                  hint: 'Enter your business name',
                  icon: Icons.business_center_outlined,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Business name is required' : null,
                ),

                const SizedBox(height: 16),
                _buildLabel('Password'),
                _buildPasswordField(
                  controller: _passwordController,
                  obscure: _obscure,
                  hint: 'Create a password',
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
                  hint: 'Confirm your password',
                  toggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AuthColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Create Account',
                            style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.nunito(color: const Color(0xFF6B7280), fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(authProvider.notifier).clearError();
                          context.go('/auth/login');
                        },
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.nunito(
                            color: AuthColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF374151),
        ),
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.nunito(fontSize: 15, color: const Color(0xFF111827), fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(color: const Color(0xFF9CA3AF), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 18),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AuthColors.primary, width: 1.5)),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Phone number is required';
        if (!RegExp(r'^[0-9]{9}$').hasMatch(v.trim())) return 'Enter a valid 9-digit number';
        return null;
      },
      style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF111827)),
      decoration: InputDecoration(
        hintText: '7XX XXX XXX',
        hintStyle: GoogleFonts.nunito(color: const Color(0xFF9CA3AF), fontSize: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Text(
            '+255',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF374151),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AuthColors.primary, width: 1.5)),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscure,
    required String hint,
    required VoidCallback toggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: GoogleFonts.nunito(fontSize: 15, color: const Color(0xFF111827), fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(color: const Color(0xFF9CA3AF), fontSize: 14),
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF6B7280), size: 18),
        suffixIcon: TextButton(
          onPressed: toggle,
          child: Text(
            obscure ? 'Show' : 'Hide',
            style: GoogleFonts.nunito(
              color: AuthColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AuthColors.primary, width: 1.5)),
      ),
    );
  }
}
