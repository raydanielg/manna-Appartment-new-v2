import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            label: 'Phone Number',
            hint: '255700000001',
            controller: _phone,
            keyboardType: TextInputType.phone,
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Password',
            controller: _password,
            obscureText: _obscure,
            suffix: IconButton(
              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Sign In',
            isLoading: auth.isLoading,
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              await ref.read(authProvider.notifier).login(_phone.text.trim(), _password.text);
            },
          ),
          TextButton(
            onPressed: () => context.push('/auth/forgot-password'),
            child: const Text('Forgot Password?', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
