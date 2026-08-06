import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/tenants_provider.dart';
import '../../../properties/providers/properties_provider.dart';
import '../../../units/providers/units_provider.dart';

class AddTenantScreen extends ConsumerStatefulWidget {
  final String? tenantId;
  const AddTenantScreen({super.key, this.tenantId});

  @override
  ConsumerState<AddTenantScreen> createState() => _AddTenantScreenState();
}

class _AddTenantScreenState extends ConsumerState<AddTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _emergencyController = TextEditingController();
  String? _selectedPropertyId;
  String? _selectedUnitId;
  DateTime _moveInDate = DateTime.now();
  bool _isLoading = false;
  bool _isEditMode = false;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.tenantId != null && widget.tenantId!.isNotEmpty;
    if (_isEditMode) {
      _loadTenantData();
    }
  }

  Future<void> _loadTenantData() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(tenantsRepositoryProvider);
      final tenant = await repo.getTenant(widget.tenantId!);
      _nameController.text = tenant['full_name'] ?? tenant['user']?['full_name'] ?? '';
      _phoneController.text = tenant['phone'] ?? tenant['user']?['phone'] ?? '';
      _emailController.text = tenant['email'] ?? tenant['user']?['email'] ?? '';
      _emergencyController.text = tenant['emergency_contact'] ?? '';
      _selectedUnitId = tenant['unit']?['id']?.toString();
      _selectedPropertyId = tenant['unit']?['property_id']?.toString();
      if (tenant['moved_in_date'] != null) {
        _moveInDate = DateTime.tryParse(tenant['moved_in_date'].toString()) ?? DateTime.now();
      }
      if (mounted) setState(() {
        _isDataLoaded = true;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.tr('failed_load_tenant')}: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  Future<void> _pickMoveInDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _moveInDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _moveInDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPropertyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('please_select_property'), style: const TextStyle(color: Colors.white)), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_selectedUnitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('please_select_unit'), style: const TextStyle(color: Colors.white)), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(tenantsRepositoryProvider);
      final data = {
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'emergency_contact': _emergencyController.text.trim(),
        'unit_id': _selectedUnitId,
        'moved_in_date': DateFormat('yyyy-MM-dd').format(_moveInDate),
      };
      if (_isEditMode) {
        await repo.updateTenant(widget.tenantId!, data);
        ref.invalidate(tenantsListProvider);
        ref.invalidate(tenantDetailProvider(widget.tenantId!));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('tenant_updated_success')), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
          );
          context.pop();
        }
      } else {
        await repo.createTenant(data);
        ref.invalidate(tenantsListProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('tenant_added_sms')), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
          );
          context.pop();
        }
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
    final propertiesAsync = ref.watch(propertiesListProvider);
    final unitsAsync = ref.watch(unitsListProvider(_selectedPropertyId));

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(_isEditMode ? context.tr('edit_tenant') : context.tr('add_tenant'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
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
              if (_isLoading && _isEditMode && !_isDataLoaded) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ] else ...[
                _buildSectionLabel(context.tr('property')),
                const SizedBox(height: 8),
                propertiesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => Text(context.tr('failed_load_properties'), style: GoogleFonts.nunito(color: AppColors.error)),
                  data: (properties) => DropdownButtonFormField<String>(
                    value: _selectedPropertyId,
                    isExpanded: true,
                    decoration: _dropdownDecoration(context.tr('select_property')),
                    items: properties.map<DropdownMenuItem<String>>((p) {
                      return DropdownMenuItem(value: p.id, child: Text(p.name, style: GoogleFonts.nunito(fontSize: 14)));
                    }).toList(),
                    onChanged: (v) => setState(() {
                      _selectedPropertyId = v;
                      _selectedUnitId = null;
                    }),
                    validator: (v) => v == null || v.isEmpty ? context.tr('please_select_property') : null,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionLabel(context.tr('unit')),
                const SizedBox(height: 8),
                unitsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => Text(context.tr('failed_load_units'), style: GoogleFonts.nunito(color: AppColors.error)),
                  data: (units) => DropdownButtonFormField<String>(
                    value: _selectedUnitId,
                    isExpanded: true,
                    decoration: _dropdownDecoration(_selectedPropertyId == null ? context.tr('select_property_first') : context.tr('select_unit')),
                    items: units.map<DropdownMenuItem<String>>((u) {
                      final label = u['name'] ?? u['unit_number'] ?? context.tr('unit');
                      return DropdownMenuItem(value: u['id'].toString(), child: Text(label, style: GoogleFonts.nunito(fontSize: 14)));
                    }).toList(),
                    onChanged: _selectedPropertyId == null ? null : (v) => setState(() => _selectedUnitId = v),
                    validator: (v) => v == null || v.isEmpty ? context.tr('please_select_unit') : null,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionLabel(context.tr('tenant_details_label')),
                const SizedBox(height: 12),
                AppTextField(label: context.tr('full_name'), hint: context.tr('full_name_hint'), controller: _nameController, validator: (v) => v == null || v.isEmpty ? context.tr('name_required') : null),
                const SizedBox(height: 16),
                AppTextField(label: context.tr('phone'), hint: context.tr('phone_hint'), controller: _phoneController, keyboardType: TextInputType.phone, validator: (v) => v == null || v.isEmpty ? context.tr('phone_required') : null),
                const SizedBox(height: 16),
                AppTextField(label: context.tr('email'), hint: context.tr('optional'), controller: _emailController, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                AppTextField(label: context.tr('emergency_contact'), hint: context.tr('optional'), controller: _emergencyController),
                const SizedBox(height: 16),
                _buildSectionLabel(context.tr('move_in_date')),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickMoveInDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textLight),
                        const SizedBox(width: 12),
                        Text(DateFormat('dd MMM yyyy').format(_moveInDate), style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textDark)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(text: _isEditMode ? context.tr('update_tenant') : context.tr('save_tenant'), isLoading: _isLoading, onPressed: _submit),
              ],
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
}
