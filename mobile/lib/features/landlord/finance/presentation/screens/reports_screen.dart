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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(context.tr('reports'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textLight,
          indicatorColor: AppColors.primary,
          labelStyle: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700),
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

class _ExpiryReportTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          padding: const EdgeInsets.all(20),
          children: [
            if (expired.isNotEmpty) ...[
              _buildSectionHeader(context, context.tr('expired_contracts'), expired.length, AppColors.error),
              const SizedBox(height: 12),
              ...expired.map((item) => _buildExpiryCard(context, item, isDark, isExpired: true)),
              const SizedBox(height: 24),
            ],
            if (expiring.isNotEmpty) ...[
              _buildSectionHeader(context, context.tr('expiring_contracts'), expiring.length, AppColors.warning),
              const SizedBox(height: 12),
              ...expiring.map((item) => _buildExpiryCard(context, item, isDark, isExpired: false)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Text('$count', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ),
      ],
    );
  }

  Widget _buildExpiryCard(BuildContext context, dynamic item, bool isDark, {required bool isExpired}) {
    final map = item as Map<String, dynamic>;
    final tenantName = map['tenant_name'] ?? map['tenant']?['full_name'] ?? 'Unknown';
    final propertyName = map['property_name'] ?? map['property']?['name'] ?? '';
    final unitName = map['unit_name'] ?? map['unit']?['name'] ?? '';
    final endDate = map['end_date'] ?? map['lease_end'];
    final endDateStr = endDate != null
        ? DateFormat('dd MMM yyyy').format(DateTime.tryParse(endDate.toString()) ?? DateTime.now())
        : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isExpired ? AppColors.error : AppColors.warning).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isExpired ? Icons.error_outline : Icons.schedule,
              color: isExpired ? AppColors.error : AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tenantName, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                if (propertyName.isNotEmpty || unitName.isNotEmpty)
                  Text('$propertyName - $unitName', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textLight)),
                const SizedBox(height: 4),
                Text('${context.tr('lease_end')}: $endDateStr', style: GoogleFonts.nunito(fontSize: 11, color: isExpired ? AppColors.error : AppColors.warning, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtReportTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('total_debts'), style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w600)),
                        Text('TZS ${_formatAmount(totalDebts)}', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.error)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text('${debts.length} ${context.tr('tenants_in_debt')}', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.error)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...debts.map((item) => _buildDebtCard(item, isDark)),
          ],
        );
      },
    );
  }

  Widget _buildDebtCard(dynamic item, bool isDark) {
    final map = item as Map<String, dynamic>;
    final tenantName = map['tenant_name'] ?? map['tenant']?['full_name'] ?? 'Unknown';
    final propertyName = map['property_name'] ?? map['property']?['name'] ?? '';
    final unitName = map['unit_name'] ?? map['unit']?['name'] ?? '';
    final amount = _parseAmount(map['amount'] ?? map['outstanding']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.person_outline, color: AppColors.error, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tenantName, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                if (propertyName.isNotEmpty || unitName.isNotEmpty)
                  Text('$propertyName - $unitName', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          ),
          Text('TZS ${_formatAmount(amount)}', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.error)),
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

class _LeaseReportTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_LeaseReportTab> createState() => _LeaseReportTabState();
}

class _LeaseReportTabState extends ConsumerState<_LeaseReportTab> {
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reportAsync = ref.watch(leaseReportProvider(_selectedYear));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(context.tr('select_year'), style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textLight)),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButton<int>(
                    value: _selectedYear,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: List.generate(5, (i) => DateTime.now().year - 2 + i).map((y) {
                      return DropdownMenuItem(value: y, child: Text('$y', style: GoogleFonts.nunito(fontSize: 14)));
                    }).toList(),
                    onChanged: (v) { if (v != null) setState(() => _selectedYear = v); },
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
              onRetry: () => ref.invalidate(leaseReportProvider(_selectedYear)),
            ),
            data: (data) {
              final expected = _parseAmount(data['expected']);
              final collected = _parseAmount(data['collected']);
              final outstanding = _parseAmount(data['outstanding']);
              final leases = data['leases'] is List ? data['leases'] as List : [];

              if (expected == 0 && collected == 0 && outstanding == 0 && leases.isEmpty) {
                return EmptyState(message: context.tr('no_revenue_data'));
              }

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildLeaseSummary(context, expected, collected, outstanding, isDark),
                  const SizedBox(height: 20),
                  if (leases.isNotEmpty) ...[
                    Text(context.tr('lease_reports'), style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                    const SizedBox(height: 12),
                    ...leases.map((item) => _buildLeaseCard(item, isDark)),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeaseSummary(BuildContext context, double expected, double collected, double outstanding, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildLeaseRow(context.tr('lease_expected'), _formatAmount(expected), AppColors.info, Icons.account_balance_wallet_outlined),
          const Divider(height: 24),
          _buildLeaseRow(context.tr('lease_collected'), _formatAmount(collected), AppColors.success, Icons.check_circle_outline),
          const Divider(height: 24),
          _buildLeaseRow(context.tr('lease_outstanding'), _formatAmount(outstanding), AppColors.error, Icons.error_outline),
        ],
      ),
    );
  }

  Widget _buildLeaseRow(String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textLight))),
        Text('TZS $value', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }

  Widget _buildLeaseCard(dynamic item, bool isDark) {
    final map = item as Map<String, dynamic>;
    final tenantName = map['tenant_name'] ?? map['tenant']?['full_name'] ?? 'Unknown';
    final propertyName = map['property_name'] ?? map['property']?['name'] ?? '';
    final unitName = map['unit_name'] ?? map['unit']?['name'] ?? '';
    final expected = _parseAmount(map['expected']);
    final collected = _parseAmount(map['collected']);
    final outstanding = _parseAmount(map['outstanding']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tenantName, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
          if (propertyName.isNotEmpty || unitName.isNotEmpty)
            Text('$propertyName - $unitName', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textLight)),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildLeaseChip(context.tr('lease_expected'), _formatAmount(expected), AppColors.info),
              const SizedBox(width: 8),
              _buildLeaseChip(context.tr('lease_collected'), _formatAmount(collected), AppColors.success),
              const SizedBox(width: 8),
              _buildLeaseChip(context.tr('lease_outstanding'), _formatAmount(outstanding), AppColors.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaseChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Text(label, style: GoogleFonts.nunito(fontSize: 9, color: AppColors.textLight, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(value, style: GoogleFonts.nunito(fontSize: 12, color: color, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
          ],
        ),
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
