import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/unit_provider.dart';

class MyUnitDetailScreen extends ConsumerWidget {
  const MyUnitDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitAsync = ref.watch(myUnitProvider);
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('my_unit'),
          style: typography.display.md.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: FButton.icon(
          variant: .ghost,
          size: .sm,
          onPress: () => context.pop(),
          child: context.theme.icons.arrowLeft(context),
        ),
      ),
      body: unitAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) {
          if (e is DioException && e.response?.statusCode == 404) {
            return EmptyState(
              icon: Icons.door_front_door_outlined,
              message:
                  '${context.tr('no_unit_assigned_title')}\n${context.tr('no_unit_assigned_desc')}',
            );
          }
          return ErrorState(
            message: AppError.getMessage(e),
            onRetry: () => ref.invalidate(myUnitProvider),
          );
        },
        data: (unit) {
          final rent = unit['rent_amount'] ?? unit['monthly_rent'] ?? 0;
          final rentNum =
              rent is num ? rent : double.tryParse(rent.toString()) ?? 0;
          final status = (unit['status'] ?? 'occupied').toString();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                unit['name']?.toString() ?? context.tr('my_unit'),
                style: typography.display.lg
                    .copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'TZS ${NumberFormat('#,###').format(rentNum)}${context.tr('per_month')}',
                style: typography.body.md.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status.toUpperCase(),
                style: typography.body.xs3.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: status == 'occupied'
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFD97706),
                ),
              ),
              const SizedBox(height: 20),
              _infoRow(context, HugeIcons.strokeRoundedHome01,
                  context.tr('type'), unit['type']?.toString() ?? 'N/A'),
              _infoRow(context, HugeIcons.strokeRoundedRuler,
                  context.tr('size'), '${unit['size'] ?? 'N/A'} sqm'),
              _infoRow(context, HugeIcons.strokeRoundedBedDouble,
                  context.tr('bedrooms'), '${unit['bedrooms'] ?? 0}'),
              _infoRow(context, HugeIcons.strokeRoundedBathtub01,
                  context.tr('bathrooms'), '${unit['bathrooms'] ?? 0}'),
              if (unit['property'] != null)
                _infoRow(context, HugeIcons.strokeRoundedBuilding03,
                    context.tr('property'),
                    unit['property']['name']?.toString() ?? 'N/A'),
              if (unit['description'] != null) ...[
                const SizedBox(height: 16),
                Text(
                  context.tr('description').toUpperCase(),
                  style: typography.body.xs3.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  unit['description'].toString(),
                  style:
                      typography.body.xs2.copyWith(height: 1.5),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _infoRow(BuildContext context, List<List<dynamic>> icon, String label,
      String value) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            HugeIcon(icon: icon, size: 16, color: colors.mutedForeground),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: typography.body.xs2
                    .copyWith(color: colors.mutedForeground),
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
      ),
    );
  }
}
