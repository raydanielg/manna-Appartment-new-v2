import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../../core/localization/app_localizations.dart';

class SummaryCards extends StatelessWidget {
  final Map<String, dynamic> data;
  const SummaryCards({super.key, required this.data});

  String _fmt(dynamic amount) {
    final n = amount is num ? amount.toDouble() : double.tryParse('$amount') ?? 0;
    if (n >= 1000000) return 'TZS ${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return 'TZS ${(n / 1000).toStringAsFixed(0)}K';
    return 'TZS ${n.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final items = [
      _Item(context.tr('properties'), '${data['properties_count'] ?? 0}',
          HugeIcons.strokeRoundedBuilding03, colors.primary),
      _Item(context.tr('tenants'), '${data['tenants_count'] ?? 0}',
          HugeIcons.strokeRoundedUserGroup, const Color(0xFF0EA5E9)),
      _Item(context.tr('income'), _fmt(data['month_income']),
          HugeIcons.strokeRoundedMoney01, const Color(0xFF16A34A)),
      _Item(context.tr('outstanding'), _fmt(data['outstanding']),
          HugeIcons.strokeRoundedAlert02, colors.error),
    ];

    return Column(
      children: [
        for (var i = 0; i < items.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _Card(item: items[i])),
                const SizedBox(width: 12),
                Expanded(child: _Card(item: items[i + 1])),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Item {
  final String label;
  final String value;
  final List<List<dynamic>> icon;
  final Color color;
  const _Item(this.label, this.value, this.icon, this.color);
}

class _Card extends StatelessWidget {
  final _Item item;
  const _Card({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final radii = context.theme.style.borderRadius;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                borderRadius: radii.md,
              ),
              child: Center(
                child: HugeIcon(icon: item.icon, size: 20, color: item.color),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              item.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.display.lg.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.body.xs.copyWith(color: colors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}
