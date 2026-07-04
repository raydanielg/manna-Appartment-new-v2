import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../providers/kyc_provider.dart';

class KycUploadDocumentsScreen extends ConsumerStatefulWidget {
  const KycUploadDocumentsScreen({super.key});

  @override
  ConsumerState<KycUploadDocumentsScreen> createState() => _KycUploadDocumentsScreenState();
}

class _KycUploadDocumentsScreenState extends ConsumerState<KycUploadDocumentsScreen> {
  final _idController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _idFront;
  File? _idBack;
  File? _selfie;
  File? _ownershipProof;

  Future<void> _pickImage(ImageSource source, void Function(File) onPicked) async {
    final picked = await _picker.pickImage(source: source, maxWidth: 1200, maxHeight: 1200, imageQuality: 80);
    if (picked != null) {
      onPicked(File(picked.path));
    }
  }

  Widget _buildPhotoCard(String label, File? file, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: file != null ? AppColors.primary : Colors.grey.shade300),
        ),
        child: file == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 32, color: AppColors.primary),
                  const SizedBox(height: 8),
                  Text(label, style: GoogleFonts.nunito(fontSize: 13, color: isDark ? Colors.white70 : AppColors.textLight)),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(file, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
              ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_idController.text.trim().isEmpty || _idFront == null || _idBack == null || _selfie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in your ID number and all required photos.')),
      );
      return;
    }

    final success = await ref.read(kycProvider.notifier).submit(
      idNumber: _idController.text.trim(),
      idPhotoFront: _idFront!,
      idPhotoBack: _idBack!,
      selfiePhoto: _selfie!,
      ownershipProof: _ownershipProof,
    );

    if (success && mounted) {
      context.go('/landlord/kyc/under-review');
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kycState = ref.watch(kycProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text('KYC Verification', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Submit your documents',
                  style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'We need to verify your identity before you can access the dashboard.',
                  style: GoogleFonts.nunito(fontSize: 14, color: isDark ? Colors.white70 : AppColors.textLight),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: 'ID / NIDA Number',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                _buildPhotoCard('ID Front', _idFront, () => _pickImage(ImageSource.camera, (f) => setState(() => _idFront = f))),
                const SizedBox(height: 12),
                _buildPhotoCard('ID Back', _idBack, () => _pickImage(ImageSource.camera, (f) => setState(() => _idBack = f))),
                const SizedBox(height: 12),
                _buildPhotoCard('Selfie', _selfie, () => _pickImage(ImageSource.camera, (f) => setState(() => _selfie = f))),
                const SizedBox(height: 12),
                _buildPhotoCard('Ownership Proof (optional)', _ownershipProof, () => _pickImage(ImageSource.gallery, (f) => setState(() => _ownershipProof = f))),
                const SizedBox(height: 24),
                if (kycState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      kycState.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: kycState.isLoading ? null : _submit,
                  icon: kycState.isLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.upload_file),
                  label: Text(kycState.isLoading ? 'Submitting...' : 'Submit KYC'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: kycState.isLoading ? null : () => context.go('/landlord/kyc'),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
