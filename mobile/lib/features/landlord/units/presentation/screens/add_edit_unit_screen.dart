import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/units_provider.dart';
import '../../../properties/providers/properties_provider.dart';

class AddEditUnitScreen extends ConsumerStatefulWidget {
  final String? propertyId;
  final String? unitId;

  const AddEditUnitScreen({super.key, this.propertyId, this.unitId});

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
  bool _isEditMode = false;
  bool _isDataLoaded = false;
  String? _selectedPropertyId;

  @override
  void initState() {
    super.initState();
    final pid = widget.propertyId;
    if (pid != null && pid.isNotEmpty) {
      _selectedPropertyId = pid;
    }
    _isEditMode = widget.unitId != null && widget.unitId!.isNotEmpty;
    if (_isEditMode) {
      _loadUnitData();
    }
  }

  Future<void> _loadUnitData() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(unitsRepositoryProvider);
      final unit = await repo.getUnit(widget.unitId!);
      _nameController.text = unit['name'] ?? unit['unit_number'] ?? '';
      _rentController.text = (unit['monthly_rent'] ?? '').toString();
      _sizeController.text = unit['size']?.toString() ?? '';
      _type = unit['type'] ?? 'bedsitter';
      _bedrooms = unit['bedrooms'] ?? 0;
      _bathrooms = unit['bathrooms'] ?? 1;
      _selectedPropertyId = unit['property_id']?.toString() ?? _selectedPropertyId;
      if (mounted) setState(() {
        _isDataLoaded = true;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack('Failed to load unit: $e', AppColors.error);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rentController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final propertyId = _selectedPropertyId;
    if (propertyId == null || propertyId.isEmpty) {
      if (mounted) {
        _showSnack('Please select a property first.', AppColors.error);
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(unitsRepositoryProvider);
      final data = {
        'name': _nameController.text.trim(),
        'monthly_rent': double.tryParse(_rentController.text) ?? 0,
        'size': _sizeController.text.trim(),
        'type': _type,
        'bedrooms': _bedrooms,
        'bathrooms': _bathrooms,
      };
      if (_isEditMode) {
        await repo.updateUnit(widget.unitId!, data);
        ref.invalidate(unitsListProvider(_selectedPropertyId));
        ref.invalidate(unitDetailProvider(widget.unitId!));
        if (mounted) {
          _showSnack('Unit updated successfully', AppColors.success);
          context.pop();
        }
      } else {
        await repo.createUnit(propertyId, data);
        ref.invalidate(unitsListProvider(propertyId));
        if (mounted) {
          _showSnack('Unit created successfully', AppColors.success);
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Error: ${e.toString()}', AppColors.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: Text(_isEditMode ? context.tr('edit_unit') : context.tr('add_unit')), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
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
              ],
              if (widget.propertyId == null || widget.propertyId!.isEmpty) ...[
                _buildPropertySelector(context),
                const SizedBox(height: 16),
              ],
              AppTextField(label: context.tr('unit_name_number'), hint: context.tr('unit_name_hint'), controller: _nameController, validator: (v) => v == null || v.isEmpty ? context.tr('name_required') : null),
              const SizedBox(height: 16),
              AppTextField(label: context.tr('monthly_rent_tzs'), hint: context.tr('rent_hint'), controller: _rentController, keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? context.tr('rent_required') : null),
              const SizedBox(height: 16),
              AppTextField(label: context.tr('size_sqm'), hint: context.tr('optional'), controller: _sizeController, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              Text(context.tr('unit_type'), style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                items: [
                  DropdownMenuItem(value: 'bedsitter', child: Text(context.tr('bedsitter'))),
                  DropdownMenuItem(value: '1br', child: Text(context.tr('1_bedroom'))),
                  DropdownMenuItem(value: '2br', child: Text(context.tr('2_bedroom'))),
                  DropdownMenuItem(value: '3br', child: Text(context.tr('3_bedroom'))),
                  DropdownMenuItem(value: 'studio', child: Text(context.tr('studio'))),
                  DropdownMenuItem(value: 'shop', child: Text(context.tr('shop'))),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'bedsitter'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildCounter(context, context.tr('bedrooms'), _bedrooms, (v) => setState(() => _bedrooms = v))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCounter(context, context.tr('bathrooms'), _bathrooms, (v) => setState(() => _bathrooms = v))),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(text: _isEditMode ? context.tr('update_unit') : context.tr('save_unit'), isLoading: _isLoading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertySelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final propertiesAsync = ref.watch(propertiesListProvider);
    return propertiesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('${context.tr('failed_load_properties')}: $e', style: TextStyle(color: AppColors.error)),
      data: (properties) {
        final items = properties.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('select_property'), style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPropertyId,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              hint: Text(context.tr('choose_property'), style: TextStyle(color: isDark ? Colors.white60 : AppColors.textLight)),
              items: items,
              onChanged: (v) => setState(() => _selectedPropertyId = v),
              validator: (v) => v == null || v.isEmpty ? context.tr('please_select_property') : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCounter(BuildContext context, String label, int value, ValueChanged<int> onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.textLight)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: value > 0 ? () => onChanged(value - 1) : null,
                ),
                Text('$value', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () => onChanged(value + 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
