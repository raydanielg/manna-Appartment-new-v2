import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/config/app_config.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../features/auth/providers/auth_provider.dart';

class LandlordProfileScreen extends ConsumerStatefulWidget {
  const LandlordProfileScreen({super.key});

  @override
  ConsumerState<LandlordProfileScreen> createState() => _LandlordProfileScreenState();
}

class _LandlordProfileScreenState extends ConsumerState<LandlordProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _picker = ImagePicker();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    Future.microtask(() => ref.read(authProvider.notifier).refreshFullProfile());
  }

  void _loadUser() {
    final user = ref.read(authProvider).user;
    if (user != null) {
      _nameController.text = user.fullName;
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phone;
    }
  }

  Future<void> _pickAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Update Profile Photo', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: Text('Camera', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: Text('Gallery', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;

    final picked = await _picker.pickImage(source: source, maxWidth: 800, maxHeight: 800, imageQuality: 80);
    if (picked == null) return;

    setState(() => _isLoading = true);
    final success = await ref.read(authProvider.notifier).updateAvatar(picked.path);
    setState(() => _isLoading = false);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar updated successfully'), backgroundColor: AppColors.primary),
      );
    } else if (mounted) {
      final error = ref.read(authProvider).error ?? 'Failed to update avatar';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final success = await ref.read(authProvider.notifier).updateProfile(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    setState(() {
      _isLoading = false;
      _isEditing = false;
    });
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully'), backgroundColor: AppColors.primary),
      );
    } else if (mounted) {
      final error = ref.read(authProvider).error ?? 'Failed to update profile';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final authState = ref.watch(authProvider);
    if (user == null) return const SizedBox.shrink();

    final initials = user.fullName.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
    final kycApproved = authState.isKycApproved;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        title: Text('My Profile', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: ClipOval(
                    child: user.avatar != null && user.avatar!.isNotEmpty
                        ? Image.network(
                            _avatarUrl(user.avatar!),
                            key: ValueKey(user.avatar!),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) => progress == null
                                ? child
                                : Center(child: CircularProgressIndicator(color: Colors.white, value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes! : null)),
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(initials, style: GoogleFonts.nunito(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)),
                            ),
                          )
                        : Center(
                            child: Text(initials, style: GoogleFonts.nunito(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                  ),
                ),
                GestureDetector(
                  onTap: _pickAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kycApproved ? Colors.green.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kycApproved ? Colors.green : Colors.amber),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(kycApproved ? Icons.verified : Icons.pending, size: 14, color: kycApproved ? Colors.green : Colors.amber),
                  const SizedBox(width: 6),
                  Text(
                    kycApproved ? 'KYC Verified' : 'KYC Pending',
                    style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: kycApproved ? Colors.green : Colors.amber),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildCard(
              context,
              child: Column(
                children: [
                  _buildField(context, label: 'Full Name', controller: _nameController, enabled: _isEditing, icon: Icons.person),
                  const Divider(height: 1),
                  _buildField(context, label: 'Phone', controller: _phoneController, enabled: _isEditing, icon: Icons.phone),
                  const Divider(height: 1),
                  _buildField(context, label: 'Email', controller: _emailController, enabled: _isEditing, icon: Icons.email),
                  const Divider(height: 1),
                  _buildInfoRow(context, 'Role', user.role.toUpperCase()),
                  const Divider(height: 1),
                  _buildInfoRow(context, 'Organization', user.businessName ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_isEditing) PrimaryButton(
              text: _isLoading ? 'Saving...' : 'Save Changes',
              icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
              onPressed: _isLoading ? null : _saveProfile,
            ),
            const SizedBox(height: 16),
            if (_isLoading) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _buildField(BuildContext context, {required String label, required TextEditingController controller, required bool enabled, required IconData icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: GoogleFonts.nunito(fontSize: 14, color: isDark ? Colors.white : AppColors.textDark),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.nunito(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight),
          prefixIcon: Icon(icon, size: 18, color: enabled ? AppColors.primary : (isDark ? Colors.white54 : Colors.grey)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.nunito(fontSize: 14, color: isDark ? Colors.white70 : AppColors.textLight)),
          Text(value, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
        ],
      ),
    );
  }

  String _avatarUrl(String avatar) {
    if (avatar.isEmpty) return avatar;
    if (avatar.startsWith('http://') || avatar.startsWith('https://')) return avatar;
    final base = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/api/?$'), '');
    final separator = avatar.startsWith('/') ? '' : '/';
    return '$base$separator$avatar';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
