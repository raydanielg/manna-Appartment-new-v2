import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class SummaryCards extends StatelessWidget {
  final Map<String, dynamic> data;
  const SummaryCards({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = [
      _Item('Properties', data['properties_count'] ?? 0, Icons.apartment, AppColors.primary),
      _Item('Tenants', data['tenants_count'] ?? 0, Icons.people, AppColors.info),
      _Item('Income', data['month_income'] ?? 0, Icons.account_balance_wallet, AppColors.success),
      _Item('Outstanding', data['outstanding'] ?? 0, Icons.warning_amber, AppColors.warning),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: items.map((i) => _buildCard(context, i, isDark)).toList(),
    );
  }

  Widget _buildCard(BuildContext context, _Item item, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.value.toString(),
                  style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark),
                ),
                const SizedBox(height: 2),
                Text(item.label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
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
  final dynamic value;
  final IconData icon;
  final Color color;
  _Item(this.label, this.value, this.icon, this.color);
}
