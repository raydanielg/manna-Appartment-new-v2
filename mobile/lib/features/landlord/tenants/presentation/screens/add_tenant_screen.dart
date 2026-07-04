import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../providers/tenants_provider.dart';

class AddTenantScreen extends ConsumerStatefulWidget {
  const AddTenantScreen({super.key});

  @override
  ConsumerState<AddTenantScreen> createState() => _AddTenantScreenState();
}

class _AddTenantScreenState extends ConsumerState<AddTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(tenantsRepositoryProvider);
      await repo.createTenant({
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tenant added successfully'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: '), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
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
      appBar: AppBar(title: const Text('Add Tenant'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(label: 'Full Name', hint: 'e.g. John Doe', controller: _nameController, validator: (v) => v == null || v.isEmpty ? 'Name is required' : null),
              const SizedBox(height: 16),
              AppTextField(label: 'Phone', hint: 'e.g. +255712345678', controller: _phoneController, keyboardType: TextInputType.phone, validator: (v) => v == null || v.isEmpty ? 'Phone is required' : null),
              const SizedBox(height: 16),
              AppTextField(label: 'Email', hint: 'optional', controller: _emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 24),
              PrimaryButton(text: 'Save Tenant', isLoading: _isLoading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
