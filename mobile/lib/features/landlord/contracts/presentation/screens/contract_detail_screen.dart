import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/confirm_dialog.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/contracts_provider.dart';

import 'package:manna_apartment/core/utils/app_toast.dart';

class ContractDetailScreen extends ConsumerStatefulWidget {
  const ContractDetailScreen({super.key});

  @override
  ConsumerState<ContractDetailScreen> createState() =>
      _ContractDetailScreenState();
}

class _ContractDetailScreenState extends ConsumerState<ContractDetailScreen> {
  bool _isPdfLoading = false;

  @override
  Widget build(BuildContext context) {
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    final contractAsync = ref.watch(contractDetailProvider(id));
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('contract_details'),
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
            onPress: () => _confirmDelete(context, ref, id),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedDelete02,
              size: 18,
              color: colors.error,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: contractAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
            message: AppError.getMessage(e),
            onRetry: () => ref.invalidate(contractDetailProvider(id))),
        data: (contract) {
          final tenant = contract['tenant'];
          final unit = contract['unit'];
          final property = unit?['property'];
          final rent = _parseAmount(contract['rent_amount']);
          final deposit = _parseAmount(contract['deposit_amount']);
          final isManual = contract['contract_type'] == 'manual';
          final isSigned = contract['signed_at'] != null;
          final tenantSigned = contract['tenant_signed_at'] != null ||
              contract['signature_path'] != null;
          final status = (contract['status'] ?? 'active').toString();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              // Header — contract no + pills
              Text(
                contract['contract_number']?.toString() ??
                    context.tr('contract'),
                style:
                    typography.display.sm.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _pill(context, status, _statusColor(colors, status)),
                  const SizedBox(width: 8),
                  _pill(
                    context,
                    isManual
                        ? context.tr('manual')
                        : context.tr('digital'),
                    colors.mutedForeground,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: colors.border.withValues(alpha: 0.6)),
              const SizedBox(height: 4),

              // Info rows — flat
              _row(context, HugeIcons.strokeRoundedUser, context.tr('tenant'),
                  tenant?['full_name'] ??
                      tenant?['user']?['full_name'] ??
                      'N/A'),
              _row(context, HugeIcons.strokeRoundedBuilding03,
                  context.tr('property'), property?['name'] ?? 'N/A'),
              _row(context, HugeIcons.strokeRoundedDoor01, context.tr('unit'),
                  unit?['name'] ?? unit?['unit_number'] ?? 'N/A'),
              _row(context, HugeIcons.strokeRoundedCalendar01,
                  context.tr('start_date'), _formatDate(contract['start_date'])),
              _row(context, HugeIcons.strokeRoundedCalendarMinus01,
                  context.tr('end_date'), _formatDate(contract['end_date'])),
              _row(context, HugeIcons.strokeRoundedMoney01,
                  context.tr('monthly_rent_label'),
                  'TZS ${_formatNumber(rent)}'),
              _row(context, HugeIcons.strokeRoundedWallet01,
                  context.tr('deposit'), 'TZS ${_formatNumber(deposit)}'),
              const SizedBox(height: 20),

              // A4 document preview
              _buildA4Contract(context, contract),
              const SizedBox(height: 24),

              // Actions
              FButton(
                variant: .outline,
                prefix: _isPdfLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: FCircularProgress())
                    : const HugeIcon(
                        icon: HugeIcons.strokeRoundedPdf01, size: null),
                onPress: _isPdfLoading
                    ? null
                    : () => _downloadAndOpen(context, ref, id),
                child: Text(context.tr('view_pdf')),
              ),
              const SizedBox(height: 10),
              if (isSigned)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.08),
                    borderRadius: context.theme.style.borderRadius.md,
                    border: Border.all(
                        color: const Color(0xFF16A34A)
                            .withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedCheckmarkBadge02,
                        size: 16,
                        color: Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.tr('signed_on').replaceAll(
                              '{0}', _formatDate(contract['signed_at'])),
                          style: typography.body.xs2.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (tenantSigned)
                FButton(
                  variant: .secondary,
                  prefix: const HugeIcon(
                      icon: HugeIcons.strokeRoundedEdit02, size: null),
                  onPress: () => context.push('/landlord/contracts/$id/sign'),
                  child: Text(context.tr('sign_contract')),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withValues(alpha: 0.08),
                    borderRadius: context.theme.style.borderRadius.md,
                    border: Border.all(
                        color: const Color(0xFFD97706)
                            .withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedClock01,
                        size: 16,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Awaiting tenant signature',
                          style: typography.body.xs2.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              FButton(
                variant: .destructive,
                prefix: const HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01, size: null),
                onPress: () => _confirmTerminate(context, ref, id),
                child: Text(context.tr('terminate')),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _statusColor(FColors colors, String status) => switch (status) {
        'active' => const Color(0xFF16A34A),
        'terminated' || 'cancelled' => colors.error,
        'expired' => const Color(0xFFD97706),
        _ => colors.mutedForeground,
      };

  Widget _pill(BuildContext context, String label, Color color) {
    final typography = context.theme.typography;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: context.theme.style.borderRadius.pill,
      ),
      child: Text(
        label.toUpperCase(),
        style: typography.body.xs3.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: color,
        ),
      ),
    );
  }

