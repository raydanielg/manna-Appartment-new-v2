import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../../core/localization/app_localizations.dart';

class SummaryCards extends StatelessWidget {
  final Map<String, dynamic> data;
  const SummaryCards({super.key, required this.data});

  String _fmt(dynamic amount) {
    final n = amount is num ? amount.toDouble() : double.tryParse('$amount') ?? 0;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final items = [
      _Item(context.tr('properties'), '${data['properties_count'] ?? 0}',
          HugeIcons.strokeRoundedBuilding03, colors.primary),
      _Item(context.tr('vacant'), '${data['vacant_units_count'] ?? 0}',
          HugeIcons.strokeRoundedDoor01, const Color(0xFFD97706)),
      _Item(context.tr('tenants'), '${data['tenants_count'] ?? 0}',
          HugeIcons.strokeRoundedUserGroup, const Color(0xFF0EA5E9)),
      _Item(context.tr('income'), _fmt(data['month_income']),
          HugeIcons.strokeRoundedMoney01, const Color(0xFF16A34A)),
      _Item(context.tr('outstanding'), _fmt(data['outstanding']),
          HugeIcons.strokeRoundedAlert02, colors.error),
    ];

    return Row(
      children: [
        for (final item in items)
          Expanded(child: _Stat(item: item)),
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

class _Stat extends StatelessWidget {
  final _Item item;
  const _Stat({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Column(
      children: [
        HugeIcon(icon: item.icon, size: 18, color: item.color),
        const SizedBox(height: 6),
        Text(
          item.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: typography.body.sm.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: typography.body.xs3.copyWith(color: colors.mutedForeground),
        ),
      ],
    );
  }
}
