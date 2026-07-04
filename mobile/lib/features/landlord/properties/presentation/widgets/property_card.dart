import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../data/models/property_model.dart';

class PropertyCard extends StatelessWidget {
  final PropertyModel property;
  const PropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final occupied = property.occupiedUnits ?? 0;
    final total = property.unitsCount ?? 0;
    final isFullyOccupied = total > 0 && occupied == total;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/landlord/properties/'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.apartment, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          property.address ?? 'No address',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : AppColors.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (property.type != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        property.type!.toUpperCase(),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.gold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStat(
                    context,
                    icon: Icons.meeting_room_outlined,
                    label: 'Units',
                    value: '',
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 16),
                  _buildStat(
                    context,
                    icon: Icons.check_circle_outline,
                    label: 'Occupied',
                    value: '',
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 16),
                  _buildStat(
                    context,
                    icon: Icons.highlight_off,
                    label: 'Vacant',
                    value: '',
                    color: isFullyOccupied ? AppColors.success : AppColors.warning,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, {required IconData icon, required String label, required String value, required Color color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white60 : AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
