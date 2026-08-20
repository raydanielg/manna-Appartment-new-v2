import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/contracts_provider.dart';
import '../widgets/contract_card.dart';

class ContractsListScreen extends ConsumerWidget {
  const ContractsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(contractsListProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(context.tr('contracts')),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(contractsListProvider),
        color: AppColors.primary,
        child: contractsAsync.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) => ErrorState(message: AppError.getMessage(e), onRetry: () => ref.invalidate(contractsListProvider)),
          data: (contracts) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildNewContractCard(context),
              const SizedBox(height: 16),
              if (contracts.isEmpty)
                EmptyState(message: context.tr('no_contracts_tap'), icon: Icons.description_outlined)
              else
                ...contracts.map((c) => ContractCard(contract: c)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewContractCard(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/landlord/contracts/create'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('new_contract'),
                      style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('create_new_contract'),
                      style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
