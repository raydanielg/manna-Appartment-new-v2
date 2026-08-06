import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

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

  String _formatFull(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawMonthly = data['monthly_income'];
    final monthly = (rawMonthly is List) ? rawMonthly : <dynamic>[];

    final spots = <FlSpot>[];
    final labels = <String>[];
    double maxVal = 0;

    for (var i = 0; i < monthly.length; i++) {
      final amount = _parseAmount(monthly[i]['amount']);
      spots.add(FlSpot(i.toDouble(), amount));
      labels.add(monthly[i]['month'] ?? '');
      if (amount > maxVal) maxVal = amount;
    }

    final chartHeight = 200.0;
    final minY = 0.0;
    final maxY = maxVal > 0 ? maxVal * 1.25 : 100.0;
    final totalIncome = spots.fold<double>(0, (sum, s) => sum + s.y);
    final allZero = maxVal == 0;
    final hasData = spots.isNotEmpty && !allZero;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Income',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (spots.isNotEmpty)
                      Text(
                        allZero
                            ? 'TZS 0'
                            : 'TZS ${_formatAmount(totalIncome)}',
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: allZero ? AppColors.textLight : AppColors.primary,
                        ),
                      ),
                    if (spots.isNotEmpty)
                      Text(
                        allZero ? 'No income recorded yet' : 'Total for ${monthly.length} months',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textLight,
                        ),
                      ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Last ${monthly.length} months',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (spots.isEmpty || !hasData)
              _buildEmptyState(labels, chartHeight)
            else
              SizedBox(
                height: chartHeight,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY > 0 ? maxY / 4 : 25,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: const Color(0xFFF1F5F9),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 38,
                          interval: maxY > 0 ? maxY / 3 : 25,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                _formatAmount(value),
                                style: GoogleFonts.nunito(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textLight,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[i],
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textLight,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: (spots.length > 1 ? (spots.length - 1).toDouble() : 1.0),
                    minY: minY,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.35,
                        preventCurveOverShooting: true,
                        barWidth: 3,
                        color: AppColors.primary,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            final isLast = index == spots.length - 1;
                            return FlDotCirclePainter(
                              radius: isLast ? 6 : 4,
                              color: Colors.white,
                              strokeWidth: 2.5,
                              strokeColor: AppColors.primary,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.15),
                              AppColors.primary.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => AppColors.textDark,
                        tooltipRoundedRadius: 8,
                        tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              'TZS ${_formatAmount(spot.y)}',
                              GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(List<String> labels, double height) {
    return SizedBox(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.trending_up_rounded,
                      size: 32,
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No income recorded yet',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Income will appear here once payments are confirmed',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: AppColors.textLight.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          if (labels.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: labels.map((l) => Text(
                l,
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight.withValues(alpha: 0.5),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
