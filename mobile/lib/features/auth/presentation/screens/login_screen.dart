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
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_phoneController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _showError(context.tr('enter_phone_password'));
      return;
    }
    var phone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (phone.startsWith('0')) {
      phone = '255${phone.substring(1)}';
    } else if (phone.startsWith('255')) {
      // already correct
    } else if (phone.length == 9) {
      phone = '255$phone';
    }
    final password = _passwordController.text;
    await ref.read(authProvider.notifier).login(phone, password);
  }

  void _showError(String msg) {
    AppToast.error(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final radii = context.theme.style.borderRadius;

    ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        if (next.user?.mustChangePassword == true) {
          context.go('/tenant/profile/change-password');
          return;
        }
        final route = switch (next.role) {
          'super_admin' => '/admin/landlords',
          'landlord' => '/landlord/home',
          _ => '/tenant/home',
        };
        context.go(route);
      }
    });

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerRight,
                child: ThemeModeButton(),
              ),
              const SizedBox(height: 24),

              // Logo
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.secondary,
                    borderRadius: radii.xl,
                    border: Border.all(color: colors.border),
                  ),
                  child: ClipRRect(
                    borderRadius: radii.lg,
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Text(
                context.tr('sign_in_title'),
                style: typography.display.xl2.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('sign_in_subtitle'),
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

              // Phone field
              FTextField(
                control: .managed(controller: _phoneController),
                label: Text(context.tr('phone_number')),
                hint: '7XX XXX XXX',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
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
              const SizedBox(height: 18),

              // Password field — Forui provides the show/hide eye toggle via theme icons.
              FTextField.password(
                control: .managed(controller: _passwordController),
                label: Text(context.tr('password')),
                hint: context.tr('enter_password'),
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onSubmit: (_) => _login(),
                prefixBuilder: (context, style, obscure, variants) => FTextField.prefixIconBuilder(
                  context,
                  style,
                  variants,
                  const HugeIcon(icon: HugeIcons.strokeRoundedLockPassword, size: null),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: FButton(
                  variant: .ghost,
                  size: .sm,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () {
                    ref.read(authProvider.notifier).clearError();
                    context.go('/auth/forgot-password');
                  },
                  child: Text(context.tr('forgot_password')),
                ),
              ),

              const SizedBox(height: 16),

              PrimaryButton(
                text: context.tr('sign_in'),
                isLoading: authState.isLoading,
                onPressed: _login,
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedLogin03, size: null),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${context.tr('dont_have_account')} ',
                    style: typography.body.xs.copyWith(color: colors.mutedForeground),
                  ),
                  FButton(
                    variant: .ghost,
                    size: .sm,
                    mainAxisSize: MainAxisSize.min,
                    onPress: () {
                      ref.read(authProvider.notifier).clearError();
                      context.go('/auth/register-landlord');
                    },
                    child: Text(context.tr('create_account')),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
