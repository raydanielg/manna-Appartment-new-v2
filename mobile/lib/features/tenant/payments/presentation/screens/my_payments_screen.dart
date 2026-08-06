import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../providers/payments_provider.dart';

class MyPaymentsScreen extends ConsumerWidget {
  const MyPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(myPaymentsProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(title: Text('My Payments', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myPaymentsProvider),
        color: AppColors.primary,
        child: paymentsAsync.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) {
            if (e is DioException && e.response?.statusCode == 404) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(color: AppColors.textLight.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.payments_outlined, size: 36, color: AppColors.textLight),
                      ),
                      const SizedBox(height: 20),
                      Text('No Payments Yet', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                      const SizedBox(height: 8),
                      Text('Your payment history will appear here once your landlord sets up your account.', textAlign: TextAlign.center, style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textLight, height: 1.5)),
                    ],
                  ),
                ),
              );
            }
            return ErrorState(message: e.toString(), onRetry: () => ref.invalidate(myPaymentsProvider));
          },
          data: (payments) => payments.isEmpty
              ? const EmptyState(message: 'No payment records found.', icon: Icons.payments_outlined)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final p = payments[index];
                    final amount = p['amount'] ?? 0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.payments, color: AppColors.success, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('TZS ${amount.toStringAsFixed(0)}', style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                                  const SizedBox(height: 4),
                                  Text(p['month_covered'] ?? p['payment_date'] ?? '', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textLight)),
                                ],
                              ),
                            ),
                            StatusBadge(status: p['status'] ?? 'confirmed'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
