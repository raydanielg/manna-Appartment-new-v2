import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/units_provider.dart';
import '../../../properties/providers/properties_provider.dart';

class AddEditUnitScreen extends ConsumerStatefulWidget {
  final String? propertyId;

  const AddEditUnitScreen({super.key, this.propertyId});

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
  String? _selectedPropertyId;

  @override
  void initState() {
    super.initState();
    final id = widget.propertyId;
    if (id != null && id.isNotEmpty) {
      _selectedPropertyId = id;
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
      await repo.createUnit(propertyId, {
        'name': _nameController.text.trim(),
        'monthly_rent': int.tryParse(_rentController.text) ?? 0,
        'size': _sizeController.text.trim(),
        'type': _type,
        'bedrooms': _bedrooms,
        'bathrooms': _bathrooms,
      });
      if (mounted) {
        _showSnack('Unit created successfully', AppColors.success);
        context.pop();
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
      appBar: AppBar(title: const Text('Add Unit'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.propertyId == null || widget.propertyId!.isEmpty) ...[
                _buildPropertySelector(context),
                const SizedBox(height: 16),
              ],
              AppTextField(label: 'Unit Name/Number', hint: 'e.g. A-101', controller: _nameController, validator: (v) => v == null || v.isEmpty ? 'Name is required' : null),
              const SizedBox(height: 16),
              AppTextField(label: 'Monthly Rent (TZS)', hint: 'e.g. 350000', controller: _rentController, keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? 'Rent is required' : null),
              const SizedBox(height: 16),
              AppTextField(label: 'Size (sqm)', hint: 'optional', controller: _sizeController, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              Text('Unit Type', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
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

  Widget _buildPropertySelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final propertiesAsync = ref.watch(propertiesListProvider);
    return propertiesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Failed to load properties: $e', style: TextStyle(color: AppColors.error)),
      data: (properties) {
        final items = properties.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Property', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
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
              hint: Text('Choose a property', style: TextStyle(color: isDark ? Colors.white60 : AppColors.textLight)),
              items: items,
              onChanged: (v) => setState(() => _selectedPropertyId = v),
              validator: (v) => v == null || v.isEmpty ? 'Select a property' : null,
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
