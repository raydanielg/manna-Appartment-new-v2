import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/confirm_dialog.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/units_provider.dart';

import 'package:manna_apartment/core/utils/app_toast.dart';

class UnitDetailScreen extends ConsumerWidget {
  const UnitDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    final unitAsync = ref.watch(unitDetailProvider(id));
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('unit_details'),
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
            onPress: () => context.push('/landlord/units/add?id=$id'),
            child: const HugeIcon(
                icon: HugeIcons.strokeRoundedEdit02, size: 20),
          ),
          FButton.icon(
            variant: .ghost,
            size: .sm,
            onPress: () => _confirmDelete(context, ref, id),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedDelete02,
              size: 20,
              color: colors.error,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: unitAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) {
          final message = AppError.getMessage(e);
          final isSetup = AppError.isSetupError(e);
          return ErrorState(
            message: message,
            onRetry: () => ref.invalidate(unitDetailProvider(id)),
            onAction: isSetup ? () => context.go('/landlord/subscription') : null,
            actionLabel: context.tr('complete_setup'),
          );
        },
        data: (unit) {
          final status = (unit['status'] ?? 'vacant').toString();
          final isOccupied = status == 'occupied';
          final rent = unit['monthly_rent'] ?? 0;
          final formattedRent = NumberFormat('#,###').format(
              rent is num ? rent : (double.tryParse(rent.toString()) ?? 0));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header — name + rent + status, no gradient box
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unit['name'] ??
                                unit['unit_number'] ??
                                context.tr('unit'),
                            style: typography.display.lg
                                .copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'TZS $formattedRent/${context.tr('month')}',
                            style: typography.body.sm
                                .copyWith(color: colors.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                    _pill(
                      context,
                      status,
                      isOccupied
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFD97706),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Info card
                FCard(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      children: [
                        _row(colors, typography, HugeIcons.strokeRoundedGridView,
                            context.tr('type'), unit['type']?.toString() ?? 'N/A'),
                        _divider(colors),
                        _row(colors, typography, HugeIcons.strokeRoundedSquare,
                            context.tr('size'), '${unit['size'] ?? 'N/A'} sqm'),
                        _divider(colors),
                        _row(colors, typography, HugeIcons.strokeRoundedBedDouble,
                            context.tr('bedrooms'), '${unit['bedrooms'] ?? 0}'),
                        _divider(colors),
                        _row(colors, typography, HugeIcons.strokeRoundedBathtub01,
                            context.tr('bathrooms'), '${unit['bathrooms'] ?? 0}'),
                      ],
                    ),
                  ),
                ),

                if (unit['tenant'] != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    context.tr('current_tenant'),
                    style: typography.display.sm
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  FCard(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedUser,
                                size: 18,
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
                                  unit['tenant']['full_name'] ??
                                      context.tr('unknown'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: typography.body.sm
                                      .copyWith(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  unit['tenant']['phone'] ?? '',
                                  style: typography.body.xs3.copyWith(
                                      color: colors.mutedForeground),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                FButton(
                  variant: .outline,
                  size: .sm,
                  prefix: const HugeIcon(
                      icon: HugeIcons.strokeRoundedEdit02, size: null),
                  onPress: () => context.push('/landlord/units/add?id=$id'),
                  child: Text(context.tr('edit')),
                ),
                const SizedBox(height: 10),
                FButton(
                  variant: .destructive,
                  size: .sm,
                  prefix: const HugeIcon(
                      icon: HugeIcons.strokeRoundedDelete02, size: null),
                  onPress: () => _confirmDelete(context, ref, id),
                  child: Text(context.tr('delete')),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _pill(BuildContext context, String label, Color color) {
    final typography = context.theme.typography;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: context.theme.style.borderRadius.pill,
      ),
      child: Text(
        label.toUpperCase(),
        style: typography.body.xs3.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: color,
        ),
      ),
    );
  }

  Widget _divider(FColors colors) =>
      Divider(height: 1, indent: 14, color: colors.border.withValues(alpha: 0.6));

  Widget _row(FColors colors, FTypography typography, List<List<dynamic>> icon,
      String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          HugeIcon(icon: icon, size: 16, color: colors.mutedForeground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: typography.body.xs2.copyWith(color: colors.mutedForeground),
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.body.xs2
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showConfirmDialog(
      context,
      title: context.tr('delete_unit'),
      message: context.tr('confirm_delete_unit'),
      confirmText: context.tr('delete'),
      cancelText: context.tr('cancel'),
      isDestructive: true,
    );
    if (!confirmed) return;
    try {
      await ref.read(unitsRepositoryProvider).deleteUnit(id);
      ref.invalidate(unitsListProvider(null));
      if (context.mounted) {
        AppToast.success(context, context.tr('unit_deleted'));
        if (context.canPop()) context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context,
            context.tr('failed_msg').replaceAll('{0}', AppError.getMessage(e)));
      }
    }
  }
}
