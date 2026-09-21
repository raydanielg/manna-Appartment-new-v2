import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../../../core/localization/app_localizations.dart';

class UnitCard extends StatelessWidget {
  final Map<String, dynamic> unit;
  const UnitCard({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    final name = unit['name'] ?? unit['unit_number'] ?? context.tr('unit');
    final rent = unit['monthly_rent'] ?? 0;
    final formattedRent = NumberFormat('#,###')
        .format(rent is num ? rent : (double.tryParse(rent.toString()) ?? 0));
    final status = (unit['status'] ?? 'vacant').toString();
    final isOccupied = status == 'occupied';
    final statusColor =
        isOccupied ? const Color(0xFF16A34A) : const Color(0xFFD97706);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FTappable(
        onPress: () => context.push('/landlord/units/${unit['id']}'),
        child: FCard(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: isOccupied
                          ? HugeIcons.strokeRoundedCheckmarkCircle02
                          : HugeIcons.strokeRoundedDoor01,
                      size: 20,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                      const SizedBox(height: 2),
                      Text(
                        'TZS $formattedRent/${context.tr('month')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.body.xs2
                            .copyWith(color: colors.mutedForeground),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: context.theme.style.borderRadius.pill,
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: typography.body.xs3.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
