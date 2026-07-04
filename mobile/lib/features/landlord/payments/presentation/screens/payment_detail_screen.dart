import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/status_badge.dart';

class PaymentDetailScreen extends StatelessWidget {
  const PaymentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Payment Details'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.success, AppColors.primary]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Amount', style: TextStyle(fontSize: 14, color: Colors.white70)),
                  Text('TZS 350,000', style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 8),
                  const StatusBadge(status: 'completed'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildRow(context, Icons.person, 'Tenant', 'John Doe'),
            _buildRow(context, Icons.meeting_room, 'Unit', 'A-101'),
            _buildRow(context, Icons.calendar_today, 'Date', '2026-07-04'),
            _buildRow(context, Icons.payment, 'Method', 'Mobile Money'),
            _buildRow(context, Icons.receipt, 'Reference', 'REF-'),
            _buildRow(context, Icons.calendar_month, 'Month Covered', 'July 2026'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.info),
                icon: const Icon(Icons.receipt_long),
                label: const Text('View Receipt'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
        trailing: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
      ),
    );
  }
}
