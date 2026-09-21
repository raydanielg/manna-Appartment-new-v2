import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../../core/localization/app_localizations.dart';

class IncomeChart extends StatelessWidget {
  final Map<String, dynamic> data;
  const IncomeChart({super.key, required this.data});

  double _parseAmount(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final radii = context.theme.style.borderRadius;

    final rawMonthly = data['monthly_income'];
    final monthly = (rawMonthly is List) ? rawMonthly : <dynamic>[];

    final amounts = <double>[];
    final labels = <String>[];
    double maxVal = 0;
    double totalVal = 0;
    int bestIndex = -1;

    for (var i = 0; i < monthly.length; i++) {
      final amount = _parseAmount(monthly[i]['amount']);
      amounts.add(amount);
      labels.add((monthly[i]['month'] ?? '').toString());
      totalVal += amount;
      if (amount > maxVal) maxVal = amount;
      if (bestIndex == -1 || amount > amounts[bestIndex]) bestIndex = i;
    }

    final current = amounts.isNotEmpty ? amounts.last : 0.0;
    final maxY = maxVal > 0 ? maxVal * 1.3 : 100.0;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('monthly_income'),
                        style: typography.body.xs.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TZS ${_formatAmount(current)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.display.xl.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: radii.pill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Last ${monthly.length} ${context.tr('months_label')}',
                        style: typography.body.xs3.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (amounts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedChartLineData01,
                        size: 36,
                        color: colors.mutedForeground.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('no_income_data'),
                        style: typography.body.xs.copyWith(color: colors.mutedForeground),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              SizedBox(
                height: 170,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    minY: 0,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY / 3,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: colors.border.withValues(alpha: 0.5),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 26,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                            final isLatest = i == amounts.length - 1;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[i],
                                style: typography.body.xs3.copyWith(
                                  fontWeight: isLatest ? FontWeight.w800 : FontWeight.w600,
                                  color: isLatest ? colors.primary : colors.mutedForeground,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var i = 0; i < amounts.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: amounts[i],
                              width: 18,
                              borderRadius: BorderRadius.circular(5),
                              color: i == amounts.length - 1
                                  ? colors.primary
                                  : i == bestIndex
                                      ? colors.primary.withValues(alpha: 0.55)
                                      : colors.primary.withValues(alpha: 0.25),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: maxY,
                                color: colors.secondary.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                    ],
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => colors.foreground,
                        tooltipRoundedRadius: 8,
                        tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final i = group.x;
                          return BarTooltipItem(
                            '${labels[i]}\n',
                            typography.body.xs3.copyWith(
                              color: colors.background.withValues(alpha: 0.7),
                            ),
                            children: [
                              TextSpan(
                                text: 'TZS ${_formatAmount(rod.toY)}',
                                style: typography.body.xs2.copyWith(
                                  color: colors.background,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Divider(height: 1, color: colors.border.withValues(alpha: 0.6)),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedAnalytics01,
                        size: 14,
                        color: colors.mutedForeground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '6-Mo Total: ',
                        style: typography.body.xs3.copyWith(color: colors.mutedForeground),
                      ),
                      Text(
                        'TZS ${_formatAmount(totalVal)}',
                        style: typography.body.xs3.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.foreground,
                        ),
                      ),
                    ],
                  ),
                  if (bestIndex >= 0 && amounts[bestIndex] > 0)
                    Text(
                      'Peak: ${labels[bestIndex]} (${_formatAmount(amounts[bestIndex])})',
                      style: typography.body.xs3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
