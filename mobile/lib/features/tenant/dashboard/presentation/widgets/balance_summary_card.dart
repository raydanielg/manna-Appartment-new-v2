import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Balance Summary', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 12),
            _buildRow('Total Paid', 'TZS ${_formatAmount(totalPaid)}', AppColors.success),
            const Divider(),
            _buildRow('Total Due', 'TZS ${_formatAmount(totalDue)}', AppColors.warning),
            const Divider(),
            _buildRow('Balance', 'TZS ${_formatAmount(balance)}', AppColors.primary),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0);
  }

  Widget _buildRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}
