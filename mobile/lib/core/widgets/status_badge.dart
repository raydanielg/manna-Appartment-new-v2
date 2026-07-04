import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final Color? color;

  const StatusBadge({super.key, required this.status, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeColor = color ?? _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: isDark ? 0.15 : 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: badgeColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _statusColor(String value) {
    final s = value.toLowerCase();
    if (s.contains('active') || s.contains('paid') || s.contains('sent') || s.contains('confirmed') || s.contains('resolved')) {
      return AppColors.success;
    }
    if (s.contains('pending') || s.contains('queued') || s.contains('in progress')) {
      return AppColors.warning;
    }
    if (s.contains('overdue') || s.contains('failed') || s.contains('inactive') || s.contains('rejected')) {
      return AppColors.error;
    }
    return AppColors.info;
  }
}
