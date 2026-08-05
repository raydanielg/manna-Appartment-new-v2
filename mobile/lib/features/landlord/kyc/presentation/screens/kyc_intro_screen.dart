import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../features/auth/providers/auth_provider.dart';

class KycIntroScreen extends ConsumerStatefulWidget {
  const KycIntroScreen({super.key});

  @override
  ConsumerState<KycIntroScreen> createState() => _KycIntroScreenState();
}

class _KycIntroScreenState extends ConsumerState<KycIntroScreen> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    await ref.read(authProvider.notifier).refreshFullProfile();
    if (!mounted) return;
    final authState = ref.read(authProvider);
    final user = authState.user;

    if (authState.isKycApproved) {
      context.go('/landlord/home');
      return;
    }

    if (user != null && user.organizationId == null) {
      context.go('/landlord/kyc/organization-setup');
      return;
    }

    setState(() => _isChecking = false);
  }

  void _startVerification() {
    context.go('/landlord/kyc/upload');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Color(0xFF111827)),
              onPressed: () => context.go('/settings'),
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Color(0xFF111827)),
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/auth/login');
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _isChecking
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.verified_user_rounded, size: 64, color: Color(0xFF2563EB)),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Verification Required',
                  style: GoogleFonts.nunito(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your account "${user?.businessName ?? user?.fullName ?? ''}" is pending verification. To access your landlord dashboard, we need to verify your identity.',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color: const Color(0xFF4B5563),
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _startVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Start Verification',
                      style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
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
}
