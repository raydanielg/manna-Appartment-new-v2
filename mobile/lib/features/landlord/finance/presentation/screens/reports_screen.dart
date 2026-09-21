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
import '../../providers/finance_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('reports'),
          style: typography.display.md.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: FButton.icon(
          variant: .ghost,
          size: .sm,
          onPress: () => context.pop(),
          child: context.theme.icons.arrowLeft(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.primary,
          unselectedLabelColor: colors.mutedForeground,
          indicatorColor: colors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: typography.body.xs2.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle:
              typography.body.xs2.copyWith(fontWeight: FontWeight.w500),
          tabs: [
            Tab(text: context.tr('expiry_reports')),
            Tab(text: context.tr('debt_reports')),
            Tab(text: context.tr('lease_reports')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ExpiryReportTab(),
          _DebtReportTab(),
          _LeaseReportTab(),
        ],
      ),
    );
  }
}

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

class _ExpiryReportTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(expiryReportProvider(30));

    return reportAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(expiryReportProvider(30)),
      ),
      data: (data) {
        final expiring = data['expiring'] is List ? data['expiring'] as List : [];
        final expired = data['expired'] is List ? data['expired'] as List : [];

        if (expiring.isEmpty && expired.isEmpty) {
          return EmptyState(message: context.tr('no_expiring_contracts'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (expired.isNotEmpty) ...[
              _header(context, context.tr('expired_contracts'), expired.length,
                  context.theme.colors.error),
              ...expired.map((item) =>
                  _expiryRow(context, item, isExpired: true)),
            ],
            if (expiring.isNotEmpty) ...[
              _header(context, context.tr('expiring_contracts'),
                  expiring.length, const Color(0xFFD97706)),
              ...expiring.map((item) =>
                  _expiryRow(context, item, isExpired: false)),
            ],
          ],
        );
      },
    );
  }

  Widget _header(BuildContext context, String title, int count, Color color) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: typography.body.xs3.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: colors.mutedForeground,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '($count)',
            style: typography.body.xs3
                .copyWith(fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Widget _expiryRow(BuildContext context, dynamic item,
      {required bool isExpired}) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final map = item as Map<String, dynamic>;
    final tenantName =
        map['tenant_name'] ?? map['tenant']?['full_name'] ?? 'Unknown';
    final propertyName = map['property_name'] ?? map['property']?['name'] ?? '';
    final unitName = map['unit_name'] ?? map['unit']?['name'] ?? '';
    final endDate = map['end_date'] ?? map['lease_end'];
    final endDateStr = endDate != null
        ? DateFormat('dd MMM yyyy')
            .format(DateTime.tryParse(endDate.toString()) ?? DateTime.now())
        : '-';
    final color = isExpired ? colors.error : const Color(0xFFD97706);

    return FTappable(
      onPress: () {},
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              HugeIcon(
                icon: isExpired
                    ? HugeIcons.strokeRoundedAlert02
                    : HugeIcons.strokeRoundedClock01,
                size: 17,
                color: color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenantName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.sm
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (propertyName.isNotEmpty || unitName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '$propertyName · $unitName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.body.xs3
                            .copyWith(color: colors.mutedForeground),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    endDateStr,
                    style: typography.body.xs3.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    context.tr('lease_end'),
                    style: typography.body.xs3
                        .copyWith(color: colors.mutedForeground),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DebtReportTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(debtReportProvider);

    return reportAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(debtReportProvider),
      ),
      data: (data) {
        final debts = data['debts'] is List ? data['debts'] as List : [];
        final totalDebts = _parseAmount(data['total_debts']);

        if (debts.isEmpty) {
          return EmptyState(message: context.tr('no_debts'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary header — plain, no card
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('total_debts').toUpperCase(),
                        style: context.theme.typography.body.xs3.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: context.theme.colors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TZS ${_fmt(totalDebts)}',
                        style: context.theme.typography.display.md.copyWith(
                          fontWeight: FontWeight.w800,
                          color: context.theme.colors.error,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: context.theme.colors.error.withValues(alpha: 0.1),
                    borderRadius: context.theme.style.borderRadius.pill,
                  ),
                  child: Text(
                    '${debts.length} ${context.tr('tenants_in_debt')}',
                    style: context.theme.typography.body.xs3.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.theme.colors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...debts.map((item) => _debtRow(context, item)),
          ],
        );
      },
    );
  }

  Widget _debtRow(BuildContext context, dynamic item) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final map = item as Map<String, dynamic>;
    final tenantName =
        map['tenant_name'] ?? map['tenant']?['full_name'] ?? 'Unknown';
    final propertyName = map['property_name'] ?? map['property']?['name'] ?? '';
    final unitName = map['unit_name'] ?? map['unit']?['name'] ?? '';
    final amount = _parseAmount(map['amount'] ?? map['outstanding']);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tenantName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.body.sm
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (propertyName.isNotEmpty || unitName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$propertyName · $unitName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.xs3
                          .copyWith(color: colors.mutedForeground),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'TZS ${_fmt(amount)}',
              style: typography.body.sm.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaseReportTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_LeaseReportTab> createState() => _LeaseReportTabState();
}

class _LeaseReportTabState extends ConsumerState<_LeaseReportTab> {
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final reportAsync = ref.watch(leaseReportProvider(_selectedYear));
    final years =
        List.generate(5, (i) => DateTime.now().year - 2 + i);

    return Column(
      children: [
        // Year selector — FButton chips
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text(
                context.tr('select_year'),
                style: typography.body.xs2
                    .copyWith(color: colors.mutedForeground),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final y in years)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FButton(
                            variant:
                                y == _selectedYear ? .primary : .outline,
                            size: .xs,
                            mainAxisSize: MainAxisSize.min,
                            onPress: () =>
                                setState(() => _selectedYear = y),
                            child: Text('$y'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: reportAsync.when(
            loading: () => const LoadingIndicator(),
            error: (e, _) => ErrorState(
              message: e.toString(),
              onRetry: () =>
                  ref.invalidate(leaseReportProvider(_selectedYear)),
            ),
            data: (data) {
              final expected = _parseAmount(data['expected']);
              final collected = _parseAmount(data['collected']);
              final outstanding = _parseAmount(data['outstanding']);
              final leases =
                  data['leases'] is List ? data['leases'] as List : [];

              if (expected == 0 &&
                  collected == 0 &&
                  outstanding == 0 &&
                  leases.isEmpty) {
                return EmptyState(message: context.tr('no_revenue_data'));
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Summary — plain stat rows
                  _statRow(context, context.tr('lease_expected'),
                      'TZS ${_fmt(expected)}', const Color(0xFF0EA5E9),
                      HugeIcons.strokeRoundedWallet01),
                  Divider(
                      height: 20,
                      color: colors.border.withValues(alpha: 0.6)),
                  _statRow(context, context.tr('lease_collected'),
                      'TZS ${_fmt(collected)}', const Color(0xFF16A34A),
                      HugeIcons.strokeRoundedCheckmarkCircle02),
                  Divider(
                      height: 20,
                      color: colors.border.withValues(alpha: 0.6)),
                  _statRow(context, context.tr('lease_outstanding'),
                      'TZS ${_fmt(outstanding)}', colors.error,
                      HugeIcons.strokeRoundedAlert02),
                  if (leases.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      context.tr('lease_reports').toUpperCase(),
                      style: typography.body.xs3.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: colors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...leases.map((item) => _leaseRow(context, item)),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _statRow(BuildContext context, String label, String value,
      Color color, List<List<dynamic>> icon) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Row(
      children: [
        HugeIcon(icon: icon, size: 17, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: typography.body.xs2
                  .copyWith(color: colors.mutedForeground)),
        ),
        Text(
          value,
          style: typography.body.md
              .copyWith(fontWeight: FontWeight.w800, color: color),
        ),
      ],
    );
  }

  Widget _leaseRow(BuildContext context, dynamic item) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final map = item as Map<String, dynamic>;
    final tenantName =
        map['tenant_name'] ?? map['tenant']?['full_name'] ?? 'Unknown';
    final propertyName = map['property_name'] ?? map['property']?['name'] ?? '';
    final unitName = map['unit_name'] ?? map['unit']?['name'] ?? '';
    final expected = _parseAmount(map['expected']);
    final collected = _parseAmount(map['collected']);
    final outstanding = _parseAmount(map['outstanding']);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tenantName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  typography.body.sm.copyWith(fontWeight: FontWeight.w600),
            ),
            if (propertyName.isNotEmpty || unitName.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                '$propertyName · $unitName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.body.xs3
                    .copyWith(color: colors.mutedForeground),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                _mini(context, context.tr('lease_expected'),
                    _fmt(expected), const Color(0xFF0EA5E9)),
                _mini(context, context.tr('lease_collected'),
                    _fmt(collected), const Color(0xFF16A34A)),
                _mini(context, context.tr('lease_outstanding'),
                    _fmt(outstanding), colors.error),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _mini(BuildContext context, String label, String value, Color color) {
    final typography = context.theme.typography;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.body.xs3.copyWith(
                color: context.theme.colors.mutedForeground),
          ),
          Text(
            value,
            style: typography.body.xs2
                .copyWith(fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}
