import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    final sections = [
      ('Introduction', 'Manna Apartment is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.'),
      ('Information We Collect', 'We collect personal information such as your name, phone number, email address, property details, tenant information, payment records, and KYC documents. We also collect device and usage data to improve our services.'),
      ('How We Use Your Information', 'We use your information to provide property management services, process payments, send SMS notifications, verify identities, improve our platform, and comply with legal obligations.'),
      ('Sharing of Information', 'We do not sell your personal information. We may share data with trusted service providers for payment processing, SMS delivery, and cloud hosting, and when required by law.'),
      ('Data Security', 'We implement appropriate technical and organizational measures to protect your data. However, no method of transmission over the internet is 100% secure.'),
      ('Your Rights', 'You have the right to access, update, or delete your personal information. Contact us through Help & Support to make such requests.'),
      ('Changes to This Policy', 'We may update this Privacy Policy from time to time. We will notify you of significant changes through the app or by email.'),
      ('Contact Us', 'If you have any questions, please contact us at support@mannaapartment.co.tz or +255 700 000 000.'),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('privacy_policy'),
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            context.tr('app_name'),
            style: typography.display.sm.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Effective Date: July 2026',
            style: typography.body.xs2.copyWith(color: colors.mutedForeground),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: colors.border.withValues(alpha: 0.6)),
          const SizedBox(height: 8),
          for (var i = 0; i < sections.length; i++)
            _section(context, i + 1, sections[i].$1, sections[i].$2),
          const SizedBox(height: 8),
          Divider(height: 1, color: colors.border.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text(
            '© 2026 Manna Apartment Ltd. All rights reserved.',
            textAlign: TextAlign.center,
            style: typography.body.xs3.copyWith(color: colors.mutedForeground),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, int number, String title, String body) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colors.secondary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: typography.body.xs3.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.secondaryForeground,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.body.sm.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: typography.body.xs2.copyWith(
                    color: colors.mutedForeground,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
