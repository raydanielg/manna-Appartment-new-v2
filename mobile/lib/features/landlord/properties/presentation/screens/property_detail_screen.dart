import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/properties_provider.dart';

class PropertyDetailScreen extends ConsumerWidget {
  const PropertyDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = GoRouterState.of(context);
    final id = state.pathParameters['id'] ?? '';
    final propertyAsync = ref.watch(propertyDetailProvider(id));

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(context.tr('property_details')),
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
                style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      property.address ?? context.tr('no_address'),
                      style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textLight),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.category_outlined, context.tr('type'), _capitalize(property.type ?? 'N/A')),
                    const Divider(height: 1, indent: 52),
                    _buildInfoRow(Icons.meeting_room_outlined, context.tr('total_units'), '${property.unitsCount ?? 0}'),
                    const Divider(height: 1, indent: 52),
                    _buildInfoRow(Icons.check_circle_outline, context.tr('occupied'), '${property.occupiedUnits ?? 0}'),
                    const Divider(height: 1, indent: 52),
                    _buildInfoRow(Icons.highlight_off, context.tr('vacant'), '${property.vacantUnits ?? 0}'),
                    if (property.monthlyRevenue != null && property.monthlyRevenue! > 0) ...[
                      const Divider(height: 1, indent: 52),
                      _buildInfoRow(Icons.account_balance_wallet_outlined, context.tr('monthly_revenue'), 'TZS ${property.monthlyRevenue!.toStringAsFixed(0)}'),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/landlord/properties/add?id=${property.id}'),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(context.tr('edit')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/landlord/units?propertyId=${property.id}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      icon: const Icon(Icons.meeting_room_outlined, size: 18),
                      label: Text(context.tr('units')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(context.tr('delete_property'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text(context.tr('confirm_delete_property'), style: GoogleFonts.nunito(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('cancel'))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(propertiesRepositoryProvider).deleteProperty(id);
                ref.invalidate(propertiesListProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.tr('property_deleted')), backgroundColor: AppColors.success),
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
            child: Text(context.tr('delete'), style: const TextStyle(color: AppColors.error)),
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
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apartment_outlined, size: 56, color: AppColors.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 8),
            Text(context.tr('no_photos'), style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textLight)),
          ],
        ),
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 220,
            child: PageView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) => Image.network(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  child: const Icon(Icons.apartment_outlined, color: AppColors.primary, size: 48),
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
                  color: index == 0 ? AppColors.primary : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textLight)),
          const Spacer(),
          Text(value, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
