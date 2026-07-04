import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/status_badge.dart';

class RecentActivityList extends StatelessWidget {
  final List<dynamic> activities;
  const RecentActivityList({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (activities.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 48, color: isDark ? Colors.white30 : Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('No recent activity', style: TextStyle(color: isDark ? Colors.white60 : AppColors.textLight)),
            ],
          ),
        ),
      );
    }
    return Column(
      children: activities.map((a) {
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(a['title'] ?? 'Activity', style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
            subtitle: Text(a['subtitle'] ?? '', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
            trailing: StatusBadge(status: a['status'] ?? 'info'),
          ),
        );
      }).toList(),
    );
  }
}
