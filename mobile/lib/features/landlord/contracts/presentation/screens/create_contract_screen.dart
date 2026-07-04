import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/contracts_provider.dart';
import '../../../tenants/providers/tenants_provider.dart';
import '../../../units/providers/units_provider.dart';

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
  String _contractType = 'digital';
  bool _isLoading = false;

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) controller.text = DateFormat('yyyy-MM-dd').format(picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tenantId == null || _unitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select tenant and unit'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(contractsRepositoryProvider);
      await repo.createContract({
        'tenant_id': _tenantId,
        'unit_id': _unitId,
        'start_date': _startDateController.text.trim(),
        'end_date': _endDateController.text.trim(),
        'rent_amount': double.tryParse(_rentController.text) ?? 0,
        'deposit_amount': double.tryParse(_depositController.text) ?? 0,
        'contract_type': _contractType,
      });
      ref.invalidate(contractsListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contract created successfully'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tenantsAsync = ref.watch(tenantsListProvider);
    final unitsAsync = ref.watch(unitsListProvider(null));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('New Contract', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contract Type', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildTypeChip('Digital', 'digital')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTypeChip('Manual', 'manual')),
                ],
              ),
              const SizedBox(height: 16),
              _buildDropdown('Tenant', tenantsAsync, (t) => _tenantId = t),
              const SizedBox(height: 16),
              _buildDropdown('Unit', unitsAsync, (u) => _unitId = u),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Start Date',
                hint: 'YYYY-MM-DD',
                controller: _startDateController,
                readOnly: true,
                onTap: () => _pickDate(_startDateController),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'End Date',
                hint: 'YYYY-MM-DD',
                controller: _endDateController,
                readOnly: true,
                onTap: () => _pickDate(_endDateController),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(label: 'Monthly Rent (TZS)', controller: _rentController, keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              AppTextField(label: 'Deposit (TZS)', controller: _depositController, keyboardType: TextInputType.number),
              const SizedBox(height: 24),
              PrimaryButton(text: 'Create Contract', isLoading: _isLoading, onPressed: _submit),
              if (_contractType == 'manual') ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      try {
                        final path = await ref.read(contractsRepositoryProvider).downloadTemplate();
                        await OpenFilex.open(path);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Download failed: $e'), backgroundColor: AppColors.error),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.download),
                    label: Text('Download Word Template', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, String value) {
    final isSelected = _contractType == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ChoiceChip(
      label: Text(label, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textLight))),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      onSelected: (_) => setState(() => _contractType = value),
    );
  }

  Widget _buildDropdown(String label, AsyncValue<List<dynamic>> asyncValue, ValueChanged<String?> onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
        const SizedBox(height: 8),
        asyncValue.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => Text('Failed to load $label', style: GoogleFonts.nunito(color: Colors.red)),
          data: (items) => DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            hint: Text('Select $label', style: GoogleFonts.nunito(fontSize: 14)),
            items: items.map<DropdownMenuItem<String>>((item) {
              final name = item['full_name'] ?? item['name'] ?? item['unit_number'] ?? 'Item';
              return DropdownMenuItem(value: item['id'].toString(), child: Text(name, style: GoogleFonts.nunito(fontSize: 14)));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
