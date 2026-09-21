import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('about'),
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
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          // Logo
          Center(
            child: ClipRRect(
              borderRadius: context.theme.style.borderRadius.xl,
              child: Image.asset(
                'assets/images/app_logo.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              context.tr('app_name'),
              style:
                  typography.display.sm.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '${context.tr('version')} 3.4.0+9',
              style:
                  typography.body.xs2.copyWith(color: colors.mutedForeground),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              context.tr('about_description'),
              textAlign: TextAlign.center,
              style: typography.body.xs2.copyWith(
                color: colors.mutedForeground,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Divider(height: 1, color: colors.border.withValues(alpha: 0.6)),
          _row(context, context.tr('company'), 'Manna Apartment Ltd'),
          _divider(context),
          _row(context, context.tr('website'), 'www.mannaapartment.co.tz'),
          _divider(context),
          _row(context, context.tr('email'), 'support@mannaapartment.co.tz'),
          _divider(context),
          _row(context, context.tr('phone'), '+255 734 070 202'),
          Divider(height: 1, color: colors.border.withValues(alpha: 0.6)),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '© 2026 Manna Apartment Ltd. All rights reserved.',
              textAlign: TextAlign.center,
              style:
                  typography.body.xs3.copyWith(color: colors.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Divider(
      height: 1,
      color: context.theme.colors.border.withValues(alpha: 0.6));

  Widget _row(BuildContext context, String label, String value) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                typography.body.xs2.copyWith(color: colors.mutedForeground),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.body.xs2.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
