import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';

class SummaryCards extends StatelessWidget {
  final Map<String, dynamic> data;
  const SummaryCards({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final monthIncome = data['month_income'] ?? 0;
    final outstanding = data['outstanding'] ?? 0;

    final items = [
      _Item(
        label: context.tr('properties'),
        value: '${data['properties_count'] ?? 0}',
        sub: context.tr('total_managed'),
        icon: Icons.apartment_outlined,
        customIcon: 'assets/icons/propertiesicon.png',
        color: const Color(0xFF0EA5E9),
      ),
      _Item(
        label: context.tr('tenants'),
        value: '${data['tenants_count'] ?? 0}',
        sub: context.tr('active_tenants_short'),
        icon: Icons.people_alt_outlined,
        customIcon: 'assets/icons/tenantsicon.png',
        color: const Color(0xFF2563EB),
      ),
      _Item(
        label: context.tr('income'),
        value: _formatAmount(monthIncome),
        sub: context.tr('this_month'),
        icon: Icons.account_balance_wallet_outlined,
        customIcon: 'assets/icons/incomeicon.png',
        color: const Color(0xFFF59E0B),
      ),
      _Item(
        label: context.tr('outstanding'),
        value: _formatAmount(outstanding),
        sub: context.tr('pending_collection'),
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
      children: items.map((i) => _buildCard(i)).toList(),
    );
  }

  String _formatAmount(dynamic amount) {
    final n = (amount is num)
        ? amount.toDouble()
        : double.tryParse(amount?.toString() ?? '0') ?? 0.0;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toStringAsFixed(0);
  }

  Widget _buildCard(_Item item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                    color: item.color.withValues(alpha: 0.1),
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
                      color: AppColors.textLight,
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
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  item.sub,
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    color: AppColors.textLight,
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
