import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sections = [
      {
        'title': '1. Introduction',
        'body': 'Manna Apartment is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.',
      },
      {
        'title': '2. Information We Collect',
        'body': 'We collect personal information such as your name, phone number, email address, property details, tenant information, payment records, and KYC documents. We also collect device and usage data to improve our services.',
      },
      {
        'title': '3. How We Use Your Information',
        'body': 'We use your information to provide property management services, process payments, send SMS notifications, verify identities, improve our platform, and comply with legal obligations.',
      },
      {
        'title': '4. Sharing of Information',
        'body': 'We do not sell your personal information. We may share data with trusted service providers for payment processing, SMS delivery, and cloud hosting, and when required by law.',
      },
      {
        'title': '5. Data Security',
        'body': 'We implement appropriate technical and organizational measures to protect your data. However, no method of transmission over the internet is 100% secure.',
      },
      {
        'title': '6. Your Rights',
        'body': 'You have the right to access, update, or delete your personal information. Contact us through Help & Support to make such requests.',
      },
      {
        'title': '7. Changes to This Policy',
        'body': 'We may update this Privacy Policy from time to time. We will notify you of significant changes through the app or by email.',
      },
      {
        'title': '8. Contact Us',
        'body': 'If you have any questions, please contact us at support@mannaapartment.co.tz or +255 700 000 000.',
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF3F4F6),
        elevation: 0,
        title: Text('Privacy Policy', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.apartment, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Manna Apartment',
                    style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Privacy Policy',
                    style: GoogleFonts.nunito(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Effective Date: July 2026',
                    style: GoogleFonts.nunito(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  ...sections.map((s) => _buildSection(context, s['title']!, s['body']!)),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    '© 2026 Manna Apartment Ltd. All rights reserved.',
                    style: GoogleFonts.nunito(fontSize: 11, color: isDark ? Colors.white60 : AppColors.textLight),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String body) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: GoogleFonts.nunito(fontSize: 13, height: 1.6, color: isDark ? Colors.white70 : AppColors.textLight),
          ),
        ],
      ),
    );
  }
}
