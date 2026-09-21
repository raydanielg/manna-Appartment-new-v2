import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/theme_mode_button.dart';
import '../../providers/auth_provider.dart';

import 'package:manna_apartment/core/utils/app_toast.dart';
class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  String _otp = '';
  String _phone = '';

  Future<void> _verify() async {
    if (_otp.length != 6) {
      _showError(context.tr('enter_complete_6_digit'));
      return;
    }
    final success =
        await ref.read(authProvider.notifier).verifyOtp(_phone, _otp);
    if (success && mounted) {
      context.go('/auth/reset-password?phone=$_phone');
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
                      context.go('/auth/forgot-password');
                    },
                    child: context.theme.icons.arrowLeft(context),
                  ),
                  const Spacer(),
                  const ThemeModeButton(),
                ],
              ),

              const SizedBox(height: 32),
              Text(
                context.tr('verify_otp_title'),
                style: typography.display.xl2.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                _phone.isNotEmpty
                    ? '${context.tr('enter_6_digit_code_to')} +$_phone'
                    : context.tr('enter_6_digit_code'),
                style: typography.body.sm.copyWith(color: colors.mutedForeground),
              ),
              const SizedBox(height: 36),

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

              Center(
                child: FOtpField(
                  control: .managed(
                    onChange: (value) {
                      _otp = value.text;
                      if (value.text.length == 6) {
                        _verify();
                      }
                    },
                  ),
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  onSubmit: (_) => _verify(),
                ),
              ),

              const SizedBox(height: 32),
              PrimaryButton(
                text: context.tr('verify_code'),
                isLoading: authState.isLoading,
                onPressed: _verify,
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${context.tr('didnt_receive_code')} ',
                    style: typography.body.xs.copyWith(color: colors.mutedForeground),
                  ),
                  FButton(
                    variant: .ghost,
                    size: .sm,
                    mainAxisSize: MainAxisSize.min,
                    onPress: () {
                      ref.read(authProvider.notifier).clearError();
                      context.go('/auth/forgot-password');
                    },
                    child: Text(context.tr('resend')),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
