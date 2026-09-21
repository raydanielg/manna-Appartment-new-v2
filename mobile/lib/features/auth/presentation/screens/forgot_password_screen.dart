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
      _showError(context.tr('valid_9_digit_phone'));
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
    AppToast.error(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final colors = context.theme.colors;
    final typography = context.theme.typography;

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
                context.tr('forgot_password_title'),
                style: typography.display.xl2.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('forgot_password_subtitle'),
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

              FTextField(
                control: .managed(controller: _phoneController),
                label: Text(context.tr('phone_number')),
                hint: '7XX XXX XXX',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.telephoneNumber],
                onSubmit: (_) => _sendOtp(),
                prefixBuilder: (context, style, variants) => FTextField.prefixIconBuilder(
                  context,
                  style,
                  variants,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const HugeIcon(icon: HugeIcons.strokeRoundedSmartPhone01, size: null),
                      const SizedBox(width: 6),
                      Text(
                        '+255',
                        style: typography.body.sm.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),
              PrimaryButton(
                text: context.tr('send_code'),
                isLoading: authState.isLoading,
                onPressed: _sendOtp,
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedMailSend01, size: null),
              ),

              const SizedBox(height: 20),
              Center(
                child: FButton(
                  variant: .ghost,
                  size: .sm,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () {
                    ref.read(authProvider.notifier).clearError();
                    context.go('/auth/login');
                  },
                  child: Text(context.tr('back_to_sign_in')),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
