import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/units_provider.dart';

class AddEditUnitScreen extends ConsumerStatefulWidget {
  const AddEditUnitScreen({super.key});

  @override
  ConsumerState<AddEditUnitScreen> createState() => _AddEditUnitScreenState();
}

class _AddEditUnitScreenState extends ConsumerState<AddEditUnitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rentController = TextEditingController();
  final _sizeController = TextEditingController();
  String _type = 'bedsitter';
  int _bedrooms = 0;
  int _bathrooms = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _rentController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(unitsRepositoryProvider);
      await repo.createUnit({
        'name': _nameController.text.trim(),
        'monthly_rent': int.tryParse(_rentController.text) ?? 0,
        'size': _sizeController.text.trim(),
        'type': _type,
        'bedrooms': _bedrooms,
        'bathrooms': _bathrooms,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unit created successfully'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
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
      appBar: AppBar(title: const Text('Add Unit'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(label: 'Unit Name/Number', hint: 'e.g. A-101', controller: _nameController, validator: (v) => v == null || v.isEmpty ? 'Name is required' : null),
              const SizedBox(height: 16),
              AppTextField(label: 'Monthly Rent (TZS)', hint: 'e.g. 350000', controller: _rentController, keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? 'Rent is required' : null),
              const SizedBox(height: 16),
              AppTextField(label: 'Size (sqm)', hint: 'optional', controller: _sizeController, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              Text('Unit Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                items: const [
                  DropdownMenuItem(value: 'bedsitter', child: Text('Bedsitter')),
                  DropdownMenuItem(value: '1br', child: Text('1 Bedroom')),
                  DropdownMenuItem(value: '2br', child: Text('2 Bedroom')),
                  DropdownMenuItem(value: '3br', child: Text('3 Bedroom')),
                  DropdownMenuItem(value: 'studio', child: Text('Studio')),
                  DropdownMenuItem(value: 'shop', child: Text('Shop')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'bedsitter'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildCounter(context, 'Bedrooms', _bedrooms, (v) => setState(() => _bedrooms = v))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCounter(context, 'Bathrooms', _bathrooms, (v) => setState(() => _bathrooms = v))),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(text: 'Save Unit', isLoading: _isLoading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounter(BuildContext context, String label, int value, ValueChanged<int> onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppColors.textDark)),
            Row(
              children: [
                IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: value > 0 ? () => onChanged(value - 1) : null),
                Text('', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => onChanged(value + 1)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
