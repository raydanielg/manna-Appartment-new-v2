import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class MyUnitCard extends StatelessWidget {
  final Map<String, dynamic>? unit;
  final double? rentAmount;
  final double? balance;

  const MyUnitCard({
    super.key,
    this.unit,
    this.rentAmount,
    this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final fmt = NumberFormat('#,###');
    final unitName = unit?['name']?.toString() ?? 'Not assigned';
    final propertyName = unit?['property']?.toString();
    final hasUnit = unit != null;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedDoor01,
                  size: 18,
                  color: colors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'My Unit',
                    style: typography.body.sm
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  hasUnit ? 'ACTIVE' : 'NONE',
                  style: typography.body.xs3.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: hasUnit
                        ? const Color(0xFF16A34A)
                        : colors.mutedForeground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              unitName,
              style: typography.display.sm.copyWith(fontWeight: FontWeight.w800),
            ),
            if (propertyName != null && propertyName.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                propertyName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.body.xs2
                    .copyWith(color: colors.mutedForeground),
              ),
            ],
            const SizedBox(height: 14),
            Divider(height: 1, color: colors.border.withValues(alpha: 0.6)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _stat(colors, typography, 'Rent Due',
                      'TZS ${fmt.format(rentAmount ?? 0)}'),
                ),
                Container(
                    width: 1,
                    height: 28,
                    color: colors.border.withValues(alpha: 0.6)),
                const SizedBox(width: 16),
                Expanded(
                  child: _stat(colors, typography, 'Balance',
                      'TZS ${fmt.format(balance ?? 0)}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(
      FColors colors, FTypography typography, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              typography.body.xs3.copyWith(color: colors.mutedForeground),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: typography.body.sm.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
