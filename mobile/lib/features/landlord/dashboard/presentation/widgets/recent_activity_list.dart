import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';

class RecentActivityList extends StatelessWidget {
  final List<dynamic> activities;
  const RecentActivityList({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    if (activities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedInbox,
              size: 36,
              color: colors.mutedForeground.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'No recent activity',
              style: typography.body.xs2.copyWith(color: colors.mutedForeground),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < activities.length; i++)
          _timelineItem(context, activities[i],
              isLast: i == activities.length - 1),
      ],
    );
  }

  Widget _timelineItem(BuildContext context, dynamic a,
      {required bool isLast}) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final status = a['status'] ?? 'info';
    final isSuccess = status == 'success';
    final dotColor =
        isSuccess ? const Color(0xFF16A34A) : const Color(0xFFD97706);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: dotColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: dotColor, width: 2),
                  ),
                ),
                Expanded(
                  child: isLast
                      ? const SizedBox()
                      : Container(
                          width: 1.5,
                          margin: const EdgeInsets.only(top: 2),
                          color: colors.border.withValues(alpha: 0.6),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      HugeIcon(
                        icon: isSuccess
                            ? HugeIcons.strokeRoundedCheckmarkCircle02
                            : HugeIcons.strokeRoundedWrench01,
                        size: 14,
                        color: dotColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          a['title'] ?? 'Activity',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typography.body.xs2
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        a['date'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.body.xs3
                            .copyWith(color: colors.mutedForeground),
                      ),
                    ],
                  ),
                  if ((a['subtitle'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      a['subtitle'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.xs3.copyWith(
                        color: colors.mutedForeground,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
