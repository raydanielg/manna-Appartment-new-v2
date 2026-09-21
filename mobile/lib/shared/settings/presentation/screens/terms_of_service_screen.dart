import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    final sections = [
      ('Acceptance of Terms', 'By downloading, installing, or using Manna Apartment, you agree to be bound by these Terms of Service. If you do not agree, do not use the app.'),
      ('Use of Services', 'Manna Apartment provides tools for landlords and tenants to manage properties, units, payments, contracts, and maintenance requests. You agree to use the services only for lawful purposes.'),
      ('Account Registration', 'You must provide accurate and complete information when creating an account. You are responsible for maintaining the confidentiality of your login credentials.'),
      ('Subscription and Payments', 'Some features require an active subscription. Payments are processed through mobile money providers. Subscriptions renew automatically unless canceled before the renewal date.'),
      ('User Content', 'You retain ownership of the data you upload. By using the app, you grant us a license to host and process your data solely to provide the service.'),
      ('Prohibited Conduct', 'You may not misuse the app, attempt to access unauthorized data, distribute harmful code, or use the platform for fraudulent activities.'),
      ('Termination', 'We may suspend or terminate your account if you violate these terms or if your organization becomes inactive. You may also delete your account at any time.'),
      ('Limitation of Liability', 'Manna Apartment is provided as-is without warranties. We are not liable for indirect, incidental, or consequential damages arising from your use of the app.'),
      ('Changes to Terms', 'We may modify these terms at any time. Continued use of the app after changes constitutes acceptance of the updated terms.'),
      ('Contact', 'For questions about these terms, contact us at support@mannaapartment.co.tz or +255 700 000 000.'),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('terms_of_service'),
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
