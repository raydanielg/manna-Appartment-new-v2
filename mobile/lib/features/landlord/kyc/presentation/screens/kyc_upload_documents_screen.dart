import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/localization/app_localizations.dart';
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: file != null ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB)),
        ),
        child: file == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined, size: 28, color: Color(0xFF6B7280)),
                  const SizedBox(height: 8),
                  Text(label, style: GoogleFonts.nunito(fontSize: 13, color: const Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                ],
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(file, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.check_circle, size: 20, color: Color(0xFF2563EB)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_idController.text.trim().isEmpty || _idFront == null || _idBack == null || _selfie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('fill_id_and_photos')),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('documents_received')),
          backgroundColor: const Color(0xFF2563EB),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
    final kycState = ref.watch(kycProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF111827)),
            onPressed: () => context.go('/landlord/kyc'),
          ),
          title: Text(context.tr('verification'), style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF111827))),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Submit documents',
                  style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please provide your identification details for account verification.',
                  style: GoogleFonts.nunito(fontSize: 14, color: const Color(0xFF6B7280)),
                ),
                const SizedBox(height: 32),
                if (kycState.error != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                kycState.error!,
                                style: GoogleFonts.nunito(color: const Color(0xFFB91C1C), fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => ref.read(kycProvider.notifier).clearError(),
                              child: const Icon(Icons.close_rounded, color: Color(0xFFEF4444), size: 18),
                            ),
                          ],
                        ),
                        if (kycState.error!.contains('No organization found')) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => context.go('/landlord/kyc/organization-setup'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.35),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(context.tr('resolve_now'), style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                _buildLabel('ID / NIDA Number'),
                TextField(
                  controller: _idController,
                  style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF111827)),
                  onTap: () => ref.read(kycProvider.notifier).clearError(),
                  decoration: InputDecoration(
                    hintText: 'Enter your ID number',
                    hintStyle: GoogleFonts.nunito(color: const Color(0xFF9CA3AF), fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                  ),
                ),
                const SizedBox(height: 24),

                _buildLabel('Required Documents'),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _buildPhotoCard('ID Front', _idFront, () => _pickImage(ImageSource.camera, (f) => setState(() => _idFront = f))),
                    _buildPhotoCard('ID Back', _idBack, () => _pickImage(ImageSource.camera, (f) => setState(() => _idBack = f))),
                    _buildPhotoCard('Selfie Photo', _selfie, () => _pickImage(ImageSource.camera, (f) => setState(() => _selfie = f))),
                    _buildPhotoCard('Ownership Proof', _ownershipProof, () => _pickImage(ImageSource.gallery, (f) => setState(() => _ownershipProof = f))),
                  ],
                ),
                
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: kycState.isLoading ? () {} : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF2563EB),
                      disabledForegroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: kycState.isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(context.tr('submit_verification'), style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF374151),
        ),
      ),
    );
  }
}
