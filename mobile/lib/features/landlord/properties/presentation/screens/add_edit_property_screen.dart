import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/properties_provider.dart';

import 'package:manna_apartment/core/utils/app_toast.dart';

class AddEditPropertyScreen extends ConsumerStatefulWidget {
  final String? propertyId;
  const AddEditPropertyScreen({super.key, this.propertyId});

  @override
  ConsumerState<AddEditPropertyScreen> createState() => _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends ConsumerState<AddEditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();
  final _picker = ImagePicker();
  String _type = 'apartment';
  bool _isLoading = false;
  bool _isEditMode = false;
  bool _isDataLoaded = false;
  List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.propertyId != null && widget.propertyId!.isNotEmpty;
    if (_isEditMode) {
      _loadPropertyData();
    }
  }

  Future<void> _loadPropertyData() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(propertiesRepositoryProvider);
      final property = await repo.getProperty(widget.propertyId!);
      _nameController.text = property.name;
      _addressController.text = property.address ?? '';
      _locationController.text = '';
      _type = property.type ?? 'apartment';
      if (mounted) {
        setState(() {
          _isDataLoaded = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.error(context, '${context.tr('failed_load_property')}: $e');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (picked.isEmpty) return;
    setState(() => _imagePaths = [..._imagePaths, ...picked.map((e) => e.path)]);
  }

  void _removeImage(int index) {
    setState(() => _imagePaths.removeAt(index));
  }

  String _extractErrorMessage(dynamic error) {
    if (error is DioException) {
      final response = error.response;
      if (response?.data is Map) {
        final data = response!.data as Map;
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final messages = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              for (final msg in value) {
                messages.add('$key: ${msg.toString()}');
              }
            } else if (value is String) {
              messages.add('$key: $value');
            }
          });
          if (messages.isNotEmpty) return messages.join('\n');
        }
        if (data['message'] is String && data['message'].toString().isNotEmpty) {
          return data['message'].toString();
        }
      }
      return error.message ?? context.tr('request_failed');
    }
    return error.toString();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(propertiesRepositoryProvider);
      if (_isEditMode) {
        await repo.updateProperty(widget.propertyId!, {
          'name': _nameController.text.trim(),
          'address': _addressController.text.trim(),
          'type': _type,
          if (_locationController.text.trim().isNotEmpty)
            'location': _locationController.text.trim(),
        });
        ref.invalidate(propertiesListProvider);
        ref.invalidate(propertyDetailProvider(widget.propertyId!));
        if (mounted) {
          AppToast.success(context, context.tr('property_updated'));
          context.pop();
        }
      } else {
        await repo.createProperty(
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          location: _locationController.text.trim(),
          type: _type,
          imagePaths: _imagePaths,
        );
        ref.invalidate(propertiesListProvider);
        if (mounted) {
          AppToast.success(context, context.tr('property_created'));
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        final message = _extractErrorMessage(e);
        AppToast.error(context, message);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _icon(
    BuildContext context,
    FTextFieldStyle style,
    Set<FTextFieldVariant> variants,
    List<List<dynamic>> icon,
  ) =>
      FTextField.prefixIconBuilder(
        context,
        style,
        variants,
        HugeIcon(icon: icon, size: null),
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final radii = context.theme.style.borderRadius;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditMode ? context.tr('edit_property') : context.tr('add_property'),
          style: typography.display.md.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: FButton.icon(
          variant: .ghost,
          size: .sm,
          onPress: () {
            if (context.canPop()) context.pop();
          },
          child: context.theme.icons.arrowLeft(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading && _isEditMode && !_isDataLoaded) ...[
                const SizedBox(height: 16),
                const Center(child: FCircularProgress()),
              ],
              FTextFormField(
                control: .managed(controller: _nameController),
                label: Text(context.tr('property_name')),
                hint: context.tr('property_name_hint'),
                textInputAction: TextInputAction.next,
                prefixBuilder: (context, style, variants) =>
                    _icon(context, style, variants, HugeIcons.strokeRoundedBuilding03),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? context.tr('name_required') : null,
              ),
              const SizedBox(height: 18),
              FTextFormField(
                control: .managed(controller: _addressController),
                label: Text(context.tr('address')),
                hint: context.tr('address_hint'),
                textInputAction: TextInputAction.next,
                prefixBuilder: (context, style, variants) =>
                    _icon(context, style, variants, HugeIcons.strokeRoundedLocation01),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? context.tr('address_required') : null,
              ),
              const SizedBox(height: 18),
              FTextFormField(
                control: .managed(controller: _locationController),
                label: Text(context.tr('location_optional')),
                hint: context.tr('location_hint'),
                textInputAction: TextInputAction.done,
                prefixBuilder: (context, style, variants) =>
                    _icon(context, style, variants, HugeIcons.strokeRoundedMapsLocation01),
              ),
              const SizedBox(height: 20),

              // Property type — segmented choice buttons
              Text(
                context.tr('property_type'),
                style: typography.body.sm.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in ['apartment', 'house', 'commercial', 'mixed'])
                    FButton(
                      variant: _type == type ? .primary : .outline,
                      size: .sm,
                      mainAxisSize: MainAxisSize.min,
                      onPress: () => setState(() => _type = type),
                      child: Text(context.tr(
                        type == 'mixed' ? 'mixed_use' : type,
                      )),
                    ),
                ],
              ),

              if (!_isEditMode) ...[
                const SizedBox(height: 24),
                Text(
                  context.tr('property_photos'),
                  style: typography.body.sm.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                _buildImagePicker(context, colors, typography, radii),
              ],

              const SizedBox(height: 28),
              PrimaryButton(
                text: _isEditMode
                    ? context.tr('update_property')
                    : context.tr('save_property'),
                isLoading: _isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(
    BuildContext context,
    FColors colors,
    FTypography typography,
    FBorderRadius radii,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ..._imagePaths.asMap().entries.map((entry) {
              final index = entry.key;
              final path = entry.value;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: radii.md,
                    child: Image.file(
                      File(path),
                      width: 92,
                      height: 92,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: FTappable(
                      onPress: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.background, width: 1.5),
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedCancel01,
                          size: 12,
                          color: colors.errorForeground,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
            FTappable(
              onPress: _pickImages,
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: colors.secondary.withValues(alpha: 0.4),
                  borderRadius: radii.md,
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedImageAdd01,
                      size: 24,
                      color: colors.primary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.tr('add_photos'),
                      style: typography.body.xs3.copyWith(color: colors.mutedForeground),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_imagePaths.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              '${_imagePaths.length} ${context.tr('photos_selected')}',
              style: typography.body.xs2.copyWith(color: colors.mutedForeground),
            ),
          ),
      ],
    );
  }
}
