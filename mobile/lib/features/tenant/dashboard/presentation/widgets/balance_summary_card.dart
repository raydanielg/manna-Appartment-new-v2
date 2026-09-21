import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';

class BalanceSummaryCard extends StatelessWidget {
  final double totalPaid;
  final double totalDue;
  final double balance;

  const BalanceSummaryCard({
    super.key,
    this.totalPaid = 0,
    this.totalDue = 0,
    this.balance = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final fmt = NumberFormat('#,###');

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            _row(colors, typography, 'Total Paid', 'TZS ${fmt.format(totalPaid)}',
                const Color(0xFF16A34A)),
            Divider(height: 1, color: colors.border.withValues(alpha: 0.6)),
            _row(colors, typography, 'Total Due', 'TZS ${fmt.format(totalDue)}',
                const Color(0xFFD97706)),
            Divider(height: 1, color: colors.border.withValues(alpha: 0.6)),
            _row(colors, typography, 'Balance', 'TZS ${fmt.format(balance)}',
                colors.primary),
          ],
        ),
      ),
    );
  }

  Widget _row(FColors colors, FTypography typography, String label,
      String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: typography.body.xs2
                  .copyWith(color: colors.mutedForeground),
            ),
          ),
          Text(
            value,
            style: typography.body.sm.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
