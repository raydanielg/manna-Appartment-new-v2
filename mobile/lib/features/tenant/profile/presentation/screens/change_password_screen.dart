import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../data/profile_repository.dart';
import '../../../../auth/providers/auth_provider.dart';

final _profileRepoProvider = Provider((ref) => ProfileRepository(ref.read(apiClientProvider)));

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final mustChange = ref.read(authProvider).user?.mustChangePassword == true;

    if (!mustChange && _currentController.text.isEmpty) {
      _showError('Please enter your current password');
      return;
    }
    if (_newController.text.length < 6) {
      _showError('New password must be at least 6 characters');
      return;
    }
    if (_newController.text != _confirmController.text) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(_profileRepoProvider);
      if (mustChange) {
        await repo.forceChangePassword(_newController.text);
      } else {
        await repo.changePassword(_currentController.text, _newController.text);
      }

      final user = ref.read(authProvider).user;
      if (user != null) {
        final updated = user.copyWith(mustChangePassword: false);
        ref.read(authProvider.notifier).state = ref.read(authProvider).copyWith(user: updated);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
        );
        context.go('/tenant/home');
      }
    } catch (e) {
      if (context.mounted) {
        _showError('Failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mustChange = ref.watch(authProvider).user?.mustChangePassword == true;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(mustChange ? 'Set New Password' : 'Change Password', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: mustChange ? null : IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mustChange) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.lock_outline, color: AppColors.warning, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Password Change Required', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                          const SizedBox(height: 2),
                          Text('Please set a new password to continue', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textLight)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              _buildLabel('Current Password'),
              const SizedBox(height: 8),
              _buildField(_currentController, 'Enter current password', _obscureCurrent, (v) {
                setState(() => _obscureCurrent = v);
              }),
              const SizedBox(height: 16),
            ],
            _buildLabel('New Password'),
            const SizedBox(height: 8),
            _buildField(_newController, 'Enter new password', _obscureNew, (v) {
              setState(() => _obscureNew = v);
            }),
            const SizedBox(height: 16),
            _buildLabel('Confirm Password'),
            const SizedBox(height: 8),
            _buildField(_confirmController, 'Confirm new password', _obscureConfirm, (v) {
              setState(() => _obscureConfirm = v);
            }),
            const SizedBox(height: 28),
            PrimaryButton(
              text: mustChange ? 'Set Password' : 'Update Password',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark));
  }

  Widget _buildField(TextEditingController controller, String hint, bool obscure, ValueChanged<bool> onToggle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.nunito(fontSize: 13, color: AppColors.textLight),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.textLight),
            onPressed: () => onToggle(!obscure),
          ),
        ),
      ),
    );
  }
}
