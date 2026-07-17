import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class SummaryCards extends StatelessWidget {
  final Map<String, dynamic> data;
  const SummaryCards({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthIncome = data['month_income'] ?? 0;
    final outstanding = data['outstanding'] ?? 0;

    final items = [
      _Item(
        label: 'Properties',
        value: '${data['properties_count'] ?? 0}',
        sub: 'Total managed',
        icon: Icons.apartment_outlined,
        customIcon: 'assets/icons/propertiesicon.png',
        color: const Color(0xFF0EA5E9),
      ),
      _Item(
        label: 'Tenants',
        value: '${data['tenants_count'] ?? 0}',
        sub: 'Active tenants',
        icon: Icons.people_alt_outlined,
        customIcon: 'assets/icons/tenantsicon.png',
        color: const Color(0xFF059669),
      ),
      _Item(
        label: 'Income',
        value: _formatAmount(monthIncome),
        sub: 'This month',
        icon: Icons.account_balance_wallet_outlined,
        customIcon: 'assets/icons/incomeicon.png',
        color: const Color(0xFFF59E0B),
      ),
      _Item(
        label: 'Outstanding',
        value: _formatAmount(outstanding),
        sub: 'Pending collection',
        icon: Icons.error_outline,
        customIcon: 'assets/icons/outstandingicon.png',
        color: const Color(0xFFEF4444),
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.3,
      children: items.map((i) => _buildCard(i, isDark)).toList(),
    );
  }

  String _formatAmount(dynamic amount) {
    final n = (amount is num) ? amount.toDouble() : double.tryParse('$amount') ?? 0.0;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toStringAsFixed(0);
  }

  Widget _buildCard(_Item item, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: item.customIcon != null
                      ? Padding(
                          padding: const EdgeInsets.all(6),
                          child: Image.asset(
                            item.customIcon!,
                            errorBuilder: (_, __, ___) => Icon(item.icon, color: item.color, size: 16),
                          ),
                        )
                      : Icon(item.icon, color: item.color, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.label,
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : AppColors.textLight,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.value,
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  item.sub,
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    color: isDark ? Colors.white38 : AppColors.textLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Item {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final String? customIcon;
  final Color color;

  _Item({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    this.customIcon,
    required this.color,
  });
}
