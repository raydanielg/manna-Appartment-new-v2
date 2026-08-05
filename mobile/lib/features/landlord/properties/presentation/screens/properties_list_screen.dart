import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/properties_provider.dart';
import '../widgets/property_card.dart';
import '../widgets/property_grid_card.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final propertiesAsync = ref.watch(propertiesListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Properties', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {
          if (context.canPop()) context.pop();
        }),
        actions: [
          IconButton(
            icon: Icon(_showVacantOnly ? Icons.filter_alt : Icons.filter_alt_outlined),
            tooltip: 'Vacant only',
            onPressed: () => setState(() => _showVacantOnly = !_showVacantOnly),
          ),
          IconButton(
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            tooltip: _isGrid ? 'List view' : 'Grid view',
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search properties...',
                hintStyle: GoogleFonts.nunito(fontSize: 14),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(propertiesListProvider),
              color: AppColors.primary,
              child: propertiesAsync.when(
                loading: () => const LoadingIndicator(),
                error: (e, _) {
                  final message = e.toString();
                  final isSetupError = message.toLowerCase().contains('kyc') ||
                      message.toLowerCase().contains('subscription') ||
                      message.toLowerCase().contains('organization');
                  return ErrorState(
                    message: message,
                    onRetry: () => ref.invalidate(propertiesListProvider),
                    onAction: isSetupError ? () => context.go('/landlord/subscription') : null,
                    actionLabel: 'Complete Setup',
                  );
                },
                data: (properties) {
                  var filtered = properties.where((p) {
                    final matchesSearch = p.name.toLowerCase().contains(_searchQuery) || (p.address ?? '').toLowerCase().contains(_searchQuery);
                    final matchesVacant = !_showVacantOnly || (p.vacantUnits ?? 0) > 0;
                    return matchesSearch && matchesVacant;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const EmptyState(message: 'No properties found. Add your first property.');
                  }

                  if (_isGrid) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
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
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Property'),
                              content: const Text('Are you sure you want to delete this property? This will also affect all units under it.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          try {
                            await ref.read(propertiesRepositoryProvider).deleteProperty(property.id);
                            ref.invalidate(propertiesListProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Property deleted'), backgroundColor: AppColors.success),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
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
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}
