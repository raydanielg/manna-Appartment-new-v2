import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/status_badge.dart';

class UnitCard extends StatelessWidget {
  final Map<String, dynamic> unit;
  const UnitCard({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = unit['name'] ?? unit['unit_number'] ?? 'Unit';
    final rent = unit['monthly_rent'] ?? 0;
    final status = unit['status'] ?? 'vacant';
    final isOccupied = status == 'occupied';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/landlord/units/'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isOccupied ? AppColors.success : AppColors.warning).withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isOccupied ? Icons.check_circle : Icons.meeting_room,
                  color: isOccupied ? AppColors.success : AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                    const SizedBox(height: 2),
                    Text('TZS /month', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
                  ],
                ),
              ),
              StatusBadge(status: status),
            ],
          ),
        ),
      ),
    );
  }
}
