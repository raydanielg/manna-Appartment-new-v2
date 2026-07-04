import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const AppTextField(label: 'New Password', obscureText: true),
            const SizedBox(height: 16),
            const AppTextField(label: 'Confirm Password', obscureText: true),
            const SizedBox(height: 24),
            PrimaryButton(text: 'Reset Password', onPressed: () => context.go('/auth/login')),
          ],
        ),
      ),
    );
  }
}
