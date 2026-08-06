import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
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
        title: Text(context.tr('units')),
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
                EmptyState(message: context.tr('no_units_tap'), icon: Icons.meeting_room_outlined)
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
                        title: Text(context.tr('delete_unit'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                        content: Text(context.tr('confirm_delete_unit'), style: GoogleFonts.nunito(fontSize: 14)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.tr('cancel'))),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(context.tr('delete'), style: const TextStyle(color: AppColors.error)),
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
                          SnackBar(content: Text(context.tr('unit_deleted')), backgroundColor: AppColors.success),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.tr('failed_msg').replaceAll('{0}', e.toString())), backgroundColor: AppColors.error),
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
                      context.tr('add_unit'),
                      style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('create_new_unit'),
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
