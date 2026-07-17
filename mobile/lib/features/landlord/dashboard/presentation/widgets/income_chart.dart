import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class IncomeChart extends StatelessWidget {
  final Map<String, dynamic> data;
  const IncomeChart({super.key, required this.data});

  double _parseAmount(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rawMonthly = data['monthly_income'];
    final monthly = (rawMonthly is List) ? rawMonthly : <dynamic>[];
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? Colors.white10 : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
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
                    style: GoogleFonts.nunito(fontSize: 13, color: isDark ? Colors.white38 : Colors.grey.shade400),
                  ),
                ),
              )
            else
              SizedBox(
                height: 160,
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
    final amounts = monthly.map<double>((m) => _parseAmount(m['amount'])).toList();
    final maxAmount = amounts.isNotEmpty ? amounts.reduce((a, b) => a > b ? a : b) : 0.0;

    return monthly.asMap().entries.map<Widget>((entry) {
      final i = entry.key;
      final m = entry.value;
      final amount = _parseAmount(m['amount']);
      final pct = maxAmount > 0
          ? (amount / maxAmount * 100).clamp(8.0, 100.0)
          : 8.0;
      final isHighest = maxAmount > 0 && amount == maxAmount;

      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _formatAmount(amount),
                style: GoogleFonts.nunito(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isHighest
                      ? const Color(0xFF059669)
                      : (isDark ? Colors.white54 : AppColors.textLight),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                height: (pct / 100 * 110).clamp(12.0, 110.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: isHighest
                        ? [const Color(0xFF059669), const Color(0xFF34D399)]
                        : [const Color(0xFF059669).withValues(alpha: 0.5), const Color(0xFF34D399).withValues(alpha: 0.5)],
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
