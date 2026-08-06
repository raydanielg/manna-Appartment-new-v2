import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/contracts_provider.dart';
import '../../../tenants/providers/tenants_provider.dart';

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
  Map<String, dynamic>? _selectedTenant;
  String? _unitId;
  Map<String, dynamic>? _selectedUnit;
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

  String _getTenantName(Map<String, dynamic> t) {
    final userData = t['user'] as Map<String, dynamic>?;
    return userData?['full_name'] ?? t['full_name'] ?? t['name'] ?? 'Unknown';
  }

  String _getTenantPhone(Map<String, dynamic> t) {
    final userData = t['user'] as Map<String, dynamic>?;
    return userData?['phone'] ?? t['phone'] ?? 'No phone';
  }

  String _getUnitName(Map<String, dynamic> u) {
    return u['name'] ?? u['unit_number'] ?? 'Unit';
  }

  String _formatRent(dynamic rent) {
    final n = rent is num ? rent.toDouble() : (double.tryParse(rent?.toString() ?? '0') ?? 0);
    return NumberFormat('#,###').format(n);
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
        'contract_type': 'digital',
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
    final tenantsAsync = ref.watch(tenantsListProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
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
              _buildSectionLabel('Select Tenant'),
              const SizedBox(height: 8),
              tenantsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => Text('Failed to load tenants', style: GoogleFonts.nunito(color: AppColors.error)),
                data: (tenants) => DropdownButtonFormField<String>(
                  value: _tenantId,
                  isExpanded: true,
                  decoration: _dropdownDecoration('Select tenant'),
                  items: tenants.map<DropdownMenuItem<String>>((t) {
                    final name = _getTenantName(t);
                    return DropdownMenuItem(value: t['id'].toString(), child: Text(name, style: GoogleFonts.nunito(fontSize: 14)));
                  }).toList(),
                  onChanged: (v) => setState(() {
                    _tenantId = v;
                    _selectedTenant = tenants.firstWhere((t) => t['id'].toString() == v, orElse: () => {});
                    final unit = _selectedTenant?['unit'] as Map<String, dynamic>?;
                    if (unit != null && unit.isNotEmpty) {
                      _selectedUnit = unit;
                      _unitId = unit['id']?.toString();
                      if (unit['rent_amount'] != null && _rentController.text.isEmpty) {
                        _rentController.text = unit['rent_amount'].toString();
                      } else if (unit['monthly_rent'] != null && _rentController.text.isEmpty) {
                        _rentController.text = unit['monthly_rent'].toString();
                      }
                    } else {
                      _selectedUnit = null;
                      _unitId = null;
                    }
                  }),
                ),
              ),
              if (_selectedTenant != null && _selectedTenant!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildTenantDetailsCard(_selectedTenant!),
              ],
              if (_selectedTenant != null && _selectedTenant!.isNotEmpty && (_selectedUnit == null || _selectedUnit!.isEmpty)) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This tenant has no unit assigned.',
                          style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textLight),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _buildSectionLabel('Contract Dates'),
              const SizedBox(height: 12),
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
              const SizedBox(height: 24),
              _buildSectionLabel('Payment Details'),
              const SizedBox(height: 12),
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

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
    );
  }

  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintText: hint,
      hintStyle: GoogleFonts.nunito(fontSize: 14, color: AppColors.textLight),
    );
  }

  Widget _buildTenantDetailsCard(Map<String, dynamic> tenant) {
    final name = _getTenantName(tenant);
    final phone = _getTenantPhone(tenant);
    final email = (tenant['email'] ?? tenant['user']?['email'] ?? '').toString();
    final unit = tenant['unit'] as Map<String, dynamic>?;
    final unitName = unit?['name'] ?? unit?['unit_number'] ?? '';
    final propertyName = unit?['property']?['name'] ?? unit?['property_name'] ?? '';
    final rent = _formatRent(unit?['rent_amount'] ?? unit?['monthly_rent'] ?? 0);
    final status = (unit?['status'] ?? 'vacant').toString();
    final isOccupied = status == 'occupied';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_outline, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(name, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildDetailRow(Icons.phone_outlined, phone),
          if (email.isNotEmpty) _buildDetailRow(Icons.email_outlined, email),
          if (unitName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Unit', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textLight)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.apartment_outlined, color: AppColors.info, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(unitName, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                            if (propertyName.isNotEmpty)
                              Text(propertyName, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textLight)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.payments_outlined, size: 14, color: AppColors.textLight),
                      const SizedBox(width: 6),
                      Text('TZS $rent/month', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      const Spacer(),
                      Icon(isOccupied ? Icons.check_circle_outline : Icons.highlight_off, size: 14, color: isOccupied ? AppColors.success : AppColors.warning),
                      const SizedBox(width: 4),
                      Text(isOccupied ? 'Occupied' : 'Vacant', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: isOccupied ? AppColors.success : AppColors.warning)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textLight),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textLight)),
          ),
        ],
      ),
    );
  }
}
