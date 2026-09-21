import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
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

    final rawMonthly = data['monthly_income'];
    final monthly = (rawMonthly is List) ? rawMonthly : <dynamic>[];

    final amounts = <double>[];
    final labels = <String>[];
    double maxVal = 0;

    for (var i = 0; i < monthly.length; i++) {
      final amount = _parseAmount(monthly[i]['amount']);
      amounts.add(amount);
      labels.add((monthly[i]['month'] ?? '').toString());
      if (amount > maxVal) maxVal = amount;
    }

    final current = amounts.isNotEmpty ? amounts.last : 0.0;
    final maxY = maxVal > 0 ? maxVal * 1.2 : 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header — amount + period
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('monthly_income'),
                    style: typography.body.xs2.copyWith(
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
                    ),
                  ),
                ],
              ),
            ),
            FTappable(
              onPress: () => context.push('/landlord/finance-report'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.border),
                  borderRadius: context.theme.style.borderRadius.pill,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${monthly.length}M',
                      style: typography.body.xs3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.mutedForeground,
                      ),
                    ),
                    const SizedBox(width: 3),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowDown01,
                      size: 11,
                      color: colors.mutedForeground,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

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
                    style: typography.body.xs
                        .copyWith(color: colors.mutedForeground),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 3,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: colors.border.withValues(alpha: 0.5),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: maxY / 3,
                      getTitlesWidget: (value, meta) {
                        if (value <= 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            _formatAmount(value),
                            maxLines: 1,
                            textAlign: TextAlign.right,
                            style: typography.body.xs3.copyWith(
                              color: colors.mutedForeground,
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        final isLatest = i == amounts.length - 1;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            labels[i],
                            style: typography.body.xs3.copyWith(
                              fontWeight: isLatest
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isLatest
                                  ? colors.primary
                                  : colors.mutedForeground,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < amounts.length; i++)
                        FlSpot(i.toDouble(), amounts[i]),
                    ],
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: colors.primary,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: index == amounts.length - 1 ? 4 : 3,
                        color: colors.primary,
                        strokeWidth: 2,
                        strokeColor: colors.background,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.primary.withValues(alpha: 0.15),
                          colors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => colors.foreground,
                    tooltipRoundedRadius: 8,
                    tooltipPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    getTooltipItems: (spots) => [
                      for (final s in spots)
                        LineTooltipItem(
                          '${labels[s.x.toInt()]}\n',
                          typography.body.xs3.copyWith(
                            color: colors.background.withValues(alpha: 0.7),
                          ),
                          children: [
                            TextSpan(
                              text: 'TZS ${_formatAmount(s.y)}',
                              style: typography.body.xs2.copyWith(
                                color: colors.background,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
