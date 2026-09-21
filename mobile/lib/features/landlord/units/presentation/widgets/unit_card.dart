import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
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

    return FTappable(
      onPress: () => context.push('/landlord/units/${unit['id']}'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)),
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
                    const SizedBox(height: 2),
                    Text(
                      status.toUpperCase(),
                      style: typography.body.xs3.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'TZS $formattedRent',
                style: typography.body.sm.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '/${context.tr('month')}',
                style: typography.body.xs3
                    .copyWith(color: colors.mutedForeground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
