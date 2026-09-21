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
          data: (units) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAddUnitCard(context, colors, typography),
              const SizedBox(height: 16),
              if (units.isEmpty)
                EmptyState(message: context.tr('no_units_tap'))
              else
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
          ),
        ),
      ),
    );
  }

  Widget _buildAddUnitCard(
      BuildContext context, FColors colors, FTypography typography) {
    return FTappable(
      onPress: () =>
          context.push('/landlord/units/add?propertyId=${propertyId ?? ''}'),
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
                      context.tr('add_unit'),
                      style: typography.body.sm
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('create_new_unit'),
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
