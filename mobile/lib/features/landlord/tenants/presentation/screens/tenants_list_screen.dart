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
import '../../../properties/providers/properties_provider.dart';
import '../../providers/tenants_provider.dart';
import '../widgets/tenant_card.dart';

import 'package:manna_apartment/core/utils/app_toast.dart';

class TenantsListScreen extends ConsumerStatefulWidget {
  const TenantsListScreen({super.key});

  @override
  ConsumerState<TenantsListScreen> createState() => _TenantsListScreenState();
}

class _TenantsListScreenState extends ConsumerState<TenantsListScreen> {
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, active, moved_out
  String? _selectedPropertyId;

  @override
  Widget build(BuildContext context) {
    final tenantsAsync = ref.watch(tenantsListProvider(_selectedPropertyId));
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final hasActiveFilter =
        _filterStatus != 'all' || _selectedPropertyId != null;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('tenants'),
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
          // Filter button — badge dot when active
          FButton.icon(
            variant: hasActiveFilter ? .secondary : .ghost,
            size: .sm,
            onPress: () => _showFilterSheet(context),
            child: const HugeIcon(
                icon: HugeIcons.strokeRoundedFilterHorizontal, size: null),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: FTextField(
              control: .managed(
                onChange: (v) =>
                    setState(() => _searchQuery = v.text.toLowerCase()),
              ),
              hint: context.tr('search_name_phone'),
              prefixBuilder: (context, style, variants) =>
                  FTextField.prefixIconBuilder(
                    context,
                    style,
                    variants,
                    const HugeIcon(
                        icon: HugeIcons.strokeRoundedSearch01, size: null),
                  ),
            ),
          ),

          // Active filter chips — slim summary row
          if (hasActiveFilter)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _filterSummary(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.xs3
                          .copyWith(color: colors.mutedForeground),
                    ),
                  ),
                  FButton(
                    variant: .ghost,
                    size: .xs,
                    mainAxisSize: MainAxisSize.min,
                    onPress: () => setState(() {
                      _filterStatus = 'all';
                      _selectedPropertyId = null;
                    }),
                    child: Text(context.tr('clear')),
                  ),
                ],
              ),
            ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(tenantsListProvider),
              color: colors.primary,
              child: tenantsAsync.when(
                loading: () => const LoadingIndicator(),
                error: (e, _) {
                  final message = AppError.getMessage(e);
                  final isSetup = AppError.isSetupError(e);
                  return ErrorState(
                    message: message,
                    onRetry: () => ref.invalidate(tenantsListProvider),
                    onAction: isSetup
                        ? () => context.go('/landlord/subscription')
                        : null,
                    actionLabel: context.tr('complete_setup'),
                  );
                },
                data: (tenants) {
                  final filtered = tenants.where((t) {
                    final userData = t['user'] as Map<String, dynamic>?;
                    final name = (userData?['full_name'] ??
                            userData?['name'] ??
                            t['full_name'] ??
                            t['name'] ??
                            '')
                        .toString()
                        .toLowerCase();
                    final phone = (userData?['phone'] ?? t['phone'] ?? '')
                        .toString()
                        .toLowerCase();
                    final matchesSearch = name.contains(_searchQuery) ||
                        phone.contains(_searchQuery);
                    final status = (t['status'] ?? 'active').toString();
                    final matchesStatus =
                        _filterStatus == 'all' || status == _filterStatus;
                    return matchesSearch && matchesStatus;
                  }).toList();

                  if (filtered.isEmpty) {
                    return EmptyState(
                        message: context.tr('no_tenants_found'));
                  }
                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final tenant = filtered[index];
                      final tenantId = tenant['id']?.toString() ?? '';
                      return Dismissible(
                        key: Key(tenantId.isNotEmpty
                            ? tenantId
                            : index.toString()),
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
                        confirmDismiss: (direction) =>
                            _confirmDelete(context),
                        onDismissed: (direction) async {
                          try {
                            await ref
                                .read(tenantsRepositoryProvider)
                                .deleteTenant(tenantId);
                            ref.invalidate(tenantsListProvider);
                            if (context.mounted) {
                              AppToast.success(
                                  context, context.tr('tenant_deleted'));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              AppToast.error(
                                context,
                                context.tr('failed_msg').replaceAll(
                                    '{0}', AppError.getMessage(e)),
                              );
                              ref.invalidate(tenantsListProvider);
                            }
                          }
                        },
                        child: TenantCard(tenant: tenant),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/landlord/tenants/add'),
        backgroundColor: colors.primary,
        foregroundColor: colors.primaryForeground,
        icon: const HugeIcon(icon: HugeIcons.strokeRoundedUserAdd01, size: 20),
        label: Text(context.tr('add_tenant')),
      ),
    );
  }

  String _filterSummary(BuildContext context) {
    final parts = <String>[];
    parts.add(switch (_filterStatus) {
      'active' => context.tr('active'),
      'moved_out' => context.tr('moved_out'),
      _ => context.tr('all_tenants'),
    });
    return parts.join(' · ');
  }

  Future<void> _showFilterSheet(BuildContext context) async {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    await showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String status = _filterStatus;
        String? propertyId = _selectedPropertyId;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('filter'),
                      style: typography.body.md
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),

                    // Status
                    Text(
                      context.tr('status').toUpperCase(),
                      style: typography.body.xs3.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: colors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _sheetChip(context, context.tr('all_tenants'),
                            status == 'all',
                            () => setSheetState(() => status = 'all')),
                        _sheetChip(context, context.tr('active'),
                            status == 'active',
                            () => setSheetState(() => status = 'active')),
                        _sheetChip(context, context.tr('moved_out'),
                            status == 'moved_out',
                            () => setSheetState(
                                () => status = 'moved_out')),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Property
                    Text(
                      context.tr('property').toUpperCase(),
                      style: typography.body.xs3.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: colors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _propertyPicker(context, typography, colors, propertyId,
                        (v) => setSheetState(() => propertyId = v)),
                    const SizedBox(height: 24),

                    FButton(
                      variant: .primary,
                      onPress: () {
                        setState(() {
                          _filterStatus = status;
                          _selectedPropertyId = propertyId;
                        });
                        Navigator.pop(context);
                      },
                      child: Text(context.tr('apply')),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetChip(BuildContext context, String label, bool selected,
      VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FButton(
        variant: selected ? .primary : .outline,
        size: .xs,
        mainAxisSize: MainAxisSize.min,
        onPress: onTap,
        child: Text(label),
      ),
    );
  }

  Widget _propertyPicker(BuildContext context, FTypography typography,
      FColors colors, String? current, ValueChanged<String?> onSelected) {
    final propertiesAsync = ref.watch(propertiesListProvider);
    return propertiesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (properties) {
        if (properties.isEmpty) return const SizedBox.shrink();
        return PopupMenuButton<String?>(
          offset: const Offset(0, 36),
          color: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: context.theme.style.borderRadius.lg,
          ),
          onSelected: onSelected,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: null,
              child: Text(context.tr('select_property_all'),
                  style: typography.body.xs2),
            ),
            for (final p in properties)
              PopupMenuItem(
                value: p.id,
                child: Text(p.name, style: typography.body.xs2),
              ),
          ],
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: context.theme.style.borderRadius.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    current == null
                        ? context.tr('select_property_all')
                        : properties
                            .firstWhere((p) => p.id == current,
                                orElse: () => properties.first)
                            .name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.body.xs2
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowDown01,
                  size: 14,
                  color: colors.mutedForeground,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context) {
    return showConfirmDialog(
      context,
      title: context.tr('delete_tenant'),
      message: context.tr('confirm_delete_tenant'),
      confirmText: context.tr('delete'),
      cancelText: context.tr('cancel'),
      isDestructive: true,
    );
  }
}
