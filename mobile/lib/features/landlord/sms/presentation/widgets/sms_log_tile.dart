import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/status_badge.dart';

class SmsLogTile extends StatelessWidget {
  final Map<String, dynamic> log;
  const SmsLogTile({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.info.withValues(alpha: isDark ? 0.15 : 0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.sms, color: AppColors.info, size: 20),
        ),
        title: Text(log['recipient'] ?? 'Unknown', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
        subtitle: Text(log['message'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
        trailing: StatusBadge(status: log['status'] ?? 'sent'),
      ),
    );
  }
}
