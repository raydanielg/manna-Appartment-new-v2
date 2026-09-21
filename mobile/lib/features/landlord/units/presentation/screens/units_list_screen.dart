import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/confirm_dialog.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/units_provider.dart';
import '../widgets/unit_card.dart';

import 'package:manna_apartment/core/utils/app_toast.dart';

class UnitsListScreen extends ConsumerWidget {
  final String? propertyId;
  const UnitsListScreen({super.key, this.propertyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(unitsListProvider(propertyId));
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('units'),
          style: typography.display.md.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: FButton.icon(
          variant: .ghost,
          size: .sm,
          onPress: () => context.pop(),
          child: context.theme.icons.arrowLeft(context),
        ),
        actions: [
          FButton.icon(
            variant: .ghost,
            size: .sm,
            onPress: () =>
                context.push('/landlord/units/add?propertyId=${propertyId ?? ''}'),
            child: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 20),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(unitsListProvider(propertyId)),
        color: colors.primary,
        child: unitsAsync.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) {
            final message = AppError.getMessage(e);
            final isSetup = AppError.isSetupError(e);
            return ErrorState(
              message: message,
              onRetry: () => ref.invalidate(unitsListProvider(propertyId)),
              onAction:
                  isSetup ? () => context.go('/landlord/subscription') : null,
              actionLabel: context.tr('complete_setup'),
            );
          },
          data: (units) {
            if (units.isEmpty) {
              return EmptyState(message: context.tr('no_units_tap'));
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                ...units.map((unit) => Dismissible(
                      key: Key(
                          unit['id']?.toString() ?? UniqueKey().toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: colors.error,
                          borderRadius:
                              context.theme.style.borderRadius.lg,
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedDelete02,
                          size: 22,
                          color: colors.errorForeground,
                        ),
                      ),
                      confirmDismiss: (direction) => showConfirmDialog(
                        context,
                        title: context.tr('delete_unit'),
                        message: context.tr('confirm_delete_unit'),
                        confirmText: context.tr('delete'),
                        cancelText: context.tr('cancel'),
                        isDestructive: true,
                      ),
                      onDismissed: (direction) async {
                        try {
                          await ref
                              .read(unitsRepositoryProvider)
                              .deleteUnit(unit['id'].toString());
                          ref.invalidate(unitsListProvider(propertyId));
                          if (context.mounted) {
                            AppToast.success(
                                context, context.tr('unit_deleted'));
                          }
                        } catch (e) {
                          if (context.mounted) {
                            AppToast.error(
                              context,
                              context.tr('failed_msg').replaceAll(
                                  '{0}', AppError.getMessage(e)),
                            );
                            ref.invalidate(unitsListProvider(propertyId));
                          }
                        }
                      },
                      child: UnitCard(unit: unit),
                    )),
              ],
            );
          },
        ),
      ),
    );
  }
}
