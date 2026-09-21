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
        actions: [
          FButton.icon(
            variant: .ghost,
            size: .sm,
            onPress: () => context.push('/landlord/contracts/create'),
            child: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 20),
          ),
          const SizedBox(width: 8),
        ],
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
          data: (contracts) {
            if (contracts.isEmpty) {
              return EmptyState(message: context.tr('no_contracts_tap'));
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: contracts.length,
              itemBuilder: (context, index) =>
                  ContractCard(contract: contracts[index]),
            );
          },
        ),
      ),
    );
  }
}
