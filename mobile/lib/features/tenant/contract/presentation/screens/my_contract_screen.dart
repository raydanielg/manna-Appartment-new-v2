import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../providers/contract_provider.dart';

class MyContractScreen extends ConsumerWidget {
  const MyContractScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contractAsync = ref.watch(myContractProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: const Text('My Contract'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: contractAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(myContractProvider)),
        data: (contract) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.info, AppColors.primary]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Contract', style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 8),
                    const StatusBadge(status: 'active'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildRow(context, Icons.calendar_today, 'Start Date', contract['start_date'] ?? 'N/A'),
              _buildRow(context, Icons.event, 'End Date', contract['end_date'] ?? 'N/A'),
              _buildRow(context, Icons.account_balance_wallet, 'Monthly Rent', 'TZS ${contract['monthly_rent'] ?? 0}'),
              _buildRow(context, Icons.savings, 'Deposit', 'TZS ${contract['deposit'] ?? 0}'),
              if (contract['unit'] != null)
                _buildRow(context, Icons.meeting_room, 'Unit', contract['unit']['name'] ?? 'N/A'),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'View Contract PDF',
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: () => context.push('/tenant/contract/pdf'),
              ),
            ],
          ),
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

