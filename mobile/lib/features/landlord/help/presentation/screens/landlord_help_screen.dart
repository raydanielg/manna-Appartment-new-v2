import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../../core/localization/app_localizations.dart';

class LandlordHelpScreen extends StatelessWidget {
  const LandlordHelpScreen({super.key});

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
          context.tr('how_to_use'),
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
        padding: const EdgeInsets.all(20),
        children: [
          _card(
            context,
            colors,
            typography,
            title: context.tr('subscription_plan_help'),
            steps: [
              'Start with a free trial or choose a plan.',
              'Pay to unlock SMS, contracts and full features.',
              'View your active plan under Subscription.',
            ],
          ),
          _card(
            context,
            colors,
            typography,
            title: context.tr('add_property_unit_help'),
            steps: [
              'Go to Properties > Add property.',
              'Add units with rent and numbers.',
              'Units show as vacant or occupied.',
            ],
          ),
          _card(
            context,
            colors,
            typography,
            title: context.tr('add_tenant_help'),
            steps: [
              'Go to Tenants > Add tenant.',
              'Select a vacant unit and move-in date.',
              'Tenant receives SMS with login details.',
            ],
          ),
          _card(
            context,
            colors,
            typography,
            title: context.tr('record_payments_help'),
            steps: [
              'Go to Payments > Record.',
              'Select tenant, contract and payment type (rent, water, electricity, other).',
              'Amount, date and month are saved automatically.',
            ],
          ),
          _card(
            context,
            colors,
            typography,
            title: context.tr('contracts_signatures_help'),
            steps: [
              'Create digital or manual contract.',
              'For manual, download Word template.',
              'Sign digital contracts with finger signature and get PDF.',
            ],
          ),
          _card(
            context,
            colors,
            typography,
            title: context.tr('sms_broadcast_help'),
            steps: [
              'Go to More > SMS Broadcast.',
              'Choose group: all, active, overdue or custom numbers.',
              'Pick a template or type message, then send.',
            ],
          ),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context,
    FColors colors,
    FTypography typography, {
    required String title,
    required List<String> steps,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FCard(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    typography.body.sm.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...steps.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                          size: 15,
                          color: const Color(0xFF16A34A),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s,
                            style: typography.body.xs2.copyWith(
                                color: colors.mutedForeground, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
