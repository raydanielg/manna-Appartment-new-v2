import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/finance_provider.dart';
import '../../../properties/providers/properties_provider.dart';
import '../../../units/providers/units_provider.dart';

class FinanceReportScreen extends ConsumerStatefulWidget {
  const FinanceReportScreen({super.key});

  @override
  ConsumerState<FinanceReportScreen> createState() => _FinanceReportScreenState();
}

class _FinanceReportScreenState extends ConsumerState<FinanceReportScreen> {
  String _period = 'monthly';
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  String? _selectedPropertyId;
  String? _selectedUnitId;
  bool _showUnitFilter = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final params = RevenueReportParams(
      period: _period,
      year: _selectedYear,
      month: _period == 'monthly' ? _selectedMonth : null,
      propertyId: _selectedPropertyId,
      unitId: _selectedUnitId,
    );
    final reportAsync = ref.watch(revenueReportProvider(params));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(context.tr('revenue_report'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodFilter(isDark),
            const SizedBox(height: 16),
            if (_period == 'monthly') _buildMonthYearPicker(isDark),
            if (_period == 'yearly') _buildYearPicker(isDark),
            if (_period == 'multi_year') _buildMultiYearPicker(isDark),
            const SizedBox(height: 16),
            _buildPropertyFilter(isDark),
            if (_showUnitFilter) ...[
              const SizedBox(height: 16),
              _buildUnitFilter(isDark),
            ],
            const SizedBox(height: 24),
            reportAsync.when(
              loading: () => const LoadingIndicator(),
              error: (e, _) => ErrorState(
                message: e.toString(),
                onRetry: () => ref.invalidate(revenueReportProvider(params)),
              ),
              data: (data) => _buildReportContent(data, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodFilter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          _buildPeriodTab(context.tr('monthly_view'), 'monthly'),
          _buildPeriodTab(context.tr('yearly_view'), 'yearly'),
          _buildPeriodTab(context.tr('multi_year_view'), 'multi_year'),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String label, String value) {
    final isSelected = _period == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _period = value;
          _selectedUnitId = null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthYearPicker(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            isDark,
            context.tr('select_month'),
            _selectedMonth,
            List.generate(12, (i) => i + 1),
            (v) => setState(() => _selectedMonth = v),
            (v) => DateFormat('MMMM').format(DateTime(2020, v, 1)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDropdown(
            isDark,
            context.tr('select_year'),
            _selectedYear,
            List.generate(10, (i) => DateTime.now().year - 4 + i),
            (v) => setState(() => _selectedYear = v),
            (v) => '$v',
          ),
        ),
      ],
    );
  }

  Widget _buildYearPicker(bool isDark) {
    return _buildDropdown(
      isDark,
      context.tr('select_year'),
      _selectedYear,
      List.generate(10, (i) => DateTime.now().year - 4 + i),
      (v) => setState(() => _selectedYear = v),
      (v) => '$v',
    );
  }

  Widget _buildMultiYearPicker(bool isDark) {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (i) => currentYear - 4 + i);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('select_year'), style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textLight)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: years.map((y) {
              final isSelected = y <= _selectedYear && y >= _selectedYear - 2;
              return ChoiceChip(
                label: Text('$y', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.textLight)),
                selected: y == _selectedYear,
                selectedColor: AppColors.primary,
                backgroundColor: isDark ? AppColors.darkInput : AppColors.lightInput,
                onSelected: (_) => setState(() => _selectedYear = y),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(bool isDark, String hint, int value, List<int> items, ValueChanged<int> onChanged, String Function(int) labelBuilder) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: DropdownButton<int>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        items: items.map((v) => DropdownMenuItem(value: v, child: Text(labelBuilder(v), style: GoogleFonts.nunito(fontSize: 14)))).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    );
  }

  Widget _buildPropertyFilter(bool isDark) {
    final propertiesAsync = ref.watch(propertiesListProvider);
    return propertiesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (properties) {
        if (properties.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('all_properties'), style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textLight)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
              ),
              child: DropdownButton<String>(
                value: _selectedPropertyId,
                isExpanded: true,
                underline: const SizedBox(),
                hint: Text(context.tr('select_property_all'), style: GoogleFonts.nunito(fontSize: 14)),
                items: [
                  DropdownMenuItem(value: null, child: Text(context.tr('select_property_all'), style: GoogleFonts.nunito(fontSize: 14))),
                  ...properties.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name, style: GoogleFonts.nunito(fontSize: 14)))),
                ],
                onChanged: (v) => setState(() {
                  _selectedPropertyId = v;
                  _selectedUnitId = null;
                  _showUnitFilter = v != null;
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUnitFilter(bool isDark) {
    final unitsAsync = ref.watch(unitsListProvider(_selectedPropertyId));
    return unitsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (units) {
        if (units.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('select_unit_all'), style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textLight)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
              ),
              child: DropdownButton<String>(
                value: _selectedUnitId,
                isExpanded: true,
                underline: const SizedBox(),
                hint: Text(context.tr('select_unit_all'), style: GoogleFonts.nunito(fontSize: 14)),
                items: [
                  DropdownMenuItem(value: null, child: Text(context.tr('select_unit_all'), style: GoogleFonts.nunito(fontSize: 14))),
                  ...units.map((u) => DropdownMenuItem(
                    value: u['id']?.toString(),
                    child: Text(u['name'] ?? u['unit_number'] ?? 'Unit', style: GoogleFonts.nunito(fontSize: 14)),
                  )),
                ],
                onChanged: (v) => setState(() => _selectedUnitId = v),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportContent(Map<String, dynamic> data, bool isDark) {
    final totalRevenue = _parseAmount(data['total_revenue']);
    final expectedRevenue = _parseAmount(data['expected_revenue']);
    final collectedRevenue = _parseAmount(data['collected_revenue']);
    final outstandingRevenue = _parseAmount(data['outstanding_revenue']);
    final collectionRate = data['collection_rate'];
    final rateStr = collectionRate is num
        ? '${collectionRate.toStringAsFixed(1)}%'
        : '$collectionRate%';

    final breakdown = data['breakdown'] is List ? data['breakdown'] as List : [];
    final chartData = data['chart_data'] is List ? data['chart_data'] as List : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryCards(expectedRevenue, collectedRevenue, outstandingRevenue, rateStr, isDark),
        const SizedBox(height: 24),
        if (chartData.isNotEmpty) ...[
          Text(context.tr('revenue_overview'), style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
          const SizedBox(height: 12),
          _buildRevenueChart(chartData, isDark),
          const SizedBox(height: 24),
        ],
        if (breakdown.isNotEmpty) ...[
          Text(
            _selectedUnitId != null ? context.tr('revenue_by_unit') : context.tr('revenue_by_property'),
            style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark),
          ),
          const SizedBox(height: 12),
          _buildBreakdownList(breakdown, isDark),
        ],
        if (chartData.isEmpty && breakdown.isEmpty)
          EmptyState(message: context.tr('no_revenue_data')),
      ],
    );
  }

  Widget _buildSummaryCards(double expected, double collected, double outstanding, String rate, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.4,
      children: [
        _buildSummaryCard(context.tr('expected_revenue'), _formatAmount(expected), AppColors.info, Icons.account_balance_wallet_outlined, isDark),
        _buildSummaryCard(context.tr('collected_revenue'), _formatAmount(collected), AppColors.success, Icons.check_circle_outline, isDark),
        _buildSummaryCard(context.tr('outstanding_revenue'), _formatAmount(outstanding), AppColors.error, Icons.error_outline, isDark),
        _buildSummaryCard(context.tr('collection_rate'), rate, AppColors.warning, Icons.pie_chart_outline, isDark),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textLight))),
            ],
          ),
          Text(value, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(List<dynamic> chartData, bool isDark) {
    final spots = <FlSpot>[];
    final labels = <String>[];
    double maxVal = 0;

    for (var i = 0; i < chartData.length; i++) {
      final amount = _parseAmount(chartData[i]['amount'] ?? chartData[i]['revenue']);
      spots.add(FlSpot(i.toDouble(), amount));
      labels.add(chartData[i]['label'] ?? chartData[i]['month'] ?? '');
      if (amount > maxVal) maxVal = amount;
    }

    final maxY = maxVal > 0 ? maxVal * 1.2 : 100.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('total_revenue'), style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textLight)),
          if (spots.isNotEmpty)
            Text('TZS ${_formatAmount(spots.last.y)}', style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (_) => FlLine(color: isDark ? Colors.white10 : const Color(0xFFF1F5F9), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      interval: maxY / 3,
                      getTitlesWidget: (value, _) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(_formatAmount(value), style: GoogleFonts.nunito(fontSize: 9, color: AppColors.textLight)),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, _) {
                        final i = value.toInt();
                        if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(labels[i], style: GoogleFonts.nunito(fontSize: 10, color: AppColors.textLight)),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    barWidth: 3,
                    color: AppColors.primary,
                    dotData: FlDotData(show: true, getDotPainter: (spot, _, __, index) {
                      final isLast = index == spots.length - 1;
                      return FlDotCirclePainter(radius: isLast ? 6 : 4, color: Colors.white, strokeWidth: 2.5, strokeColor: AppColors.primary);
                    }),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primary.withValues(alpha: 0.15), AppColors.primary.withValues(alpha: 0.0)],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.textDark,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                      return LineTooltipItem('TZS ${_formatAmount(spot.y)}', GoogleFonts.nunito(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700));
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownList(List<dynamic> breakdown, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: breakdown.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = breakdown[index];
        final name = item['name'] ?? item['property_name'] ?? item['unit_name'] ?? 'Unknown';
        final collected = _parseAmount(item['collected'] ?? item['amount']);
        final expected = _parseAmount(item['expected']);
        final outstanding = _parseAmount(item['outstanding']);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildBreakdownItem(context.tr('collected_revenue'), _formatAmount(collected), AppColors.success),
                  const SizedBox(width: 12),
                  _buildBreakdownItem(context.tr('outstanding_revenue'), _formatAmount(outstanding), AppColors.error),
                ],
              ),
              if (expected > 0) ...[
                const SizedBox(height: 4),
                _buildBreakdownItem(context.tr('expected_revenue'), _formatAmount(expected), AppColors.info),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreakdownItem(String label, String value, Color color) {
    return Expanded(
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Flexible(
            child: Text('$label: $value', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textLight)),
          ),
        ],
      ),
    );
  }

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
}
