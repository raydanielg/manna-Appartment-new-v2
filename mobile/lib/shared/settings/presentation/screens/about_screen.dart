import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        title: Text('About', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.apartment, size: 56, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Manna Apartment',
              style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: GoogleFonts.nunito(fontSize: 14, color: isDark ? Colors.white70 : AppColors.textLight),
            ),
            const SizedBox(height: 32),
            _buildCard(
              context,
              children: [
                _buildInfoRow(context, 'Company', 'Manna Apartment Ltd'),
                const Divider(height: 1),
                _buildInfoRow(context, 'Website', 'www.mannaapartment.co.tz'),
                const Divider(height: 1),
                _buildInfoRow(context, 'Email', 'support@mannaapartment.co.tz'),
                const Divider(height: 1),
                _buildInfoRow(context, 'Phone', '+255 700 000 000'),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Manna Apartment helps landlords manage properties, tenants, payments, and maintenance with ease. Built for the Tanzanian market.',
              style: GoogleFonts.nunito(fontSize: 14, color: isDark ? Colors.white70 : AppColors.textLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.nunito(fontSize: 14, color: isDark ? Colors.white70 : AppColors.textLight)),
          Text(value, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
        ],
      ),
    );
  }
}
