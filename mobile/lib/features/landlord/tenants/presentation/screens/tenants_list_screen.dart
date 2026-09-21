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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: FTextField(
              control: .managed(
                onChange: (v) => setState(() => _searchQuery = v.text.toLowerCase()),
              ),
              hint: context.tr('search_name_phone'),
              prefixBuilder: (context, style, variants) =>
                  FTextField.prefixIconBuilder(
                    context,
                    style,
                    variants,
                    const HugeIcon(icon: HugeIcons.strokeRoundedSearch01, size: null),
                  ),
            ),
          ),

          // Status filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _filterButton(context.tr('all_tenants'), 'all'),
                const SizedBox(width: 8),
                _filterButton(context.tr('active'), 'active'),
                const SizedBox(width: 8),
                _filterButton(context.tr('moved_out'), 'moved_out'),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Property filter
          _buildPropertyFilter(colors, typography),
          const SizedBox(height: 12),

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
                    onAction: isSetup ? () => context.go('/landlord/subscription') : null,
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
                    final phone =
                        (userData?['phone'] ?? t['phone'] ?? '').toString().toLowerCase();
                    final matchesSearch =
                        name.contains(_searchQuery) || phone.contains(_searchQuery);
                    final status = (t['status'] ?? 'active').toString();
                    final matchesStatus = _filterStatus == 'all' || status == _filterStatus;
                    return matchesSearch && matchesStatus;
                  }).toList();

                  if (filtered.isEmpty) {
                    return EmptyState(message: context.tr('no_tenants_found'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final tenant = filtered[index];
                      final tenantId = tenant['id']?.toString() ?? '';
                      return Dismissible(
                        key: Key(tenantId.isNotEmpty ? tenantId : index.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: colors.error,
                            borderRadius: context.theme.style.borderRadius.lg,
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedDelete02,
                            size: 22,
                            color: colors.errorForeground,
                          ),
                        ),
                        confirmDismiss: (direction) => _confirmDelete(context),
                        onDismissed: (direction) async {
                          try {
                            await ref
                                .read(tenantsRepositoryProvider)
                                .deleteTenant(tenantId);
                            ref.invalidate(tenantsListProvider);
                            if (context.mounted) {
                              AppToast.success(context, context.tr('tenant_deleted'));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              AppToast.error(
                                context,
                                context.tr('failed_msg').replaceAll('{0}', AppError.getMessage(e)),
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

  Widget _filterButton(String label, String value) {
    final isSelected = _filterStatus == value;
    return FButton(
      variant: isSelected ? .primary : .outline,
      size: .sm,
      mainAxisSize: MainAxisSize.min,
      onPress: () => setState(() => _filterStatus = value),
      child: Text(label),
    );
  }

  Widget _buildPropertyFilter(FColors colors, FTypography typography) {
    final propertiesAsync = ref.watch(propertiesListProvider);
    return propertiesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (properties) {
        if (properties.isEmpty) return const SizedBox.shrink();
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              FButton(
                variant: _selectedPropertyId == null ? .secondary : .ghost,
                size: .sm,
                mainAxisSize: MainAxisSize.min,
                prefix: HugeIcon(
                  icon: HugeIcons.strokeRoundedBuilding03,
                  size: null,
                  color: null,
                ),
                onPress: () => setState(() => _selectedPropertyId = null),
                child: Text(context.tr('select_property_all')),
              ),
              for (final p in properties) ...[
                const SizedBox(width: 8),
                FButton(
                  variant: _selectedPropertyId == p.id ? .secondary : .ghost,
                  size: .sm,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () => setState(() => _selectedPropertyId = p.id),
                  child: Text(p.name),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showFDialog<bool>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        builder: (context, style) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('delete_tenant'), style: style.titleTextStyle),
            const SizedBox(height: 8),
            Text(context.tr('confirm_delete_tenant'), style: style.bodyTextStyle),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton(
                  variant: .outline,
                  size: .sm,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () => Navigator.pop(context, false),
                  child: Text(context.tr('cancel')),
                ),
                const SizedBox(width: 8),
                FButton(
                  variant: .destructive,
                  size: .sm,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () => Navigator.pop(context, true),
                  child: Text(context.tr('delete')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
