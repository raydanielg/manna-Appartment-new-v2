import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class LandlordHelpScreen extends StatelessWidget {
  const LandlordHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('How to Use', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCard(
            context,
            title: '1. Subscription Plan',
            steps: ['Start with a free trial or choose a plan.', 'Pay to unlock SMS, contracts and full features.', 'View your active plan under Subscription.'],
          ),
          _buildCard(
            context,
            title: '2. Add Property & Unit',
            steps: ['Go to Properties > Add property.', 'Add units with rent and numbers.', 'Units show as vacant or occupied.'],
          ),
          _buildCard(
            context,
            title: '3. Add Tenant',
            steps: ['Go to Tenants > Add tenant.', 'Select a vacant unit and move-in date.', 'Tenant receives SMS with login details.'],
          ),
          _buildCard(
            context,
            title: '4. Record Payments',
            steps: ['Go to Payments > Record.', 'Select tenant, contract and payment type (rent, water, electricity, other).', 'Amount, date and month are saved automatically.'],
          ),
          _buildCard(
            context,
            title: '5. Contracts & Signatures',
            steps: ['Create digital or manual contract.', 'For manual, download Word template.', 'Sign digital contracts with finger signature and get PDF.'],
          ),
          _buildCard(
            context,
            title: '6. SMS Broadcast',
            steps: ['Go to More > SMS Broadcast.', 'Choose group: all, active, overdue or custom numbers.', 'Pick a template or type message, then send.'],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required List<String> steps}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark)),
          const SizedBox(height: 8),
          ...steps.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, size: 14, color: AppColors.success),
                const SizedBox(width: 8),
                Expanded(child: Text(s, style: GoogleFonts.nunito(fontSize: 13, color: isDark ? Colors.white70 : AppColors.textLight))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
