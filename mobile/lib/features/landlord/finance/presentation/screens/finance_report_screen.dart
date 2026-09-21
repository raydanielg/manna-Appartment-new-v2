import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/utils/app_toast.dart';
import '../../providers/finance_provider.dart';
import '../../../properties/providers/properties_provider.dart';
import '../../../units/providers/units_provider.dart';

class FinanceReportScreen extends ConsumerStatefulWidget {
  const FinanceReportScreen({super.key});

  @override
  ConsumerState<FinanceReportScreen> createState() =>
      _FinanceReportScreenState();
}

class _FinanceReportScreenState extends ConsumerState<FinanceReportScreen> {
  String _period = 'monthly';
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  String? _selectedPropertyId;
  String? _selectedUnitId;
  bool _isExporting = false;

  double _parseAmount(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  String _fmt(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final params = RevenueReportParams(
      period: _period,
      year: _selectedYear,
      month: _period == 'monthly' ? _selectedMonth : null,
      propertyId: _selectedPropertyId,
      unitId: _selectedUnitId,
    );
    final reportAsync = ref.watch(revenueReportProvider(params));

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('revenue_report'),
          style: typography.display.md.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: FButton.icon(
          variant: .ghost,
          size: .sm,
          onPress: () => context.pop(),
          child: context.theme.icons.arrowLeft(context),
        ),
        actions: [
          FButton.icon(
            variant: .ghost,
            size: .sm,
            onPress: _isExporting ? null : () => _exportReport(context),
            child: _isExporting
                ? const SizedBox(
                    width: 16, height: 16, child: FCircularProgress())
                : const HugeIcon(
                    icon: HugeIcons.strokeRoundedDownload04, size: null),
          ),
          FButton.icon(
            variant: .ghost,
            size: .sm,
            onPress: () => _showFilterSheet(context),
            child: const HugeIcon(
                icon: HugeIcons.strokeRoundedFilterHorizontal, size: null),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: reportAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(revenueReportProvider(params)),
        ),
        data: (data) => RefreshIndicator(
          color: colors.primary,
          onRefresh: () async =>
              ref.invalidate(revenueReportProvider(params)),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _activeFilterLabel(context),
              const SizedBox(height: 12),
              _reportContent(context, data),
            ],
          ),
        ),
      ),
    );
  }

  // ---- filter sheet ----

  Future<void> _exportReport(BuildContext context) async {
    setState(() => _isExporting = true);
    try {
      final path = await ref.read(financeRepositoryProvider).exportRevenueReport(
            period: _period,
            year: _selectedYear,
            month: _period == 'monthly' ? _selectedMonth : null,
            propertyId: _selectedPropertyId,
            unitId: _selectedUnitId,
          );
      await OpenFilex.open(path);
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context, AppError.getMessage(e));
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _showFilterSheet(BuildContext context) async {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    await showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String period = _period;
        int year = _selectedYear;
        int month = _selectedMonth;
        String? propertyId = _selectedPropertyId;
        String? unitId = _selectedUnitId;
        final currentYear = DateTime.now().year;
        final years = List.generate(10, (i) => currentYear - 4 + i);

        return StatefulBuilder(
          builder: (context, setSheet) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('filter'),
                      style: typography.body.md
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),

                    // Period
                    _sheetLabel(context, context.tr('period')),
                    Wrap(
                      spacing: 6,
                      children: [
                        _sheetChip(context, 'Weekly', period == 'weekly',
                            () => setSheet(() => period = 'weekly')),
                        _sheetChip(
                            context,
                            context.tr('monthly_view'),
                            period == 'monthly',
                            () => setSheet(() => period = 'monthly')),
                        _sheetChip(
                            context,
                            context.tr('yearly_view'),
                            period == 'yearly',
                            () => setSheet(() => period = 'yearly')),
                        _sheetChip(
                            context,
                            context.tr('multi_year_view'),
                            period == 'multi_year',
                            () => setSheet(() => period = 'multi_year')),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date selectors
                    Row(
                      children: [
                        if (period == 'monthly' || period == 'weekly')
                          _sheetPicker(
                            context,
                            label: period == 'weekly' ? 'Week' : context.tr('select_month'),
                            value: period == 'weekly'
                                ? 'Week $month'
                                : DateFormat('MMMM')
                                    .format(DateTime(2020, month, 1)),
                            items: List.generate(
                                period == 'weekly' ? 52 : 12, (i) => i + 1),
                            labelOf: (v) => period == 'weekly'
                                ? 'Week $v'
                                : DateFormat('MMMM')
                                    .format(DateTime(2020, v, 1)),
                            onSelected: (v) =>
                                setSheet(() => month = v),
                          ),
                        if (period == 'monthly' || period == 'weekly')
                          const SizedBox(width: 8),
                        _sheetPicker(
                          context,
                          label: context.tr('select_year'),
                          value: '$year',
                          items: years,
                          labelOf: (v) => '$v',
                          onSelected: (v) => setSheet(() => year = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Property
                    _sheetLabel(context, context.tr('property')),
                    _propertyPicker(context, propertyId,
                        (v) => setSheet(() {
                              propertyId = v;
                              unitId = null;
                            })),
                    const SizedBox(height: 16),

                    // Unit (only if property selected)
                    if (propertyId != null) ...[
                      _sheetLabel(context, context.tr('unit')),
                      _unitPicker(context, propertyId, unitId,
                          (v) => setSheet(() => unitId = v)),
                      const SizedBox(height: 16),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: FButton(
                            variant: .outline,
                            onPress: () {
                              setSheet(() {
                                period = 'monthly';
                                year = DateTime.now().year;
                                month = DateTime.now().month;
                                propertyId = null;
                                unitId = null;
                              });
                            },
                            child: Text(context.tr('clear')),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: FButton(
                            variant: .primary,
                            onPress: () {
                              setState(() {
                                _period = period;
                                _selectedYear = year;
                                _selectedMonth = month;
                                _selectedPropertyId = propertyId;
                                _selectedUnitId = unitId;
                              });
                              Navigator.pop(context);
                            },
                            child: Text(context.tr('apply')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetLabel(BuildContext context, String label) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: typography.body.xs3.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: colors.mutedForeground,
        ),
      ),
    );
  }

  Widget _sheetChip(BuildContext context, String label, bool selected,
      VoidCallback onTap) {
    return FButton(
      variant: selected ? .primary : .outline,
      size: .xs,
      mainAxisSize: MainAxisSize.min,
      onPress: onTap,
      child: Text(label),
    );
  }

  Widget _sheetPicker<T>(
    BuildContext context, {
    required String label,
    required String value,
    required List<T> items,
    required String Function(T) labelOf,
    required ValueChanged<T> onSelected,
  }) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return PopupMenuButton<T>(
      offset: const Offset(0, 40),
      color: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: context.theme.style.borderRadius.lg,
      ),
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final v in items)
          PopupMenuItem(
            value: v,
            child: Text(labelOf(v), style: typography.body.xs2),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          border: Border.all(color: colors.border),
          borderRadius: context.theme.style.borderRadius.md,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: typography.body.xs2
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 6),
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowDown01,
              size: 12,
              color: colors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  Widget _propertyPicker(BuildContext context, String? current,
      ValueChanged<String?> onSelected) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final propertiesAsync = ref.watch(propertiesListProvider);
    return propertiesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (properties) {
        if (properties.isEmpty) return const SizedBox.shrink();
        final names = <String?, String>{
          null: context.tr('select_property_all'),
          for (final p in properties) p.id: p.name,
        };
        return PopupMenuButton<String?>(
          offset: const Offset(0, 40),
          color: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: context.theme.style.borderRadius.lg,
          ),
          onSelected: onSelected,
          itemBuilder: (context) => [
            for (final e in names.entries)
              PopupMenuItem(
                value: e.key,
                child: Text(e.value, style: typography.body.xs2),
              ),
          ],
          child: _pickerBox(context, colors, typography,
              names[current] ?? context.tr('select_property_all')),
        );
      },
    );
  }

  Widget _unitPicker(BuildContext context, String? propertyId, String? current,
      ValueChanged<String?> onSelected) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final unitsAsync = ref.watch(unitsListProvider(propertyId));
    return unitsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (units) {
        if (units.isEmpty) return const SizedBox.shrink();
        final names = <String?, String>{
          null: context.tr('select_unit_all'),
          for (final u in units)
            u['id']?.toString(): (u['name'] ?? u['unit_number'] ?? 'Unit').toString(),
        };
        return PopupMenuButton<String?>(
          offset: const Offset(0, 40),
          color: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: context.theme.style.borderRadius.lg,
          ),
          onSelected: onSelected,
          itemBuilder: (context) => [
            for (final e in names.entries)
              PopupMenuItem(
                value: e.key,
                child: Text(e.value, style: typography.body.xs2),
              ),
          ],
          child: _pickerBox(context, colors, typography,
              names[current] ?? context.tr('select_unit_all')),
        );
      },
    );
  }

  Widget _pickerBox(BuildContext context, FColors colors,
      FTypography typography, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: context.theme.style.borderRadius.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  typography.body.xs2.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          HugeIcon(
            icon: HugeIcons.strokeRoundedArrowDown01,
            size: 14,
            color: colors.mutedForeground,
          ),
        ],
      ),
    );
  }

  // ---- content ----

  Widget _activeFilterLabel(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final parts = <String>[
      switch (_period) {
        'weekly' => 'Weekly',
        'monthly' => context.tr('monthly_view'),
        'yearly' => context.tr('yearly_view'),
        _ => context.tr('multi_year_view'),
      },
      '$_selectedYear',
    ];
    return Text(
      parts.join(' · '),
      style: typography.body.xs3.copyWith(color: colors.mutedForeground),
    );
  }

  Widget _reportContent(BuildContext context, Map<String, dynamic> data) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final expected = _parseAmount(data['expected_revenue']);
    final collected = _parseAmount(data['collected_revenue']);
    final outstanding = _parseAmount(data['outstanding_revenue']);
    final collectionRate = data['collection_rate'];
    final rateStr = collectionRate is num
        ? '${collectionRate.toStringAsFixed(1)}%'
        : '$collectionRate%';

    final breakdown =
        data['breakdown'] is List ? data['breakdown'] as List : [];
    final chartData =
        data['chart_data'] is List ? data['chart_data'] as List : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary stats — plain row
        Row(
          children: [
            _stat(context, context.tr('expected_revenue'), _fmt(expected),
                const Color(0xFF0EA5E9)),
            _stat(context, context.tr('collected_revenue'), _fmt(collected),
                const Color(0xFF16A34A)),
            _stat(context, context.tr('outstanding_revenue'),
                _fmt(outstanding), colors.error),
            _stat(context, context.tr('collection_rate'), rateStr,
                const Color(0xFFD97706)),
          ],
        ),
        const SizedBox(height: 20),
        if (chartData.isNotEmpty) ...[
          Text(
            context.tr('revenue_overview'),
            style: typography.body.sm.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _chart(context, chartData),
          const SizedBox(height: 20),
        ],
        if (breakdown.isNotEmpty) ...[
          Text(
            _selectedUnitId != null
                ? context.tr('revenue_by_unit')
                : context.tr('revenue_by_property'),
            style: typography.body.sm.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...breakdown.map((item) => _breakdownRow(context, item)),
        ],
        if (chartData.isEmpty && breakdown.isEmpty)
          EmptyState(message: context.tr('no_revenue_data')),
      ],
    );
  }

  Widget _stat(BuildContext context, String label, String value, Color color) {
    final typography = context.theme.typography;
    final colors = context.theme.colors;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.body.xs3
                      .copyWith(color: colors.mutedForeground),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                typography.body.md.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _chart(BuildContext context, List<dynamic> chartData) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final spots = <FlSpot>[];
    final labels = <String>[];
    double maxVal = 0;

    for (var i = 0; i < chartData.length; i++) {
      final amount =
          _parseAmount(chartData[i]['amount'] ?? chartData[i]['revenue']);
      spots.add(FlSpot(i.toDouble(), amount));
      labels.add(chartData[i]['label'] ?? chartData[i]['month'] ?? '');
      if (amount > maxVal) maxVal = amount;
    }

    final maxY = maxVal > 0 ? maxVal * 1.2 : 100.0;

    return SizedBox(
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
                reservedSize: 38,
                interval: maxY / 3,
                getTitlesWidget: (value, meta) {
                  if (value <= 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      _fmt(value),
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
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[i],
                      style: typography.body.xs3.copyWith(
                        color: colors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: colors.primary,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                  radius: index == spots.length - 1 ? 4 : 3,
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
                        text: 'TZS ${_fmt(s.y)}',
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
    );
  }

  Widget _breakdownRow(BuildContext context, dynamic item) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final name =
        (item['label'] ?? item['date'] ?? item['month'] ?? 'Unknown')
            .toString();
    final collected = _parseAmount(item['amount'] ?? item['revenue']);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.body.xs2
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              'TZS ${_fmt(collected)}',
              style: typography.body.xs2.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF16A34A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
