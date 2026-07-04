import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';

class RegisterLandlordScreen extends ConsumerStatefulWidget {
  const RegisterLandlordScreen({super.key});

  @override
  ConsumerState<RegisterLandlordScreen> createState() => _RegisterLandlordScreenState();
}

class _RegisterLandlordScreenState extends ConsumerState<RegisterLandlordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Register as Landlord'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create your landlord account',
                  style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 24),
                AppTextField(label: 'Full Name', controller: _nameController, validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 16),
                AppTextField(label: 'Phone Number', controller: _phoneController, keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 16),
                AppTextField(label: 'Business Name (optional)', controller: _businessController),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: _obscure,
                  suffix: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 24),
                PrimaryButton(text: 'Register', onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: call API
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
