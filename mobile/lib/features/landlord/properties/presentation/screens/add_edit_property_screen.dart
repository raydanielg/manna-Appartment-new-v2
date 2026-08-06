import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/properties_provider.dart';

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
  final Map<String, String> _fieldErrors = {};

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
      if (mounted) setState(() {
        _isDataLoaded = true;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.tr('failed_load_property')}: $e'), backgroundColor: AppColors.error),
        );
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
    final picked = await _picker.pickMultiImage(maxWidth: 1200, maxHeight: 1200, imageQuality: 80);
    if (picked.isEmpty) return;
    setState(() {
      _imagePaths = [..._imagePaths, ...picked.map((e) => e.path)];
      _fieldErrors.remove('images');
    });
  }

  void _removeImage(int index) {
    setState(() => _imagePaths.removeAt(index));
  }

  void _setFieldError(String field, String message) {
    setState(() => _fieldErrors[field] = message);
  }

  void _clearFieldError(String field) {
    if (_fieldErrors.containsKey(field)) {
      setState(() => _fieldErrors.remove(field));
    }
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
    setState(() {
      _isLoading = true;
      _fieldErrors.clear();
    });
    try {
      final repo = ref.read(propertiesRepositoryProvider);
      if (_isEditMode) {
        await repo.updateProperty(widget.propertyId!, {
          'name': _nameController.text.trim(),
          'address': _addressController.text.trim(),
          'type': _type,
          if (_locationController.text.trim().isNotEmpty) 'location': _locationController.text.trim(),
        });
        ref.invalidate(propertiesListProvider);
        ref.invalidate(propertyDetailProvider(widget.propertyId!));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('property_updated')),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('property_created')),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        final message = _extractErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(_isEditMode ? context.tr('edit_property') : context.tr('add_property'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
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
              ],
              AppTextField(
                label: context.tr('property_name'),
                hint: context.tr('property_name_hint'),
                controller: _nameController,
                prefix: const Icon(Icons.apartment, size: 20),
                validator: (v) => v == null || v.isEmpty ? context.tr('name_required') : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: context.tr('address'),
                hint: context.tr('address_hint'),
                controller: _addressController,
                prefix: const Icon(Icons.location_on, size: 20),
                validator: (v) => v == null || v.isEmpty ? context.tr('address_required') : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: context.tr('location_optional'),
                hint: context.tr('location_hint'),
                controller: _locationController,
                prefix: const Icon(Icons.map, size: 20),
              ),
              const SizedBox(height: 16),
              Text(context.tr('property_type'), style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                dropdownColor: Colors.white,
                items: [
                  DropdownMenuItem(value: 'apartment', child: Text(context.tr('apartment'))),
                  DropdownMenuItem(value: 'house', child: Text(context.tr('house'))),
                  DropdownMenuItem(value: 'commercial', child: Text(context.tr('commercial'))),
                  DropdownMenuItem(value: 'mixed', child: Text(context.tr('mixed_use'))),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'apartment'),
              ),
              if (!_isEditMode) ...[
                const SizedBox(height: 24),
                Text(context.tr('property_photos'), style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 10),
                _buildImagePicker(context),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                text: _isEditMode ? context.tr('update_property') : context.tr('save_property'),
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

  Widget _buildImagePicker(BuildContext context) {
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
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(path),
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }),
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, color: AppColors.primary),
                    const SizedBox(height: 4),
                    Text(context.tr('add_photos'), style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textLight)),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_imagePaths.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text('${_imagePaths.length} ${context.tr('photos_selected')}', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textLight)),
          ),
      ],
    );
  }
}
