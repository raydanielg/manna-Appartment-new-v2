import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
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
  String _contractType = 'digital';
  final _termsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    _termsController.dispose();
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
    return userData?['full_name'] ?? t['full_name'] ?? t['name'] ?? context.tr('unknown');
  }

  String _getTenantPhone(Map<String, dynamic> t) {
    final userData = t['user'] as Map<String, dynamic>?;
    return userData?['phone'] ?? t['phone'] ?? context.tr('no_phone');
  }

  String _getUnitName(Map<String, dynamic> u) {
    return u['name'] ?? u['unit_number'] ?? context.tr('unit');
  }

  String _formatRent(dynamic rent) {
    final n = rent is num ? rent.toDouble() : (double.tryParse(rent?.toString() ?? '0') ?? 0);
    return NumberFormat('#,###').format(n);
  }

  void _showContractCreatedDialog(BuildContext context, WidgetRef ref, Map<String, dynamic>? tenant, String? tenantId) {
    final tenantName = tenant != null ? _getTenantName(tenant) : '';
    final tenantPhone = tenant != null ? _getTenantPhone(tenant) : '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(context.tr('contract_created'), style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('contract_created_msg'), style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textLight)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: AppColors.info),
                      const SizedBox(width: 8),
                      Text(context.tr('tenant_credentials'), style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.info)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (tenantName.isNotEmpty)
                    Text('${context.tr('name')}: $tenantName', style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textDark)),
                  if (tenantPhone.isNotEmpty)
                    Text('${context.tr('phone')}: $tenantPhone', style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Text(context.tr('credentials_sms_hint'), style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textLight, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.pop();
            },
            child: Text(context.tr('close')),
          ),
          if (tenantId != null && tenantId.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await ref.read(tenantsRepositoryProvider).sendCredentials(tenantId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr('credentials_sent_success')),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr('failed_msg').replaceAll('{0}', e.toString())),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
                if (context.mounted) context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.send, size: 16),
              label: Text(context.tr('send_credentials'), style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tenantId == null || _unitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('please_select_tenant_unit')), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
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
        if (_contractType == 'manual') 'template_content': _termsController.text.trim(),
      });
      ref.invalidate(contractsListProvider);
      if (mounted) {
        _showContractCreatedDialog(context, ref, _selectedTenant, _tenantId);
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
    final tenantsAsync = ref.watch(tenantsListProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(context.tr('new_contract'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
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
              _buildSectionLabel(context.tr('contract_type')),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeCard(
                      Icons.auto_awesome_outlined,
                      context.tr('digital'),
                      context.tr('auto_generated_terms'),
                      'digital',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeCard(
                      Icons.edit_note_outlined,
                      context.tr('manual'),
                      context.tr('write_own_terms'),
                      'manual',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionLabel(context.tr('select_tenant_label')),
              const SizedBox(height: 8),
              tenantsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => Text(context.tr('failed_load_tenants'), style: GoogleFonts.nunito(color: AppColors.error)),
                data: (tenants) => DropdownButtonFormField<String>(
                  value: _tenantId,
                  isExpanded: true,
                  decoration: _dropdownDecoration(context.tr('select_tenant')),
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
                          context.tr('tenant_no_unit'),
                          style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textLight),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _buildSectionLabel(context.tr('contract_dates')),
              const SizedBox(height: 12),
              AppTextField(
                label: context.tr('start_date'),
                hint: 'YYYY-MM-DD',
                controller: _startDateController,
                readOnly: true,
                onTap: () => _pickDate(_startDateController),
                validator: (v) => v == null || v.isEmpty ? context.tr('required') : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: context.tr('end_date'),
                hint: 'YYYY-MM-DD',
                controller: _endDateController,
                readOnly: true,
                onTap: () => _pickDate(_endDateController),
                validator: (v) => v == null || v.isEmpty ? context.tr('required') : null,
              ),
              const SizedBox(height: 24),
              _buildSectionLabel(context.tr('payment_details')),
              const SizedBox(height: 12),
              AppTextField(label: context.tr('monthly_rent_tzs'), controller: _rentController, keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? context.tr('required') : null),
              const SizedBox(height: 16),
              AppTextField(label: context.tr('deposit_tzs'), controller: _depositController, keyboardType: TextInputType.number),
              if (_contractType == 'manual') ...[
                const SizedBox(height: 24),
                _buildSectionLabel(context.tr('contract_terms')),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _termsController,
                    maxLines: 12,
                    minLines: 8,
                    style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textDark, height: 1.6),
                    decoration: InputDecoration(
                      hintText: context.tr('contract_terms_hint'),
                      hintStyle: GoogleFonts.nunito(fontSize: 13, color: AppColors.textLight, height: 1.6),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              PrimaryButton(text: context.tr('create_contract'), isLoading: _isLoading, onPressed: _submit),
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

  Widget _buildTypeCard(IconData icon, String title, String subtitle, String value) {
    final isSelected = _contractType == value;
    return GestureDetector(
      onTap: () => setState(() => _contractType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textLight, size: 20),
            ),
            const SizedBox(height: 10),
            Text(title, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: isSelected ? AppColors.primary : AppColors.textDark)),
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textLight), textAlign: TextAlign.center),
          ],
        ),
      ),
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
                  Text(context.tr('unit'), style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textLight)),
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
                      Text('TZS $rent/${context.tr('month')}', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      const Spacer(),
                      Icon(isOccupied ? Icons.check_circle_outline : Icons.highlight_off, size: 14, color: isOccupied ? AppColors.success : AppColors.warning),
                      const SizedBox(width: 4),
                      Text(isOccupied ? context.tr('occupied') : context.tr('vacant'), style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: isOccupied ? AppColors.success : AppColors.warning)),
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
