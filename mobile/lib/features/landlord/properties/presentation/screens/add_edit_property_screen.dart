import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../providers/properties_provider.dart';

class AddEditPropertyScreen extends ConsumerStatefulWidget {
  const AddEditPropertyScreen({super.key});

  @override
  ConsumerState<AddEditPropertyScreen> createState() => _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends ConsumerState<AddEditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _type = 'apartment';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(propertiesRepositoryProvider);
      final data = {
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'type': _type,
        'description': _descriptionController.text.trim(),
      };
      await repo.createProperty(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Property created successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: '),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
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
        title: const Text('Add Property'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Property Name',
                hint: 'e.g. Manna Apartments',
                controller: _nameController,
                validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Address',
                hint: 'e.g. Kijitonyama, Dar es Salaam',
                controller: _addressController,
                validator: (v) => v == null || v.isEmpty ? 'Address is required' : null,
              ),
              const SizedBox(height: 16),
              Text('Property Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: const [
                  DropdownMenuItem(value: 'apartment', child: Text('Apartment')),
                  DropdownMenuItem(value: 'house', child: Text('House')),
                  DropdownMenuItem(value: 'commercial', child: Text('Commercial')),
                  DropdownMenuItem(value: 'mixed', child: Text('Mixed Use')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'apartment'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Description',
                hint: 'Optional description',
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Save Property',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
