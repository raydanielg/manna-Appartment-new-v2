import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../providers/contracts_provider.dart';

class ContractDetailScreen extends ConsumerWidget {
  const ContractDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    final contractAsync = ref.watch(contractDetailProvider(id));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Contract Details'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: contractAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(contractDetailProvider(id))),
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
                    Text('Contract', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 8),
                    StatusBadge(status: contract['status'] ?? 'active'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSection(context, 'Tenant', contract['tenant']?['full_name'] ?? 'N/A', Icons.person),
              _buildSection(context, 'Unit', contract['unit']?['name'] ?? 'N/A', Icons.meeting_room),
              _buildSection(context, 'Start Date', contract['start_date'] ?? 'N/A', Icons.calendar_today),
              _buildSection(context, 'End Date', contract['end_date'] ?? 'N/A', Icons.event),
              _buildSection(context, 'Monthly Rent', 'TZS ', Icons.account_balance_wallet),
              _buildSection(context, 'Deposit', 'TZS ', Icons.savings),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'View PDF',
                      icon: const Icon(Icons.picture_as_pdf),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Terminate',
                      color: AppColors.error,
                      icon: const Icon(Icons.cancel),
                      onPressed: () async {
                        await ref.read(contractsRepositoryProvider).terminateContract(id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Contract terminated'), backgroundColor: AppColors.warning, behavior: SnackBarBehavior.floating),
                          );
                          context.pop();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String label, String value, IconData icon) {
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
