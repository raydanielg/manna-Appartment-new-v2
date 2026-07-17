import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/status_badge.dart';

class ContractCard extends StatelessWidget {
  final Map<String, dynamic> contract;
  const ContractCard({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tenantName = contract['tenant']?['full_name'] ?? contract['tenant']?['user']?['full_name'] ?? 'Unknown';
    final unitName = contract['unit']?['name'] ?? contract['unit']?['unit_number'] ?? 'N/A';
    final startDate = _formatDate(contract['start_date']);
    final endDate = _formatDate(contract['end_date']);
    final status = contract['status'] ?? 'active';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/landlord/contracts/${contract['id']}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: isDark ? 0.15 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.description, color: AppColors.info, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tenantName, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('Unit: $unitName', style: GoogleFonts.nunito(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDate(context, Icons.play_arrow, 'Start', startDate)),
                  Expanded(child: _buildDate(context, Icons.stop, 'End', endDate)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    final dt = DateTime.tryParse(date.toString());
    if (dt == null) return date.toString();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Widget _buildDate(BuildContext context, IconData icon, String label, String date) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? Colors.white60 : AppColors.textLight),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.nunito(fontSize: 10, color: isDark ? Colors.white60 : AppColors.textLight)),
              Text(date, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}
