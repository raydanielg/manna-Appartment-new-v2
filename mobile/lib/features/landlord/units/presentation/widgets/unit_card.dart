import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/status_badge.dart';

class UnitCard extends StatelessWidget {
  final Map<String, dynamic> unit;
  const UnitCard({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final name = unit['name'] ?? unit['unit_number'] ?? 'Unit';
    final rent = unit['monthly_rent'] ?? 0;
    final formattedRent = NumberFormat('#,###').format(rent is num ? rent : (double.tryParse(rent.toString()) ?? 0));
    final status = unit['status'] ?? 'vacant';
    final isOccupied = status == 'occupied';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/landlord/units/${unit['id']}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isOccupied ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isOccupied ? Icons.check_circle_outline : Icons.meeting_room_outlined,
                  color: isOccupied ? AppColors.success : AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'TZS $formattedRent/month',
                      style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: status),
            ],
          ),
        ),
      ),
    );
  }
}