  Widget _row(BuildContext context, List<List<dynamic>> icon, String label,
      String value) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          HugeIcon(icon: icon, size: 15, color: colors.mutedForeground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: typography.body.xs2
                  .copyWith(color: colors.mutedForeground),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  typography.body.xs2.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showConfirmDialog(
      context,
      title: context.tr('delete_contract'),
      message: context.tr('confirm_delete_contract'),
      confirmText: context.tr('delete'),
      cancelText: context.tr('cancel'),
      isDestructive: true,
    );
    if (confirmed != true) return;
    try {
      await ref.read(contractsRepositoryProvider).deleteContract(id);
      ref.invalidate(contractsListProvider);
      if (context.mounted) {
        AppToast.success(context, context.tr('contract_deleted'));
        if (context.canPop()) context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context,
            context.tr('failed_msg').replaceAll('{0}', AppError.getMessage(e)));
      }
    }
  }

  void _confirmTerminate(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showConfirmDialog(
      context,
      title: context.tr('terminate'),
      message: context.tr('confirm_delete_contract'),
      confirmText: context.tr('terminate'),
      cancelText: context.tr('cancel'),
      isDestructive: true,
    );
    if (confirmed != true) return;
    try {
      await ref.read(contractsRepositoryProvider).terminateContract(id);
      ref.invalidate(contractDetailProvider(id));
      ref.invalidate(contractsListProvider);
      if (context.mounted) {
        AppToast.warning(context, context.tr('contract_terminated'));
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context,
            context.tr('failed_msg').replaceAll('{0}', AppError.getMessage(e)));
      }
    }
  }

  double _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String _formatNumber(double amount) {
    return NumberFormat('#,###').format(amount);
  }

  Future<void> _downloadAndOpen(
      BuildContext context, WidgetRef ref, String id) async {
    setState(() => _isPdfLoading = true);
    try {
      final path =
          await ref.read(contractsRepositoryProvider).downloadPdf(id);
      await OpenFilex.open(path);
    } catch (e) {
      if (context.mounted) {
        AppToast.error(
            context,
            context
                .tr('could_not_open_pdf')
                .replaceAll('{0}', AppError.getMessage(e)));
      }
    } finally {
      if (mounted) setState(() => _isPdfLoading = false);
    }
  }

  Widget _buildA4Contract(BuildContext context, Map<String, dynamic> contract) {
    final tenant = contract['tenant'];
    final unit = contract['unit'];
    final property = unit?['property'];
    final rent = _parseAmount(contract['rent_amount']);
    final deposit = _parseAmount(contract['deposit_amount']);
    final start = _formatDate(contract['start_date']);
    final end = _formatDate(contract['end_date']);
    final tenantName =
        tenant?['full_name'] ?? tenant?['user']?['full_name'] ?? '________________';
    final tenantPhone =
        tenant?['phone'] ?? tenant?['user']?['phone'] ?? '________________';
    final propertyName = property?['name'] ?? '________________';
    final propertyAddress = property?['address'] ?? '________________';
    final unitName =
        unit?['name'] ?? unit?['unit_number'] ?? '________________';
    final contractNo = contract['contract_number'] ?? 'N/A';
    final isSigned = contract['signed_at'] != null;
    final isManual = contract['contract_type'] == 'manual';
    final customTerms = contract['template_content']?.toString() ?? '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 24, horizontal: 28),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8)),
            ),
            child: Column(
              children: [
                Text(context.tr('tenancy_agreement'),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                      context
                          .tr('contract_no_label')
                          .replaceAll('{0}', contractNo.toString()),
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                          letterSpacing: 0.5)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('tenancy_intro'),
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black54, height: 1.6)),
                const SizedBox(height: 24),
                _buildDocSection(context.tr('sec_parties'), [
                  _buildDocRow(context.tr('landlord_owner'), propertyName),
                  _buildDocRow(context.tr('tenant_name_label'), tenantName),
                  _buildDocRow(context.tr('tenant_phone_label'), tenantPhone),
                ]),
                const SizedBox(height: 20),
                _buildDocSection(context.tr('sec_property_details'), [
                  _buildDocRow(context.tr('property_name_label'), propertyName),
                  _buildDocRow(context.tr('address_label'), propertyAddress),
                  _buildDocRow(context.tr('unit_no_label'), unitName),
                ]),
                const SizedBox(height: 20),
                _buildDocSection(context.tr('sec_term_of_tenancy'), [
                  _buildDocRow(context.tr('start_date_label'), start),
                  _buildDocRow(context.tr('end_date_label'), end),
                  _buildDocRow(
                      context.tr('duration_label'),
                      _calcDuration(contract['start_date']?.toString(),
                          contract['end_date']?.toString())),
                ]),
                const SizedBox(height: 20),
                _buildDocSection(context.tr('sec_rent_deposit'), [
                  _buildDocRow(context.tr('monthly_rent_label'),
                      'TZS ${_formatNumber(rent)}'),
                  _buildDocRow(context.tr('security_deposit_label'),
                      'TZS ${_formatNumber(deposit)}'),
                  _buildDocRow(context.tr('payment_due_label'),
                      context.tr('payment_due_value')),
                ]),
                const SizedBox(height: 20),
                _buildDocSectionTitle(context.tr('sec_terms_conditions')),
                const SizedBox(height: 10),
                if (isManual && customTerms.isNotEmpty)
                  Text(customTerms,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black87,
                          height: 1.6))
                else ...[
                  _buildDocTerm('5.1', context.tr('term_5_1')),
                  _buildDocTerm('5.2', context.tr('term_5_2')),
                  _buildDocTerm('5.3', context.tr('term_5_3')),
                  _buildDocTerm('5.4', context.tr('term_5_4')),
                  _buildDocTerm('5.5', context.tr('term_5_5')),
                  _buildDocTerm('5.6', context.tr('term_5_6')),
                  _buildDocTerm('5.7', context.tr('term_5_7')),
                  _buildDocTerm('5.8', context.tr('term_5_8')),
                ],
                const SizedBox(height: 24),
                _buildDocSectionTitle(context.tr('sec_governing_law')),
                const SizedBox(height: 8),
                Text(context.tr('governing_law_text'),
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black87, height: 1.6)),
                const SizedBox(height: 32),
                _buildDocSectionTitle(context.tr('sec_signatures')),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.tr('landlord_label'),
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87)),
                          const SizedBox(height: 24),
                          Container(height: 1, color: Colors.black38),
                          const SizedBox(height: 4),
                          Text(context.tr('signature_date'),
                              style: const TextStyle(
                                  fontSize: 9, color: Colors.black54)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.tr('tenant_label'),
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87)),
                          const SizedBox(height: 24),
                          if (isSigned && contract['signature_path'] != null)
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.green.shade700,
                                        width: 1.5)),
                              ),
                              child: const Icon(Icons.draw,
                                  color: Colors.green, size: 28),
                            )
                          else
                            Container(height: 1, color: Colors.black38),
                          const SizedBox(height: 4),
                          Text(
                            isSigned
                                ? context.tr('signed_on_label').replaceAll(
                                    '{0}', _formatDate(contract['signed_at']))
                                : context.tr('signature_date'),
                            style: TextStyle(
                                fontSize: 9,
                                color: isSigned
                                    ? Colors.green.shade700
                                    : Colors.black54,
                                fontWeight: isSigned
                                    ? FontWeight.w700
                                    : FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(context.tr('legally_binding_notice'),
                      style: const TextStyle(
                          fontSize: 9,
                          color: Colors.black45,
                          fontStyle: FontStyle.italic)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDocSectionTitle(title),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }

  Widget _buildDocSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            letterSpacing: 0.3));
  }

  Widget _buildDocRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.black54)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildDocTerm(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Text(number,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87)),
          ),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 11, color: Colors.black87, height: 1.5)),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    final dt = DateTime.tryParse(date.toString());
    if (dt == null) return date.toString();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _calcDuration(String? start, String? end) {
    if (start == null || end == null) return context.tr('custom_duration');
    final startDate = DateTime.tryParse(start);
    final endDate = DateTime.tryParse(end);
    if (startDate == null || endDate == null) {
      return context.tr('custom_duration');
    }
    final months =
        (endDate.year - startDate.year) * 12 + (endDate.month - startDate.month);
    if (months <= 0) return context.tr('custom_duration');
    if (months % 12 == 0) {
      final years = months ~/ 12;
      return years > 1
          ? context.tr('year_plural').replaceAll('{0}', years.toString())
          : context.tr('year_singular').replaceAll('{0}', years.toString());
    }
    return months > 1
        ? context.tr('month_plural').replaceAll('{0}', months.toString())
        : context.tr('month_singular').replaceAll('{0}', months.toString());
  }
}
