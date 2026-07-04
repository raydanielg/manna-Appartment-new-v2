import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../features/landlord/payments/providers/payments_provider.dart';

class MyPaymentsScreen extends ConsumerWidget {
  const MyPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paymentsAsync = ref.watch(landlordPaymentsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: const Text('My Payments'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: paymentsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(landlordPaymentsProvider)),
        data: (payments) => payments.isEmpty
            ? const EmptyState(message: 'No payment records found.')
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  final p = payments[index];
                  return Card(
                    child: ListTile(
                      title: Text('TZS ', style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                      subtitle: Text(p['month_covered'] ?? '', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
                      trailing: Text(p['payment_date'] ?? '', style: const TextStyle(fontSize: 12)),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
