import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class IncomeChart extends StatelessWidget {
  final Map<String, dynamic> data;
  const IncomeChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthly = data['monthly_income'] ?? [];
    final cardColor = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark ? Colors.white10 : const Color(0xFFE5E7EB);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? null
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Income',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Last 6 months',
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (monthly.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No data available',
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.grey.shade400),
                  ),
                ),
              )
            else
              SizedBox(
                height: 140,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _buildBars(monthly, isDark),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBars(List<dynamic> monthly, bool isDark) {
    final amounts = monthly.map<double>((m) => (m['amount'] ?? 0).toDouble()).toList();
    final maxAmount = amounts.reduce((a, b) => a > b ? a : b);
    if (maxAmount == 0) return [];

    return monthly.map<Widget>((m) {
      final amount = (m['amount'] ?? 0).toDouble();
      final pct = (amount / maxAmount * 100).clamp(8.0, 100.0);
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: double.infinity,
                height: (pct / 100 * 100).clamp(10.0, 100.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xFF059669), Color(0xFF34D399)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                m['month'] ?? '',
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
