import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/theme_mode_button.dart';
import '../../providers/auth_provider.dart';

import 'package:manna_apartment/core/utils/app_toast.dart';
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String _phone = '';

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_passwordController.text.isEmpty) {
      _showError(context.tr('enter_new_password_first'));
      return;
    }
    if (_passwordController.text.length < 6) {
      _showError(context.tr('password_min_6'));
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      _showError(context.tr('passwords_not_match'));
      return;
    }
    final success = await ref.read(authProvider.notifier)
        .resetPassword(_phone, _passwordController.text);
    if (success && mounted) {
      AppToast.success(context, context.tr('password_reset_success'));
      context.go('/auth/login');
    }
  }

  void _showError(String msg) {
    AppToast.error(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final query = GoRouterState.of(context).uri.queryParameters;
    _phone = query['phone'] ?? '';

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Back button + theme toggle
              Row(
                children: [
                  FButton.icon(
                    variant: .outline,
                    size: .sm,
                    onPress: () {
                      ref.read(authProvider.notifier).clearError();
                      context.go('/auth/login');
                    },
                    child: context.theme.icons.arrowLeft(context),
                  ),
                  const Spacer(),
                  const ThemeModeButton(),
                ],
              ),

              const SizedBox(height: 32),
              Text(
                context.tr('reset_password_title'),
                style: typography.display.xl2.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('reset_password_subtitle'),
                style: typography.body.sm.copyWith(color: colors.mutedForeground),
              ),
              const SizedBox(height: 28),

              if (authState.error != null) ...[
                FAlert(
                  variant: .destructive,
                  title: Row(
                    children: [
                      Expanded(child: Text(authState.error!)),
                      GestureDetector(
                        onTap: () => ref.read(authProvider.notifier).clearError(),
                        child: context.theme.icons.x(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              FTextField.password(
                control: .managed(controller: _passwordController),
                label: Text(context.tr('new_password')),
                hint: context.tr('enter_new_password'),
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                prefixBuilder: (context, style, obscure, variants) => FTextField.prefixIconBuilder(
                  context,
                  style,
                  variants,
                  const HugeIcon(icon: HugeIcons.strokeRoundedLockPassword, size: null),
                ),
              ),

              const SizedBox(height: 16),
              FTextField.password(
                control: .managed(controller: _confirmController),
                label: Text(context.tr('confirm_password')),
                hint: context.tr('confirm_new_password'),
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onSubmit: (_) => _resetPassword(),
                prefixBuilder: (context, style, obscure, variants) => FTextField.prefixIconBuilder(
                  context,
                  style,
                  variants,
                  const HugeIcon(icon: HugeIcons.strokeRoundedLockPassword, size: null),
                ),
              ),

              const SizedBox(height: 28),
              PrimaryButton(
                text: context.tr('update_password'),
                isLoading: authState.isLoading,
                onPressed: _resetPassword,
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedShieldUser, size: null),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
