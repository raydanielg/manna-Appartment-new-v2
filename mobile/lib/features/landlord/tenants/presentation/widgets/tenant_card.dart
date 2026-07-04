import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/status_badge.dart';

class TenantCard extends StatelessWidget {
  final Map<String, dynamic> tenant;
  const TenantCard({super.key, required this.tenant});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = tenant['full_name'] ?? tenant['name'] ?? 'Unknown';
    final phone = tenant['phone'] ?? '';
    final unit = tenant['unit']?['name'] ?? tenant['unit_name'] ?? 'No unit';
    final status = tenant['status'] ?? 'active';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/landlord/tenants/'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.info, AppColors.primary]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'T',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phone,
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.meeting_room_outlined, size: 14, color: isDark ? Colors.white60 : AppColors.textLight),
                        const SizedBox(width: 4),
                        Text(
                          unit,
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight),
                        ),
                      ],
                    ),
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
