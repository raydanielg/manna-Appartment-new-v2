import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../providers/contracts_provider.dart';

class CreateContractScreen extends ConsumerStatefulWidget {
  const CreateContractScreen({super.key});

  @override
  ConsumerState<CreateContractScreen> createState() => _CreateContractScreenState();
}

class _CreateContractScreenState extends ConsumerState<CreateContractScreen> {
  final _formKey = GlobalKey<FormState>();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _rentController = TextEditingController();
  final _depositController = TextEditingController();
  String? _tenantId;
  String? _unitId;
  bool _isLoading = false;

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(contractsRepositoryProvider);
      await repo.createContract({
        'tenant_id': _tenantId,
        'unit_id': _unitId,
        'start_date': _startDateController.text.trim(),
        'end_date': _endDateController.text.trim(),
        'monthly_rent': int.tryParse(_rentController.text) ?? 0,
        'deposit': int.tryParse(_depositController.text) ?? 0,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contract created successfully'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
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
      appBar: AppBar(title: const Text('New Contract'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(label: 'Tenant', hint: 'Select tenant', controller: TextEditingController(text: _tenantId ?? ''), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              AppTextField(label: 'Unit', hint: 'Select unit', controller: TextEditingController(text: _unitId ?? ''), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              AppTextField(label: 'Start Date', hint: 'YYYY-MM-DD', controller: _startDateController, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              AppTextField(label: 'End Date', hint: 'YYYY-MM-DD', controller: _endDateController, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              AppTextField(label: 'Monthly Rent (TZS)', controller: _rentController, keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              AppTextField(label: 'Deposit (TZS)', controller: _depositController, keyboardType: TextInputType.number),
              const SizedBox(height: 24),
              PrimaryButton(text: 'Create Contract', isLoading: _isLoading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
