import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SummaryCards extends StatelessWidget {
  final Map<String, dynamic> data;
  const SummaryCards({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final monthIncome = data['month_income'] ?? 0;
    final outstanding = data['outstanding'] ?? 0;

    final items = [
      _Item(
        label: 'Properties',
        value: '${data['properties_count'] ?? 0}',
        sub: 'Total managed',
        icon: Icons.apartment_outlined,
        gradientStart: const Color(0xFF0EA5E9),
        gradientEnd: const Color(0xFF0284C7),
        borderColor: const Color(0xFF38BDF8),
      ),
      _Item(
        label: 'Tenants',
        value: '${data['tenants_count'] ?? 0}',
        sub: 'Active tenants',
        icon: Icons.people_alt_outlined,
        gradientStart: const Color(0xFF059669),
        gradientEnd: const Color(0xFF047857),
        borderColor: const Color(0xFF34D399),
      ),
      _Item(
        label: 'Income',
        value: _formatAmount(monthIncome),
        sub: 'This month',
        icon: Icons.account_balance_wallet_outlined,
        gradientStart: const Color(0xFFF59E0B),
        gradientEnd: const Color(0xFFD97706),
        borderColor: const Color(0xFFFBBF24),
      ),
      _Item(
        label: 'Outstanding',
        value: _formatAmount(outstanding),
        sub: 'Pending collection',
        icon: Icons.error_outline,
        gradientStart: const Color(0xFFEF4444),
        gradientEnd: const Color(0xFFDC2626),
        borderColor: const Color(0xFFF87171),
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: items.map((i) => _buildCard(i)).toList(),
    );
  }

  String _formatAmount(dynamic amount) {
    final n = (amount is num) ? amount.toDouble() : double.tryParse('$amount') ?? 0.0;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toStringAsFixed(0);
  }

  Widget _buildCard(_Item item) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [item.gradientStart, item.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.borderColor.withValues(alpha: 0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: item.gradientStart.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -12,
            right: -12,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                    Icon(item.icon, color: Colors.white.withValues(alpha: 0.7), size: 20),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.value,
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.sub,
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Item {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color gradientStart;
  final Color gradientEnd;
  final Color borderColor;

  _Item({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.gradientStart,
    required this.gradientEnd,
    required this.borderColor,
  });
}
