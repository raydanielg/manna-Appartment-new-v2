import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final vacant = property.vacantUnits ?? (total - occupied);
    final isFullyOccupied = total > 0 && occupied == total;
    final hasImage = property.imageUrl != null && property.imageUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.push('/landlord/properties/${property.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: hasImage
                        ? Image.network(
                            property.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.apartment, color: AppColors.primary, size: 48),
                          )
                        : const Icon(Icons.apartment, color: AppColors.primary, size: 48),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isFullyOccupied ? Colors.green : (vacant > 0 ? Colors.orange : Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isFullyOccupied ? 'Fully Occupied' : (vacant > 0 ? '$vacant Vacant' : 'No Units'),
                      style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          property.name,
                          style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark),
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
                            style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.gold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    property.address ?? 'No address',
                    style: GoogleFonts.nunito(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildStat(context, icon: Icons.meeting_room_outlined, label: 'Units', value: '$total', color: AppColors.info),
                      const SizedBox(width: 16),
                      _buildStat(context, icon: Icons.check_circle_outline, label: 'Occupied', value: '$occupied', color: AppColors.success),
                      const SizedBox(width: 16),
                      _buildStat(context, icon: Icons.highlight_off, label: 'Vacant', value: '$vacant', color: isFullyOccupied ? AppColors.success : AppColors.warning),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
                style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark),
              ),
              Text(
                label,
                style: GoogleFonts.nunito(fontSize: 10, color: isDark ? Colors.white60 : AppColors.textLight),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
