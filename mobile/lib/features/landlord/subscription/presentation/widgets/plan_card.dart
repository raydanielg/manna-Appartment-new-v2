import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';

class PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isCurrent;
  final VoidCallback? onSelect;
  const PlanCard(
      {super.key, required this.plan, this.isCurrent = false, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final radii = context.theme.style.borderRadius;

    final features = (plan['features_json'] as List<dynamic>? ??
        (plan['features'] as List<dynamic>? ?? []));
    final billingCycle = plan['billing_cycle']?.toString() ?? 'monthly';
    final isTrial = billingCycle == 'trial';
    final price = (plan['price'] is num
        ? (plan['price'] as num).toDouble()
        : double.tryParse(plan['price']?.toString() ?? '0') ?? 0.0);
    final propertyLimit = plan['property_limit'] ?? 0;
    final unitLimit = plan['unit_limit'] ?? 0;
    final smsIncluded = plan['sms_included'] ?? 0;
    final planName = plan['name']?.toString() ?? 'Plan';
    final accent = isTrial ? const Color(0xFFD97706) : colors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: radii.lg,
          border: Border.all(
            color: isCurrent ? colors.primary : colors.border,
            width: isCurrent ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.1),
                            borderRadius: radii.md,
                          ),
                          child: Center(
                            child: HugeIcon(
                              icon: isTrial
                                  ? HugeIcons.strokeRoundedZap
                                  : HugeIcons.strokeRoundedCrown,
                              size: 20,
                              color: accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            planName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.body.lg
                                .copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                        borderRadius: radii.pill,
                      ),
                      child: Text(
                        'CURRENT',
                        style: typography.body.xs3.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isTrial ? 'FREE' : 'TZS ${price.toStringAsFixed(0)}',
                    style: typography.display.xl.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      isTrial ? '3 days' : '/ ${billingCycle.replaceAll('ly', '')}',
                      style: typography.body.xs2
                          .copyWith(color: colors.mutedForeground),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              Divider(height: 1, color: colors.border.withValues(alpha: 0.6)),
              const SizedBox(height: 14),

              // Limits
              Row(
                children: [
                  _limit(colors, typography, HugeIcons.strokeRoundedBuilding03,
                      'Properties',
                      propertyLimit == 0
                          ? 'Unlimited'
                          : propertyLimit.toString()),
                  _vDivider(colors),
                  _limit(colors, typography, HugeIcons.strokeRoundedDoor01,
                      'Units',
                      unitLimit == 0 ? 'Unlimited' : unitLimit.toString()),
                  _vDivider(colors),
                  _limit(colors, typography, HugeIcons.strokeRoundedMessage01,
                      'SMS', smsIncluded.toString()),
                ],
              ),

              // Features
              if (features.isNotEmpty) ...[
                const SizedBox(height: 16),
                Divider(
                    height: 1, color: colors.border.withValues(alpha: 0.6)),
                const SizedBox(height: 12),
                ...features.map((f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                            size: 15,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _formatFeature(f.toString()),
                              style: typography.body.xs2
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],

              const SizedBox(height: 18),
              if (!isCurrent)
                FButton(
                  variant: .primary,
                  onPress: onSelect,
                  child:
                      Text(isTrial ? 'Start Free Trial' : 'Select Plan'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vDivider(FColors colors) => Container(
        width: 1,
        height: 36,
        color: colors.border.withValues(alpha: 0.6),
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );

  Widget _limit(FColors colors, FTypography typography,
      List<List<dynamic>> icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          HugeIcon(icon: icon, size: 16, color: colors.primary),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.body.sm.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style:
                typography.body.xs3.copyWith(color: colors.mutedForeground),
          ),
        ],
      ),
    );
  }

  String _formatFeature(String f) {
    return f
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
