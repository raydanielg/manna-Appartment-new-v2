import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/localization/app_localizations.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    final faqs = [
      (context.tr('faq_q1'), context.tr('faq_a1')),
      (context.tr('faq_q2'), context.tr('faq_a2')),
      (context.tr('faq_q3'), context.tr('faq_a3')),
      (context.tr('faq_q4'), context.tr('faq_a4')),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('help_support'),
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
            context.tr('need_help'),
            style: typography.display.sm.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('contact_support'),
            style: typography.body.xs2
                .copyWith(color: colors.mutedForeground, height: 1.5),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: colors.border.withValues(alpha: 0.6)),
          _contactRow(
            context,
            icon: HugeIcons.strokeRoundedCall,
            title: context.tr('call_us'),
            value: '+255 734 070 202',
          ),
          _divider(context),
          _contactRow(
            context,
            icon: HugeIcons.strokeRoundedMail01,
            title: context.tr('email_us'),
            value: 'support@mannaapartment.co.tz',
          ),
          _divider(context),
          _contactRow(
            context,
            icon: HugeIcons.strokeRoundedWhatsapp,
            title: context.tr('whatsapp'),
            value: '+255 734 070 202',
          ),
          Divider(height: 1, color: colors.border.withValues(alpha: 0.6)),
          const SizedBox(height: 24),
          Text(
            context.tr('faq').toUpperCase(),
            style: typography.body.xs3.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
          FAccordion(
            children: [
              for (final (q, a) in faqs)
                FAccordionItem(
                  title: Text(q),
                  child: Text(
                    a,
                    style: typography.body.xs2.copyWith(
                      color: colors.mutedForeground,
                      height: 1.55,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Divider(
      height: 1,
      color: context.theme.colors.border.withValues(alpha: 0.6));

  Widget _contactRow(
    BuildContext context, {
    required List<List<dynamic>> icon,
    required String title,
    required String value,
  }) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          HugeIcon(icon: icon, size: 18, color: colors.mutedForeground),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.body.xs3
                      .copyWith(color: colors.mutedForeground),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.body.sm
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
