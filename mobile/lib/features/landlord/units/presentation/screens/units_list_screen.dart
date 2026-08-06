import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/units_provider.dart';
import '../widgets/unit_card.dart';

class UnitsListScreen extends ConsumerWidget {
  final String? propertyId;
  const UnitsListScreen({super.key, this.propertyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(unitsListProvider(propertyId));

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Units'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(unitsListProvider(propertyId)),
        color: AppColors.primary,
        child: unitsAsync.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(unitsListProvider(propertyId))),
          data: (units) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAddUnitCard(context),
              const SizedBox(height: 16),
              if (units.isEmpty)
                const EmptyState(message: 'No units yet. Tap above to add your first unit.', icon: Icons.meeting_room_outlined)
              else
                ...units.map((unit) => Dismissible(
                  key: Key(unit['id']?.toString() ?? UniqueKey().toString()),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text('Delete Unit', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                        content: Text('Are you sure you want to delete this unit?', style: GoogleFonts.nunito(fontSize: 14)),
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
                      await ref.read(unitsRepositoryProvider).deleteUnit(unit['id'].toString());
                      ref.invalidate(unitsListProvider(propertyId));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Unit deleted'), backgroundColor: AppColors.success),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
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

  Widget _buildAddUnitCard(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/landlord/units/add?propertyId=${propertyId ?? ''}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Unit',
                      style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Create a new unit for this property',
                      style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
