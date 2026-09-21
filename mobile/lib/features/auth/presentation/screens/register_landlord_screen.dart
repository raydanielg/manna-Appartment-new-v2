import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/theme_mode_button.dart';
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

  Widget _icon(BuildContext context, FTextFieldStyle style, Set<FTextFieldVariant> variants, List<List<dynamic>> icon) =>
      FTextField.prefixIconBuilder(context, style, variants, HugeIcon(icon: icon, size: null));

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
          child: Form(
            key: _formKey,
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
                  context.tr('create_account_title'),
                  style: typography.display.xl2.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('join_as_landlord'),
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

                FTextFormField(
                  control: .managed(controller: _nameController),
                  label: Text(context.tr('full_name')),
                  hint: context.tr('enter_full_name'),
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  prefixBuilder: (context, style, variants) =>
                      _icon(context, style, variants, HugeIcons.strokeRoundedUser),
                  validator: (v) => v == null || v.trim().isEmpty ? context.tr('name_required') : null,
                ),

                const SizedBox(height: 16),
                FTextFormField(
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
                        Text('+255', style: typography.body.sm.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return context.tr('phone_number_required');
                    if (!RegExp(r'^[0-9]{9}$').hasMatch(v.trim())) return context.tr('valid_9_digit_number');
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                FTextFormField(
                  control: .managed(controller: _businessController),
                  label: Text(context.tr('business_name')),
                  hint: context.tr('enter_business_name'),
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.organizationName],
                  prefixBuilder: (context, style, variants) =>
                      _icon(context, style, variants, HugeIcons.strokeRoundedBriefcase01),
                  validator: (v) => v == null || v.trim().isEmpty ? context.tr('business_name_required') : null,
                ),

                const SizedBox(height: 16),
                FTextFormField.password(
                  control: .managed(controller: _passwordController),
                  label: Text(context.tr('password')),
                  hint: context.tr('enter_password'),
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  prefixBuilder: (context, style, obscure, variants) =>
                      _icon(context, style, variants, HugeIcons.strokeRoundedLockPassword),
                  validator: (v) {
                    if (v == null || v.isEmpty) return context.tr('password_required');
                    if (v.length < 6) return context.tr('min_6_chars');
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                FTextFormField.password(
                  control: .managed(controller: _confirmController),
                  label: Text(context.tr('confirm_password')),
                  hint: context.tr('confirm_your_password'),
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  onSubmit: (_) => _register(),
                  prefixBuilder: (context, style, obscure, variants) =>
                      _icon(context, style, variants, HugeIcons.strokeRoundedLockPassword),
                  validator: (v) {
                    if (v == null || v.isEmpty) return context.tr('required_field');
                    if (v != _passwordController.text) return context.tr('passwords_not_match');
                    return null;
                  },
                ),

                const SizedBox(height: 28),
                PrimaryButton(
                  text: context.tr('create_account'),
                  isLoading: authState.isLoading,
                  onPressed: _register,
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedUser, size: null),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${context.tr('already_have_account')} ',
                      style: typography.body.xs.copyWith(color: colors.mutedForeground),
                    ),
                    FButton(
                      variant: .ghost,
                      size: .sm,
                      mainAxisSize: MainAxisSize.min,
                      onPress: () {
                        ref.read(authProvider.notifier).clearError();
                        context.go('/auth/login');
                      },
                      child: Text(context.tr('sign_in')),
                    ),
                  ],
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
