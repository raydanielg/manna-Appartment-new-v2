import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/units_provider.dart';
import '../../../properties/providers/properties_provider.dart';

import 'package:manna_apartment/core/utils/app_toast.dart';

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
      _selectedPropertyId =
          unit['property_id']?.toString() ?? _selectedPropertyId;
      if (mounted) {
        setState(() {
          _isDataLoaded = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.error(context, 'Failed to load unit: $e');
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
        AppToast.error(context, 'Please select a property first.');
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
          AppToast.success(context, 'Unit updated successfully');
          context.pop();
        }
      } else {
        await repo.createUnit(propertyId, data);
        ref.invalidate(unitsListProvider(propertyId));
        if (mounted) {
          AppToast.success(context, 'Unit created successfully');
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditMode ? context.tr('edit_unit') : context.tr('add_unit'),
          style: typography.display.md.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: FButton.icon(
          variant: .ghost,
          size: .sm,
          onPress: () => context.pop(),
          child: context.theme.icons.arrowLeft(context),
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
                const Center(child: FCircularProgress()),
              ],
              if (widget.propertyId == null ||
                  widget.propertyId!.isEmpty) ...[
                _buildPropertySelector(context, colors, typography),
                const SizedBox(height: 16),
              ],
              FTextFormField(
                control: .managed(controller: _nameController),
                label: Text(context.tr('unit_name_number')),
                hint: context.tr('unit_name_hint'),
                validator: (v) =>
                    v == null || v.isEmpty ? context.tr('name_required') : null,
              ),
              const SizedBox(height: 16),
              FTextFormField(
                control: .managed(controller: _rentController),
                label: Text(context.tr('monthly_rent_tzs')),
                hint: context.tr('rent_hint'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? context.tr('rent_required') : null,
              ),
              const SizedBox(height: 16),
              FTextFormField(
                control: .managed(controller: _sizeController),
                label: Text(context.tr('size_sqm')),
                hint: context.tr('optional'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('unit_type'),
                style: typography.body.xs2.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in const [
                    ('bedsitter', 'bedsitter'),
                    ('1br', '1_bedroom'),
                    ('2br', '2_bedroom'),
                    ('3br', '3_bedroom'),
                    ('studio', 'studio'),
                    ('shop', 'shop'),
                  ])
                    FButton(
                      variant: _type == t.$1 ? .primary : .outline,
                      size: .sm,
                      mainAxisSize: MainAxisSize.min,
                      onPress: () => setState(() => _type = t.$1),
                      child: Text(context.tr(t.$2)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _counter(colors, typography, context.tr('bedrooms'),
                        _bedrooms, (v) => setState(() => _bedrooms = v)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _counter(colors, typography, context.tr('bathrooms'),
                        _bathrooms, (v) => setState(() => _bathrooms = v)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: _isEditMode
                    ? context.tr('update_unit')
                    : context.tr('save_unit'),
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertySelector(
      BuildContext context, FColors colors, FTypography typography) {
    final propertiesAsync = ref.watch(propertiesListProvider);
    return propertiesAsync.when(
      loading: () => const Center(child: FCircularProgress()),
      error: (e, _) => Text('${context.tr('failed_load_properties')}: $e',
          style: TextStyle(color: colors.error)),
      data: (properties) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('select_property'),
              style: typography.body.xs2.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in properties)
                  FButton(
                    variant: _selectedPropertyId == p.id ? .primary : .outline,
                    size: .sm,
                    mainAxisSize: MainAxisSize.min,
                    onPress: () =>
                        setState(() => _selectedPropertyId = p.id),
                    child: Text(p.name),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _counter(FColors colors, FTypography typography, String label,
      int value, ValueChanged<int> onChanged) {
    return FCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style:
                  typography.body.xs3.copyWith(color: colors.mutedForeground),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FButton.icon(
                  variant: .ghost,
                  size: .sm,
                  onPress: value > 0 ? () => onChanged(value - 1) : null,
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedMinusSign,
                    size: 18,
                    color: colors.mutedForeground,
                  ),
                ),
                Text(
                  '$value',
                  style:
                      typography.body.md.copyWith(fontWeight: FontWeight.w800),
                ),
                FButton.icon(
                  variant: .ghost,
                  size: .sm,
                  onPress: () => onChanged(value + 1),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedAdd01,
                    size: 18,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
