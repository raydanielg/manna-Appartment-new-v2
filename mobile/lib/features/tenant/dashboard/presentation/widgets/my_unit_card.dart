import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class MyUnitCard extends StatelessWidget {
  const MyUnitCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My Unit', style: TextStyle(fontSize: 14, color: Colors.white70)),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)), child: const Text('ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))),
              ],
            ),
            const SizedBox(height: 12),
            Text('Not assigned', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStat(Icons.calendar_today, 'Rent Due', 'TZS 0')),
                Expanded(child: _buildStat(Icons.account_balance_wallet, 'Balance', 'TZS 0')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)), Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))],
        ),
      ],
    );
  }
}
