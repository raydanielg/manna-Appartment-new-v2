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
    final cardColor = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark ? Colors.white10 : const Color(0xFFE5E7EB);

    if (activities.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 40, color: isDark ? Colors.white24 : Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'No recent activity',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white38 : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? null
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: activities.asMap().entries.map((entry) {
          final a = entry.value;
          final isLast = entry.key == activities.length - 1;
          final status = a['status'] ?? 'info';
          final isSuccess = status == 'success';

          return Container(
            decoration: isLast
                ? null
                : BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? Colors.white10 : const Color(0xFFF3F4F6),
                        width: 1,
                      ),
                    ),
                  ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSuccess
                          ? const Color(0xFF059669).withValues(alpha: 0.1)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isSuccess ? Icons.check_circle_outline : Icons.build_outlined,
                      color: isSuccess ? const Color(0xFF059669) : const Color(0xFFF59E0B),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a['title'] ?? 'Activity',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a['subtitle'] ?? '',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white54 : AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: status),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
