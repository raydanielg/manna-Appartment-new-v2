import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/confirm_dialog.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../payments/providers/payments_provider.dart';
import '../../../tenants/providers/tenants_provider.dart';
import '../../providers/properties_provider.dart';

import 'package:manna_apartment/core/utils/app_toast.dart';

class PropertyDetailScreen extends ConsumerWidget {
  const PropertyDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = GoRouterState.of(context);
    final id = state.pathParameters['id'] ?? '';
    final propertyAsync = ref.watch(propertyDetailProvider(id));
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Text(
            context.tr('property_details'),
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
              onPress: () => context.push('/landlord/properties/add?id=$id'),
              child: const HugeIcon(
                icon: HugeIcons.strokeRoundedEdit02,
                size: 20,
              ),
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
          bottom: TabBar(
            labelColor: colors.primary,
            unselectedLabelColor: colors.mutedForeground,
            indicatorColor: colors.primary,
            labelStyle:
                typography.body.sm.copyWith(fontWeight: FontWeight.w700),
            tabs: [
              Tab(text: context.tr('details')),
              Tab(text: context.tr('tenants')),
              Tab(text: context.tr('payments')),
            ],
          ),
        ),
        body: propertyAsync.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) => ErrorState(
            message: AppError.getMessage(e),
            onRetry: () => ref.invalidate(propertyDetailProvider(id)),
          ),
          data: (property) => TabBarView(
            children: [
              _detailsTab(context, ref, id, property, colors, typography),
              _tenantsTab(context, ref, id, colors, typography),
              _paymentsTab(context, ref, id, colors, typography),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Details tab ----------------

  Widget _detailsTab(BuildContext context, WidgetRef ref, String id,
      dynamic property, FColors colors, FTypography typography) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageGallery(context, property, colors, typography),
          const SizedBox(height: 20),
          Text(
            property.name,
            style: typography.display.lg.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedLocation01,
                size: 15,
                color: colors.mutedForeground,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  property.address ?? context.tr('no_address'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      typography.body.xs.copyWith(color: colors.mutedForeground),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FCard(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                children: [
                  _row(colors, typography, HugeIcons.strokeRoundedBuilding03,
                      context.tr('type'), _capitalize(property.type ?? 'N/A')),
                  _divider(colors),
                  _row(colors, typography, HugeIcons.strokeRoundedDoor01,
                      context.tr('total_units'), '${property.unitsCount ?? 0}'),
                  _divider(colors),
                  _row(colors, typography, HugeIcons.strokeRoundedCheckmarkCircle02,
                      context.tr('occupied'), '${property.occupiedUnits ?? 0}'),
                  _divider(colors),
                  _row(colors, typography, HugeIcons.strokeRoundedCancel01,
                      context.tr('vacant'), '${property.vacantUnits ?? 0}'),
                  if (property.monthlyRevenue != null &&
                      property.monthlyRevenue! > 0) ...[
                    _divider(colors),
                    _row(
                      colors,
                      typography,
                      HugeIcons.strokeRoundedWallet01,
                      context.tr('monthly_revenue'),
                      'TZS ${property.monthlyRevenue!.toStringAsFixed(0)}',
                      valueColor: colors.primary,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FButton(
            variant: .secondary,
            size: .sm,
            prefix:
                const HugeIcon(icon: HugeIcons.strokeRoundedDoor01, size: null),
            onPress: () =>
                context.push('/landlord/units?propertyId=${property.id}'),
            child: Text(context.tr('units')),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------------- Tenants tab ----------------

  Widget _tenantsTab(BuildContext context, WidgetRef ref, String propertyId,
      FColors colors, FTypography typography) {
    final tenantsAsync = ref.watch(tenantsListProvider(propertyId));
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(tenantsListProvider(propertyId)),
      color: colors.primary,
      child: tenantsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          message: AppError.getMessage(e),
          onRetry: () => ref.invalidate(tenantsListProvider(propertyId)),
        ),
        data: (tenants) {
          if (tenants.isEmpty) {
            return EmptyState(message: context.tr('no_tenants_found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: tenants.length,
            itemBuilder: (context, index) {
              final t = tenants[index];
              final name = t['full_name'] ??
                  t['user']?['full_name'] ??
                  context.tr('unknown');
              final unit =
                  t['unit']?['name'] ?? t['unit']?['unit_number'] ?? '';
              final status = (t['status'] ?? 'active').toString();
              final isActive = status == 'active';
              return FTappable(
                onPress: () =>
                    context.push('/landlord/tenants/${t['id']}'),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: colors.border.withValues(alpha: 0.5)),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: typography.body.sm
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                              if (unit.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '${context.tr('unit')} $unit',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: typography.body.xs3.copyWith(
                                      color: colors.mutedForeground),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          status.toUpperCase(),
                          style: typography.body.xs3.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? const Color(0xFF16A34A)
                                : colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ---------------- Payments tab ----------------

  Widget _paymentsTab(BuildContext context, WidgetRef ref, String propertyId,
      FColors colors, FTypography typography) {
    final paymentsAsync = ref.watch(landlordPaymentsProvider(propertyId));
    return RefreshIndicator(
      onRefresh: () async =>
          ref.invalidate(landlordPaymentsProvider(propertyId)),
      color: colors.primary,
      child: paymentsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          message: AppError.getMessage(e),
          onRetry: () =>
              ref.invalidate(landlordPaymentsProvider(propertyId)),
        ),
        data: (payments) {
          if (payments.isEmpty) {
            return EmptyState(message: context.tr('no_payments_found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final p = payments[index];
              final tenant = p['tenant']?['full_name'] ??
                  p['tenant']?['user']?['full_name'] ??
                  context.tr('unknown');
              final type = (p['payment_type'] ?? 'payment').toString();
              final date = p['payment_date']?.toString() ?? '';
              final amount = p['amount'] ?? 0;
              final amountStr = NumberFormat('#,###').format(
                  amount is num
                      ? amount
                      : double.tryParse(amount.toString()) ?? 0);
              return FTappable(
                onPress: () =>
                    context.push('/landlord/payments/${p['id']}'),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: colors.border.withValues(alpha: 0.5)),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tenant,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: typography.body.sm
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$type · ${date.isNotEmpty ? date.substring(0, 10) : '-'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: typography.body.xs3.copyWith(
                                    color: colors.mutedForeground),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'TZS $amountStr',
                          style: typography.body.sm
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ---------------- Helpers ----------------

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showConfirmDialog(
      context,
      title: context.tr('delete_property'),
      message: context.tr('confirm_delete_property'),
      confirmText: context.tr('delete'),
      cancelText: context.tr('cancel'),
      isDestructive: true,
    );
    if (confirmed != true) return;
    try {
      await ref.read(propertiesRepositoryProvider).deleteProperty(id);
      ref.invalidate(propertiesListProvider);
      if (context.mounted) {
        AppToast.success(context, context.tr('property_deleted'));
        if (context.canPop()) context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context,
            context.tr('failed_msg').replaceAll('{0}', AppError.getMessage(e)));
      }
    }
  }

  Widget _buildImageGallery(
      BuildContext context, property, FColors colors, FTypography typography) {
    final images =
        property.images is List ? property.images as List<String> : <String>[];
    final hasImages = images.isNotEmpty;
    final radii = context.theme.style.borderRadius;

    if (!hasImages) {
      return Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: colors.secondary.withValues(alpha: 0.4),
          borderRadius: radii.lg,
          border: Border.all(color: colors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedBuilding03,
              size: 48,
              color: colors.mutedForeground.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('no_photos'),
              style: typography.body.xs.copyWith(color: colors.mutedForeground),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: radii.lg,
          child: SizedBox(
            height: 220,
            child: PageView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) => Image.network(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: colors.secondary.withValues(alpha: 0.4),
                  child: Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedBuilding03,
                      size: 40,
                      color: colors.mutedForeground.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: index == 0 ? colors.primary : colors.border,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _divider(FColors colors) =>
      Divider(height: 1, indent: 14, color: colors.border.withValues(alpha: 0.6));

  Widget _row(
    FColors colors,
    FTypography typography,
    List<List<dynamic>> icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
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
              style: typography.body.xs2.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor ?? colors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
