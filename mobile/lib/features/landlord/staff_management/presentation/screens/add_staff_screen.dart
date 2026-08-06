import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/staff_provider.dart';

class AddStaffScreen extends ConsumerStatefulWidget {
  const AddStaffScreen({super.key});
  @override
  ConsumerState<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends ConsumerState<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _role = 'manager';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(staffRepositoryProvider);
      await repo.createStaff({
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': _role,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('staff_added')), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('failed_msg').replaceAll('{0}', e.toString())), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
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
      appBar: AppBar(title: Text(context.tr('add_staff')), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(label: context.tr('full_name'), hint: context.tr('enter_full_name'), controller: _nameController, validator: (v) => v == null || v.isEmpty ? context.tr('required_field') : null),
              const SizedBox(height: 16),
              AppTextField(label: context.tr('phone'), hint: '+255...', controller: _phoneController, keyboardType: TextInputType.phone, validator: (v) => v == null || v.isEmpty ? context.tr('required_field') : null),
              const SizedBox(height: 16),
              Text(context.tr('role'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                items: [
                  DropdownMenuItem(value: 'manager', child: Text(context.tr('manager'))),
                  DropdownMenuItem(value: 'accountant', child: Text(context.tr('accountant'))),
                  DropdownMenuItem(value: 'agent', child: Text(context.tr('agent'))),
                  DropdownMenuItem(value: 'caretaker', child: Text(context.tr('caretaker'))),
                ],
                onChanged: (v) => setState(() => _role = v ?? 'manager'),
              ),
              const SizedBox(height: 24),
              PrimaryButton(text: context.tr('add_staff'), isLoading: _isLoading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
