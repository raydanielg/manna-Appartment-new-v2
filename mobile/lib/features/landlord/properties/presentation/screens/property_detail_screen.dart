import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/properties_provider.dart';

class PropertyDetailScreen extends ConsumerWidget {
  const PropertyDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = GoRouterState.of(context);
    final id = state.pathParameters['id'] ?? '';
    final propertyAsync = ref.watch(propertyDetailProvider(id));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Property Details'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/landlord/properties/add?id=$id'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _confirmDelete(context, ref, id),
          ),
        ],
      ),
      body: propertyAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(propertyDetailProvider(id))),
        data: (property) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageGallery(context, property),
              const SizedBox(height: 20),
              Text(
                property.name,
                style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark),
              ),
              const SizedBox(height: 4),
              Text(
                property.address ?? 'No address',
                style: GoogleFonts.nunito(fontSize: 14, color: isDark ? Colors.white60 : AppColors.textLight),
              ),
              const SizedBox(height: 20),
              _buildInfoRow(context, Icons.category_outlined, 'Type', property.type ?? 'N/A'),
              _buildInfoRow(context, Icons.meeting_room_outlined, 'Total Units', '${property.unitsCount ?? 0}'),
              _buildInfoRow(context, Icons.check_circle_outline, 'Occupied', '${property.occupiedUnits ?? 0}'),
              _buildInfoRow(context, Icons.highlight_off, 'Vacant', '${property.vacantUnits ?? 0}'),
              if (property.monthlyRevenue != null && property.monthlyRevenue! > 0)
                _buildInfoRow(context, Icons.account_balance_wallet, 'Monthly Revenue', 'TZS ${property.monthlyRevenue!.toStringAsFixed(0)}'),
              if (property.description != null && property.description!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('Description', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                const SizedBox(height: 8),
                Text(property.description!, style: GoogleFonts.nunito(fontSize: 14, color: isDark ? Colors.white70 : AppColors.textDark)),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/landlord/properties/add?id=${property.id}'),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmDelete(context, ref, property.id),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/landlord/units?propertyId=${property.id}'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.info),
                      icon: const Icon(Icons.meeting_room),
                      label: const Text('Units'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Property'),
        content: const Text('Are you sure you want to delete this property? This will also affect all units under it. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(propertiesRepositoryProvider).deleteProperty(id);
                ref.invalidate(propertiesListProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Property deleted'), backgroundColor: AppColors.success),
                  );
                  if (context.canPop()) context.pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context, property) {
    final images = property.images is List ? property.images as List<String> : <String>[];
    final hasImages = images.isNotEmpty;
    if (!hasImages) {
      return Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Icon(Icons.apartment, size: 64, color: Colors.white70)),
      );
    }
    return SizedBox(
      height: 180,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) => ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            images[index],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(Icons.apartment, color: AppColors.primary, size: 48),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.nunito(fontSize: 14, color: isDark ? Colors.white60 : AppColors.textLight)),
          const Spacer(),
          Text(value, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
        ],
      ),
    );
  }
}
