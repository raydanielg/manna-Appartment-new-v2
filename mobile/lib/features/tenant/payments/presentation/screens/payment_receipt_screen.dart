import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/widgets/status_badge.dart';

class PaymentReceiptScreen extends StatelessWidget {
  const PaymentReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Receipt'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(24)),
                child: const Icon(Icons.receipt_long, size: 40, color: AppColors.success),
              ),
            ),
            const SizedBox(height: 16),
            Center(child: Text('Payment Receipt', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark))),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  _buildRow(context, 'Receipt #', 'RCP-$id'),
                  const Divider(height: 1, indent: 16),
                  _buildRow(context, 'Amount', 'TZS 350,000'),
                  const Divider(height: 1, indent: 16),
                  _buildRow(context, 'Date', '2026-07-04'),
                  const Divider(height: 1, indent: 16),
                  _buildRow(context, 'Method', 'Mobile Money'),
                  const Divider(height: 1, indent: 16),
                  _buildRow(context, 'Reference', 'REF-$id'),
                  const Divider(height: 1, indent: 16),
                  _buildRow(context, 'Month', 'July 2026'),
                  const Divider(height: 1, indent: 16),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status', style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : AppColors.textLight)),
                        const StatusBadge(status: 'completed'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'Download',
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Downloading receipt...'), backgroundColor: AppColors.info, behavior: SnackBarBehavior.floating),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: 'Share',
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sharing receipt...'), backgroundColor: AppColors.info, behavior: SnackBarBehavior.floating),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : AppColors.textLight)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
        ],
      ),
    );
  }
}
