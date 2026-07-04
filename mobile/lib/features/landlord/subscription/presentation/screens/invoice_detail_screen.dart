import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> invoice;
  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plan = invoice['plan'] ?? {};
    final planName = plan['name']?.toString() ?? 'Subscription';
    final amount = invoice['amount'] ?? 0;
    final status = invoice['status']?.toString() ?? 'unknown';
    final paid = status == 'active' || status == 'paid';
    final startDate = invoice['start_date']?.toString() ?? '-';
    final endDate = invoice['end_date']?.toString() ?? '-';
    final reference = invoice['payment_reference']?.toString() ?? '-';
    final createdAt = invoice['created_at']?.toString() ?? '-';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Receipt'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/landlord/subscription');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: paid ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: paid ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(paid ? Icons.check_circle : Icons.pending, size: 64, color: paid ? Colors.green : Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    paid ? 'PAID' : 'PENDING',
                    style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: paid ? Colors.green : Colors.red),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    planName,
                    style: GoogleFonts.nunito(fontSize: 16, color: isDark ? Colors.white : AppColors.textDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Amount'),
            _buildInfoCard(context, amount == 0 ? 'FREE' : 'TZS $amount'),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Period'),
            _buildInfoCard(context, '$startDate to $endDate'),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Payment Reference'),
            _buildInfoCard(context, reference),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Issued On'),
            _buildInfoCard(context, createdAt == '-' ? '-' : createdAt.substring(0, 10)),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => context.go('/landlord/subscription'),
              icon: const Icon(Icons.subscriptions),
              label: const Text('Back to Subscription'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? Colors.white60 : AppColors.textLight),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        value,
        style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textDark),
      ),
    );
  }
}
