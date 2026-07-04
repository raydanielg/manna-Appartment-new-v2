import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/tenants_provider.dart';
import '../../../units/providers/units_provider.dart';

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
  final _idNumberController = TextEditingController();
  final _emergencyController = TextEditingController();
  String? _selectedUnitId;
  DateTime _moveInDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _idNumberController.dispose();
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
    if (_selectedUnitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a unit'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(tenantsRepositoryProvider);
      await repo.createTenant({
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'id_number': _idNumberController.text.trim(),
        'emergency_contact': _emergencyController.text.trim(),
        'unit_id': _selectedUnitId,
        'moved_in_date': DateFormat('yyyy-MM-dd').format(_moveInDate),
      });
      ref.invalidate(tenantsListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tenant added. SMS sent with login credentials.'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
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
    final unitsAsync = ref.watch(unitsListProvider(null));
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Add Tenant', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
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
              AppTextField(label: 'Full Name', hint: 'e.g. John Doe', controller: _nameController, validator: (v) => v == null || v.isEmpty ? 'Name is required' : null),
              const SizedBox(height: 16),
              AppTextField(label: 'Phone', hint: 'e.g. +255712345678', controller: _phoneController, keyboardType: TextInputType.phone, validator: (v) => v == null || v.isEmpty ? 'Phone is required' : null),
              const SizedBox(height: 16),
              AppTextField(label: 'Email', hint: 'optional', controller: _emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              AppTextField(label: 'ID Number', hint: 'optional', controller: _idNumberController),
              const SizedBox(height: 16),
              AppTextField(label: 'Emergency Contact', hint: 'optional', controller: _emergencyController),
              const SizedBox(height: 16),
              Text('Unit', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
              const SizedBox(height: 8),
              unitsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => Text('Failed to load units', style: GoogleFonts.nunito(color: Colors.red)),
                data: (units) => DropdownButtonFormField<String>(
                  value: _selectedUnitId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  hint: Text('Select unit', style: GoogleFonts.nunito(fontSize: 14)),
                  items: units.map<DropdownMenuItem<String>>((u) {
                    final label = u['name'] ?? u['unit_number'] ?? 'Unit';
                    return DropdownMenuItem(value: u['id'].toString(), child: Text(label, style: GoogleFonts.nunito(fontSize: 14)));
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedUnitId = v),
                ),
              ),
              const SizedBox(height: 16),
              Text('Move-in Date', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickMoveInDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 18, color: isDark ? Colors.white60 : AppColors.textLight),
                      const SizedBox(width: 12),
                      Text(DateFormat('dd MMM yyyy').format(_moveInDate), style: GoogleFonts.nunito(fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(text: 'Save Tenant', isLoading: _isLoading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
