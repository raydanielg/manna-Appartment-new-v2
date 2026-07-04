import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/status_badge.dart';

class ContractCard extends StatelessWidget {
  final Map<String, dynamic> contract;
  const ContractCard({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tenantName = contract['tenant']?['full_name'] ?? 'Unknown';
    final unitName = contract['unit']?['name'] ?? 'N/A';
    final startDate = contract['start_date'] ?? 'N/A';
    final endDate = contract['end_date'] ?? 'N/A';
    final status = contract['status'] ?? 'active';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/landlord/contracts/'),
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
                        Text(tenantName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                        const SizedBox(height: 2),
                        Text('Unit: ', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
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

  Widget _buildDate(BuildContext context, IconData icon, String label, String date) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? Colors.white60 : AppColors.textLight),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : AppColors.textLight)),
            Text(date, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textDark)),
          ],
        ),
      ],
    );
  }
}
