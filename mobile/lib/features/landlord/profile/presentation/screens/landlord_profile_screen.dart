import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/config/app_config.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../features/auth/data/models/login_response_model.dart';
import '../../../../../features/auth/providers/auth_provider.dart';

import 'package:manna_apartment/core/utils/app_toast.dart';

class LandlordProfileScreen extends ConsumerStatefulWidget {
  const LandlordProfileScreen({super.key});

  @override
  ConsumerState<LandlordProfileScreen> createState() =>
      _LandlordProfileScreenState();
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
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('update_profile_photo'),
                style:
                    typography.body.md.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _sourceTile(context, colors, typography,
                  HugeIcons.strokeRoundedCamera01, context.tr('camera'),
                  ImageSource.camera),
              _sourceTile(context, colors, typography,
                  HugeIcons.strokeRoundedImage01, context.tr('gallery'),
                  ImageSource.gallery),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;

    final picked = await _picker.pickImage(
        source: source, maxWidth: 800, maxHeight: 800, imageQuality: 80);
    if (picked == null) return;

    setState(() => _isLoading = true);
    final success =
        await ref.read(authProvider.notifier).updateAvatar(picked.path);
    setState(() => _isLoading = false);
    if (success && mounted) {
      AppToast.info(context, context.tr('avatar_updated'));
    } else if (mounted) {
      final error =
          ref.read(authProvider).error ?? context.tr('failed_update_avatar');
      AppToast.error(context, error);
    }
  }

  Widget _sourceTile(BuildContext context, FColors colors,
      FTypography typography, List<List<dynamic>> icon, String label,
      ImageSource source) {
    return FTappable(
      onPress: () => Navigator.pop(context, source),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: context.theme.style.borderRadius.md,
              ),
              child: Center(
                  child: HugeIcon(icon: icon, size: 17, color: colors.primary)),
            ),
            const SizedBox(width: 12),
            Text(label,
                style:
                    typography.body.sm.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
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
      AppToast.info(context, context.tr('profile_updated'));
    } else if (mounted) {
      final error =
          ref.read(authProvider).error ?? context.tr('failed_update_profile');
      AppToast.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final authState = ref.watch(authProvider);
    if (user == null) return const SizedBox.shrink();

    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final radii = context.theme.style.borderRadius;
    final initials = user.fullName
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();
    final kycApproved = authState.isKycApproved;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('my_profile'),
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
        actions: [
          FButton.icon(
            variant: .ghost,
            size: .sm,
            onPress: () => setState(() => _isEditing = !_isEditing),
            child: HugeIcon(
              icon: _isEditing
                  ? HugeIcons.strokeRoundedCancel01
                  : HugeIcons.strokeRoundedEdit02,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + name — centered, simple
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.secondary,
                          border: Border.all(color: colors.border, width: 2),
                        ),
                        child: ClipOval(
                          child: user.avatar != null && user.avatar!.isNotEmpty
                              ? Image.network(
                                  _avatarUrl(user.avatar!),
                                  key: ValueKey(user.avatar!),
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => _initials(
                                      colors, typography, initials),
                                )
                              : _initials(colors, typography, initials),
                        ),
                      ),
                      FTappable(
                        onPress: _pickAvatar,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: colors.background, width: 2),
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCamera01,
                            size: 14,
                            color: colors.primaryForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName,
                    style: typography.display.sm
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (kycApproved
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFD97706))
                          .withValues(alpha: 0.1),
                      borderRadius: radii.pill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(
                          icon: kycApproved
                              ? HugeIcons.strokeRoundedCheckmarkBadge02
                              : HugeIcons.strokeRoundedClock01,
                          size: 12,
                          color: kycApproved
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          kycApproved
                              ? context.tr('kyc_verified_badge')
                              : context.tr('kyc_pending_status'),
                          style: typography.body.xs3.copyWith(
                            fontWeight: FontWeight.w700,
                            color: kycApproved
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            _sectionTitle(context, context.tr('personal_information')),
            const SizedBox(height: 8),
            if (_isEditing) ...[
              FTextField(
                control: .managed(controller: _nameController),
                label: Text(context.tr('full_name')),
                hint: context.tr('full_name'),
                prefixBuilder: (context, style, variants) =>
                    FTextField.prefixIconBuilder(
                      context,
                      style,
                      variants,
                      const HugeIcon(icon: HugeIcons.strokeRoundedUser, size: null),
                    ),
              ),
              const SizedBox(height: 12),
              FTextField(
                control: .managed(controller: _phoneController),
                label: Text(context.tr('phone')),
                hint: '0712...',
                keyboardType: TextInputType.phone,
                prefixBuilder: (context, style, variants) =>
                    FTextField.prefixIconBuilder(
                      context,
                      style,
                      variants,
                      const HugeIcon(icon: HugeIcons.strokeRoundedCall, size: null),
                    ),
              ),
              const SizedBox(height: 12),
              FTextField(
                control: .managed(controller: _emailController),
                label: Text(context.tr('email')),
                hint: 'email@example.com',
                keyboardType: TextInputType.emailAddress,
                prefixBuilder: (context, style, variants) =>
                    FTextField.prefixIconBuilder(
                      context,
                      style,
                      variants,
                      const HugeIcon(icon: HugeIcons.strokeRoundedMail01, size: null),
                    ),
              ),
              const SizedBox(height: 12),
              FCard(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: _infoRow(context, context.tr('role'),
                      user.role.toUpperCase()),
                ),
              ),
            ] else
              FCard(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    children: [
                      _field(context, context.tr('full_name'), _nameController,
                          HugeIcons.strokeRoundedUser),
                      _divider(colors),
                      _field(context, context.tr('phone'), _phoneController,
                          HugeIcons.strokeRoundedCall),
                      _divider(colors),
                      _field(context, context.tr('email'), _emailController,
                          HugeIcons.strokeRoundedMail01),
                      _divider(colors),
                      _infoRow(context, context.tr('role'),
                          user.role.toUpperCase()),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            _sectionTitle(context, context.tr('organization')),
            const SizedBox(height: 8),
            _orgCard(context, user, colors, typography, radii, kycApproved),
            const SizedBox(height: 24),

            if (_isEditing)
              PrimaryButton(
                text: context.tr('save_changes'),
                isLoading: _isLoading,
                onPressed: _saveProfile,
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _initials(FColors colors, FTypography typography, String initials) {
    return Center(
      child: Text(
        initials,
        style: typography.display.lg.copyWith(
          fontWeight: FontWeight.w800,
          color: colors.secondaryForeground,
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: typography.body.xs3.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: colors.mutedForeground,
        ),
      ),
    );
  }

  Widget _divider(FColors colors) =>
      Divider(height: 1, indent: 8, color: colors.border.withValues(alpha: 0.5));

  Widget _field(BuildContext context, String label,
      TextEditingController controller, List<List<dynamic>> icon) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          HugeIcon(icon: icon, size: 16, color: colors.mutedForeground),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: typography.body.xs3
                      .copyWith(color: colors.mutedForeground),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.text.isEmpty ? '—' : controller.text,
                  style:
                      typography.body.xs2.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  typography.body.xs2.copyWith(color: colors.mutedForeground)),
          Flexible(
            child: Text(
              value,
              style:
                  typography.body.xs2.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orgCard(BuildContext context, UserModel user, FColors colors,
      FTypography typography, FBorderRadius radii, bool kycApproved) {
    final orgStatus = user.organizationStatus ?? 'active';
    final isActive = orgStatus == 'active';

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: radii.md,
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedBuilding03,
                      size: 18,
                      color: colors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    user.businessName ?? context.tr('organization'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        typography.body.sm.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _orgRow(context, context.tr('sms_balance'),
                '${user.smsBalance ?? 0}', HugeIcons.strokeRoundedMessage01,
                const Color(0xFF0EA5E9)),
            _divider(colors),
            _orgRow(
              context,
              context.tr('kyc_status_label'),
              kycApproved ? context.tr('verified') : context.tr('pending'),
              kycApproved
                  ? HugeIcons.strokeRoundedCheckmarkBadge02
                  : HugeIcons.strokeRoundedClock01,
              kycApproved ? const Color(0xFF16A34A) : const Color(0xFFD97706),
            ),
            _divider(colors),
            _orgRow(
              context,
              context.tr('account_status'),
              isActive ? context.tr('active') : orgStatus,
              isActive
                  ? HugeIcons.strokeRoundedCheckmarkCircle02
                  : HugeIcons.strokeRoundedPauseCircle,
              isActive ? const Color(0xFF16A34A) : const Color(0xFFD97706),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orgRow(BuildContext context, String label, String value,
      List<List<dynamic>> icon, Color color) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          HugeIcon(icon: icon, size: 15, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: typography.body.xs2
                    .copyWith(color: colors.mutedForeground)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: context.theme.style.borderRadius.xs,
            ),
            child: Text(
              value,
              style: typography.body.xs3
                  .copyWith(fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }

  String _avatarUrl(String avatar) {
    if (avatar.isEmpty) return avatar;
    if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
      return avatar;
    }
    final base = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/api(/v1)?/?$'), '');
    var path = avatar.startsWith('/') ? avatar : '/$avatar';
    if (path.startsWith('/storage/')) path = '/public$path';
    return '$base$path';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
