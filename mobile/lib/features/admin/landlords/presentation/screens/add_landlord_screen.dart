import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/admin_landlords_provider.dart';

class AddLandlordScreen extends ConsumerStatefulWidget {
  const AddLandlordScreen({super.key});

  @override
  ConsumerState<AddLandlordScreen> createState() => _AddLandlordScreenState();
}

class _AddLandlordScreenState extends ConsumerState<AddLandlordScreen> {
  final _nameController = TextEditingController();
  final _businessController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _businessController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _passwordController.text.isEmpty || _businessController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(adminLandlordsRepositoryProvider);
      await repo.createLandlord({
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'business_name': _businessController.text.trim(),
        'password': _passwordController.text,
      });
      ref.invalidate(adminLandlordsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Landlord created'), backgroundColor: AppColors.success),
        );
        if (context.canPop()) context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Add Owner / Landlord', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AppTextField(label: 'Full Name', controller: _nameController),
            const SizedBox(height: 16),
            AppTextField(label: 'Business Name', controller: _businessController),
            const SizedBox(height: 16),
            AppTextField(label: 'Phone Number', controller: _phoneController, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            AppTextField(label: 'Email (optional)', controller: _emailController, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            AppTextField(label: 'Password', controller: _passwordController, obscureText: true),
            const SizedBox(height: 24),
            PrimaryButton(text: 'Create Landlord', isLoading: _isLoading, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
