import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sections = [
      {
        'title': '1. Acceptance of Terms',
        'body': 'By downloading, installing, or using Manna Apartment, you agree to be bound by these Terms of Service. If you do not agree, do not use the app.',
      },
      {
        'title': '2. Use of Services',
        'body': 'Manna Apartment provides tools for landlords and tenants to manage properties, units, payments, contracts, and maintenance requests. You agree to use the services only for lawful purposes.',
      },
      {
        'title': '3. Account Registration',
        'body': 'You must provide accurate and complete information when creating an account. You are responsible for maintaining the confidentiality of your login credentials.',
      },
      {
        'title': '4. Subscription and Payments',
        'body': 'Some features require an active subscription. Payments are processed through mobile money providers. Subscriptions renew automatically unless canceled before the renewal date.',
      },
      {
        'title': '5. User Content',
        'body': 'You retain ownership of the data you upload. By using the app, you grant us a license to host and process your data solely to provide the service.',
      },
      {
        'title': '6. Prohibited Conduct',
        'body': 'You may not misuse the app, attempt to access unauthorized data, distribute harmful code, or use the platform for fraudulent activities.',
      },
      {
        'title': '7. Termination',
        'body': 'We may suspend or terminate your account if you violate these terms or if your organization becomes inactive. You may also delete your account at any time.',
      },
      {
        'title': '8. Limitation of Liability',
        'body': 'Manna Apartment is provided as-is without warranties. We are not liable for indirect, incidental, or consequential damages arising from your use of the app.',
      },
      {
        'title': '9. Changes to Terms',
        'body': 'We may modify these terms at any time. Continued use of the app after changes constitutes acceptance of the updated terms.',
      },
      {
        'title': '10. Contact',
        'body': 'For questions about these terms, contact us at support@mannaapartment.co.tz or +255 700 000 000.',
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF3F4F6),
        elevation: 0,
        title: Text('Terms of Service', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
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
                    'Terms of Service',
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
