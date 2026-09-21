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
import '../../providers/properties_provider.dart';
import '../widgets/property_card.dart';
import '../widgets/property_grid_card.dart';

import 'package:manna_apartment/core/utils/app_toast.dart';

class PropertiesListScreen extends ConsumerStatefulWidget {
  const PropertiesListScreen({super.key});

  @override
  ConsumerState<PropertiesListScreen> createState() => _PropertiesListScreenState();
}

class _PropertiesListScreenState extends ConsumerState<PropertiesListScreen> {
  bool _isGrid = false;
  bool _showVacantOnly = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(propertiesListProvider);
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('properties'),
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
            variant: _showVacantOnly ? .secondary : .ghost,
            size: .sm,
            onPress: () => setState(() => _showVacantOnly = !_showVacantOnly),
            child: const HugeIcon(icon: HugeIcons.strokeRoundedFilterHorizontal, size: null),
          ),
          FButton.icon(
            variant: .ghost,
            size: .sm,
            onPress: () => setState(() => _isGrid = !_isGrid),
            child: HugeIcon(
              icon: _isGrid ? HugeIcons.strokeRoundedListView : HugeIcons.strokeRoundedGridView,
              size: null,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FTextField(
              control: .managed(
                onChange: (v) => setState(() => _searchQuery = v.text.toLowerCase()),
              ),
              hint: context.tr('search_properties'),
              prefixBuilder: (context, style, variants) => FTextField.prefixIconBuilder(
                context,
                style,
                variants,
                const HugeIcon(icon: HugeIcons.strokeRoundedSearch01, size: null),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(propertiesListProvider),
              color: colors.primary,
              child: propertiesAsync.when(
                loading: () => const LoadingIndicator(),
                error: (e, _) {
                  final message = AppError.getMessage(e);
                  final isSetup = AppError.isSetupError(e);
                  return ErrorState(
                    message: message,
                    onRetry: () => ref.invalidate(propertiesListProvider),
                    onAction: isSetup ? () => context.go('/landlord/subscription') : null,
                    actionLabel: context.tr('complete_setup'),
                  );
                },
                data: (properties) {
                  var filtered = properties.where((p) {
                    final matchesSearch = p.name.toLowerCase().contains(_searchQuery) ||
                        (p.address ?? '').toLowerCase().contains(_searchQuery);
                    final matchesVacant = !_showVacantOnly || (p.vacantUnits ?? 0) > 0;
                    return matchesSearch && matchesVacant;
                  }).toList();

                  if (filtered.isEmpty) {
                    return EmptyState(message: context.tr('no_properties_found'));
                  }

                  if (_isGrid) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => PropertyGridCard(property: filtered[index]),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final property = filtered[index];
                      return Dismissible(
                        key: Key(property.id),
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
                                .read(propertiesRepositoryProvider)
                                .deleteProperty(property.id);
                            ref.invalidate(propertiesListProvider);
                            if (context.mounted) {
                              AppToast.success(context, context.tr('property_deleted'));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              AppToast.error(
                                context,
                                context.tr('failed_msg').replaceAll('{0}', AppError.getMessage(e)),
                              );
                              ref.invalidate(propertiesListProvider);
                            }
                          }
                        },
                        child: PropertyCard(property: property),
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
        onPressed: () => context.push('/landlord/properties/add'),
        backgroundColor: colors.primary,
        foregroundColor: colors.primaryForeground,
        icon: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 20),
        label: Text(context.tr('add')),
      ),
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
            Text(context.tr('delete_property'), style: style.titleTextStyle),
            const SizedBox(height: 8),
            Text(context.tr('confirm_delete_property'), style: style.bodyTextStyle),
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
