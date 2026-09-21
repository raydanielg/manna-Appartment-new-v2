import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
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
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('contracts'),
          style: typography.display.md.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: FButton.icon(
          variant: .ghost,
          size: .sm,
          onPress: () {
            if (context.canPop()) context.pop();
          },
          child: context.theme.icons.arrowLeft(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(contractsListProvider),
        color: colors.primary,
        child: contractsAsync.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) => ErrorState(
            message: AppError.getMessage(e),
            onRetry: () => ref.invalidate(contractsListProvider),
          ),
          data: (contracts) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildNewContractCard(context, colors, typography),
              const SizedBox(height: 16),
              if (contracts.isEmpty)
                EmptyState(message: context.tr('no_contracts_tap'))
              else
                ...contracts.map((c) => ContractCard(contract: c)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewContractCard(
      BuildContext context, FColors colors, FTypography typography) {
    return FTappable(
      onPress: () => context.push('/landlord/contracts/create'),
      child: FCard(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: context.theme.style.borderRadius.md,
                ),
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedAdd01,
                    size: 22,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('new_contract'),
                      style: typography.body.sm.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('create_new_contract'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.xs2
                          .copyWith(color: colors.mutedForeground),
                    ),
                  ],
                ),
              ),
              HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 18,
                color: colors.mutedForeground.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
