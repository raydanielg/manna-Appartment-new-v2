import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter your phone number to receive an OTP.'),
            const SizedBox(height: 24),
            const AppTextField(label: 'Phone Number', keyboardType: TextInputType.phone),
            const SizedBox(height: 24),
            PrimaryButton(text: 'Send OTP', onPressed: () => context.push('/auth/verify-otp')),
          ],
        ),
      ),
    );
  }
}
