import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/properties_provider.dart';

class AddEditPropertyScreen extends ConsumerStatefulWidget {
  const AddEditPropertyScreen({super.key});

  @override
  ConsumerState<AddEditPropertyScreen> createState() => _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends ConsumerState<AddEditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  String _type = 'apartment';
  bool _isLoading = false;
  List<String> _imagePaths = [];
  final Map<String, String> _fieldErrors = {};

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
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
        if (data['message'] is String) return data['message'];
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final first = errors.values.firstWhere((v) => v is List && v.isNotEmpty, orElse: () => []);
          if (first is List && first.isNotEmpty) return first.first.toString();
        }
      }
      return error.message ?? 'Request failed. Please try again.';
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
      await repo.createProperty(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        location: _locationController.text.trim(),
        type: _type,
        description: _descriptionController.text.trim(),
        imagePaths: _imagePaths,
      );
      ref.invalidate(propertiesListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Property created successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Add Property', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
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
              _buildHeader(context),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Property Name',
                hint: 'e.g. Manna Apartments',
                controller: _nameController,
                prefix: const Icon(Icons.apartment, size: 20),
                validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Address',
                hint: 'e.g. Kijitonyama, Dar es Salaam',
                controller: _addressController,
                prefix: const Icon(Icons.location_on, size: 20),
                validator: (v) => v == null || v.isEmpty ? 'Address is required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Location (Optional)',
                hint: 'e.g. Dar es Salaam',
                controller: _locationController,
                prefix: const Icon(Icons.map, size: 20),
              ),
              const SizedBox(height: 16),
              Text('Property Type', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                items: const [
                  DropdownMenuItem(value: 'apartment', child: Text('Apartment')),
                  DropdownMenuItem(value: 'house', child: Text('House')),
                  DropdownMenuItem(value: 'commercial', child: Text('Commercial')),
                  DropdownMenuItem(value: 'mixed', child: Text('Mixed Use')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'apartment'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Description',
                hint: 'Optional description',
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text('Property Photos', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
              const SizedBox(height: 10),
              _buildImagePicker(context),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Save Property',
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

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: const Icon(Icons.apartment, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Property', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Fill in the details below to register your property.', style: GoogleFonts.nunito(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    borderRadius: BorderRadius.circular(12),
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
                  color: isDark ? const Color(0xFF26334D) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, color: AppColors.primary),
                    const SizedBox(height: 4),
                    Text('Add Photos', style: GoogleFonts.nunito(fontSize: 11, color: isDark ? Colors.white70 : AppColors.textLight)),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_imagePaths.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text('${_imagePaths.length} photo(s) selected', style: GoogleFonts.nunito(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
          ),
      ],
    );
  }
}
