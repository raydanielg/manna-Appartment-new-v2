import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/payments_provider.dart';
import '../../../contracts/providers/contracts_provider.dart';
import '../../../tenants/providers/tenants_provider.dart';

import 'package:manna_apartment/core/utils/app_toast.dart';

class RecordPaymentScreen extends ConsumerStatefulWidget {
  const RecordPaymentScreen({super.key});

  @override
  ConsumerState<RecordPaymentScreen> createState() =>
      _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends ConsumerState<RecordPaymentScreen> {
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _monthController = TextEditingController(
      text: DateFormat('MMMM yyyy').format(DateTime.now()));
  final _notesController = TextEditingController();
  String? _selectedTenantId;
  String? _selectedContractId;
  String _paymentType = 'rent';
  String _method = 'cash';
  DateTime _paymentDate = DateTime.now();
  bool _isLoading = false;

  Map<String, dynamic>? _overpaymentPreview;
  bool _isPreviewLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    _monthController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce =
        Timer(const Duration(milliseconds: 600), _fetchOverpaymentPreview);
  }

  Future<void> _fetchOverpaymentPreview() async {
    if (_selectedContractId == null) return;
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      setState(() => _overpaymentPreview = null);
      return;
    }
    setState(() => _isPreviewLoading = true);
    try {
      final repo = ref.read(paymentsRepositoryProvider);
      final result = await repo.previewOverpayment(
        contractId: _selectedContractId!,
        amount: amount,
        paymentDate: DateFormat('yyyy-MM-dd').format(_paymentDate),
        monthCovered: _monthController.text.trim().isNotEmpty
            ? _monthController.text.trim()
            : null,
      );
      if (mounted) setState(() => _overpaymentPreview = result);
    } catch (_) {
      if (mounted) setState(() => _overpaymentPreview = null);
    } finally {
      if (mounted) setState(() => _isPreviewLoading = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _amountController.dispose();
    _referenceController.dispose();
    _monthController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _paymentDate = picked);
      _onAmountChanged();
    }
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (_selectedTenantId == null || _selectedContractId == null || amount <= 0) {
      AppToast.error(context, context.tr('please_select_tenant_amount'));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(paymentsRepositoryProvider);
      final response = await repo.createPayment({
        'tenant_id': _selectedTenantId,
        'contract_id': _selectedContractId,
        'payment_type': _paymentType,
        'amount': amount,
        'method': _method,
        'reference_number': _referenceController.text.trim(),
        'payment_date': DateFormat('yyyy-MM-dd').format(_paymentDate),
        'month_covered': _monthController.text.trim(),
        'notes': _notesController.text.trim(),
      });
      ref.invalidate(landlordPaymentsProvider);
      if (mounted) {
        final overpayment = response['overpayment'] as Map<String, dynamic>?;
        final monthsCount = overpayment?['months_count'];
        final isOverpayment = overpayment?['is_overpayment'] == true;
        final msg = isOverpayment && monthsCount != null
            ? context
                .tr('payment_recorded_months')
                .replaceAll('{0}', monthsCount.toString())
            : context.tr('payment_recorded');
        AppToast.success(context, msg);
        if (context.canPop()) context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(
            context,
            context.tr('failed_msg').replaceAll('{0}', AppError.getMessage(e)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final tenantsAsync = ref.watch(tenantsListProvider(null));
    final contractsAsync = ref.watch(contractsListProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('record_payment'),
          style: typography.display.md.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: FButton.icon(
          variant: .ghost,
          size: .sm,
          onPress: () {
            if (context.canPop()) context.pop();
          },
          child: context.theme.icons.arrowLeft(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Tenant picker
          _sectionLabel(context, context.tr('tenant')),
          tenantsAsync.when(
            loading: () => const Center(child: FCircularProgress()),
            error: (_, _) => Text(
              context.tr('failed_load_tenants'),
              style: typography.body.xs2.copyWith(color: colors.error),
            ),
            data: (tenants) => _searchablePicker(
              context,
              title: context.tr('select_tenant'),
              label: _selectedTenantId == null
                  ? context.tr('select_tenant')
                  : _tenantName(tenants.firstWhere(
                      (t) => t['id'].toString() == _selectedTenantId,
                      orElse: () => <String, dynamic>{},
                    )),
              items: tenants.map((t) {
                final name = _tenantName(t);
                final phone = (t['user']?['phone'] ?? t['phone'] ?? '')
                    .toString();
                return MapEntry(
                    t['id'].toString(), MapEntry(name, phone));
              }).toList(),
              onSelected: (v) => setState(() {
                _selectedTenantId = v;
                _selectedContractId = null;
              }),
            ),
          ),
          const SizedBox(height: 14),

          // Contract picker
          _sectionLabel(context, context.tr('contract')),
          contractsAsync.when(
            loading: () => const Center(child: FCircularProgress()),
            error: (_, _) => Text(
              context.tr('failed_load_contracts'),
              style: typography.body.xs2.copyWith(color: colors.error),
            ),
            data: (contracts) {
              final tenantContracts = contracts
                  .where(
                      (c) => c['tenant_id'].toString() == _selectedTenantId)
                  .toList();
              final selectedLabel = _selectedContractId == null
                  ? context.tr('select_contract')
                  : (tenantContracts.firstWhere(
                            (c) =>
                                c['id'].toString() == _selectedContractId,
                            orElse: () => <String, dynamic>{},
                          )['contract_number'] ??
                      context.tr('contract'));
              return _picker(
                context,
                label: selectedLabel.toString(),
                enabled: _selectedTenantId != null,
                items: tenantContracts.map((c) {
                  final label =
                      c['contract_number'] ?? context.tr('contract');
                  return MapEntry(c['id'].toString(), label.toString());
                }).toList(),
                onSelected: (v) {
                  setState(() => _selectedContractId = v);
                  _onAmountChanged();
                },
              );
            },
          ),
          const SizedBox(height: 14),

          // Payment type chips
          _sectionLabel(context, context.tr('payment_type')),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final (label, v) in [
                (context.tr('rent'), 'rent'),
                (context.tr('water'), 'water'),
                (context.tr('electricity'), 'electricity'),
                (context.tr('other'), 'other'),
              ])
                FButton(
                  variant: _paymentType == v ? .primary : .outline,
                  size: .xs,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () => setState(() => _paymentType = v),
                  child: Text(label),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Amount
          FTextField(
            control: .managed(controller: _amountController),
            label: Text(context.tr('amount_tzs')),
            hint: '0',
            keyboardType: TextInputType.number,
            prefixBuilder: (context, style, variants) =>
                FTextField.prefixIconBuilder(
                  context,
                  style,
                  variants,
                  const HugeIcon(
                      icon: HugeIcons.strokeRoundedMoney01, size: null),
                ),
          ),
          const SizedBox(height: 8),
          _overpaymentCard(context),
          const SizedBox(height: 10),

          // Method picker
          _sectionLabel(context, context.tr('method')),
          _picker(
            context,
            label: switch (_method) {
              'bank_transfer' => context.tr('bank_transfer'),
              'mobile_money' => context.tr('mobile_money'),
              'card' => context.tr('card'),
              _ => context.tr('cash'),
            },
            items: [
              MapEntry('cash', context.tr('cash')),
              MapEntry('bank_transfer', context.tr('bank_transfer')),
              MapEntry('mobile_money', context.tr('mobile_money')),
              MapEntry('card', context.tr('card')),
            ],
            onSelected: (v) => setState(() => _method = v),
          ),
          const SizedBox(height: 14),

          // Reference
          FTextField(
            control: .managed(controller: _referenceController),
            label: Text(context.tr('reference_number')),
            hint: 'REF-001',
            prefixBuilder: (context, style, variants) =>
                FTextField.prefixIconBuilder(
                  context,
                  style,
                  variants,
                  const HugeIcon(
                      icon: HugeIcons.strokeRoundedFile01, size: null),
                ),
          ),
          const SizedBox(height: 14),

          // Payment date
          _sectionLabel(context, context.tr('payment_date')),
          FTappable(
            onPress: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: colors.border),
                borderRadius: context.theme.style.borderRadius.md,
              ),
              child: Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedCalendar01,
                    size: 16,
                    color: colors.mutedForeground,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    DateFormat('dd MMM yyyy').format(_paymentDate),
                    style: typography.body.xs2
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Month covered
          FTextField(
            control: .managed(controller: _monthController),
            label: Text(context.tr('month_covered_hint')),
            hint: 'January 2025',
            prefixBuilder: (context, style, variants) =>
                FTextField.prefixIconBuilder(
                  context,
                  style,
                  variants,
                  const HugeIcon(
                      icon: HugeIcons.strokeRoundedCalendar01, size: null),
                ),
          ),
          const SizedBox(height: 14),

          // Notes
          FTextField.multiline(
            control: .managed(controller: _notesController),
            label: Text(context.tr('notes')),
            hint: context.tr('notes'),
            minLines: 3,
          ),
          const SizedBox(height: 24),

          PrimaryButton(
            text: context.tr('save_payment'),
            isLoading: _isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: 10),
          FButton(
            variant: .ghost,
            onPress: () {
              if (context.canPop()) context.pop();
            },
            child: Text(context.tr('cancel')),
          ),
        ],
      ),
    );
  }

  String _tenantName(Map<String, dynamic> t) {
    return (t['user']?['full_name'] ?? t['full_name'] ?? context.tr('tenant'))
        .toString();
  }

  /// Tap opens a bottom sheet with a search field + list — good for long lists.
  Widget _searchablePicker(
    BuildContext context, {
    required String title,
    required String label,
    required List<MapEntry<String, MapEntry<String, String>>> items,
    required ValueChanged<String> onSelected,
  }) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final isPlaceholder = label == title;

    return FTappable(
      onPress: () => _openSearchSheet(context,
          title: title, items: items, onSelected: onSelected),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: colors.border),
          borderRadius: context.theme.style.borderRadius.md,
        ),
        child: Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedUser,
              size: 16,
              color: colors.mutedForeground,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.body.xs2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isPlaceholder
                      ? colors.mutedForeground
                      : colors.foreground,
                ),
              ),
            ),
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowDown01,
              size: 14,
              color: colors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSearchSheet(
    BuildContext context, {
    required String title,
    required List<MapEntry<String, MapEntry<String, String>>> items,
    required ValueChanged<String> onSelected,
  }) async {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    String query = '';

    await showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) {
          final filtered = items.where((e) {
            final q = query.toLowerCase();
            return e.value.key.toLowerCase().contains(q) ||
                e.value.value.toLowerCase().contains(q);
          }).toList();

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      children: [
                        Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title,
                            style: typography.body.md
                                .copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FTextField(
                          control: .managed(
                            onChange: (v) =>
                                setSheet(() => query = v.text),
                          ),
                          hint: context.tr('search'),
                          prefixBuilder: (context, style, variants) =>
                              FTextField.prefixIconBuilder(
                                context,
                                style,
                                variants,
                                const HugeIcon(
                                    icon: HugeIcons.strokeRoundedSearch01,
                                    size: null),
                              ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.45,
                    ),
                    child: filtered.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              context.tr('no_results'),
                              style: typography.body.xs2.copyWith(
                                  color: colors.mutedForeground),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final e = filtered[i];
                              return FTappable(
                                onPress: () {
                                  onSelected(e.key);
                                  Navigator.pop(context);
                                },
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: colors.border
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                e.value.key,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: typography.body.xs2
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w700),
                                              ),
                                              if (e.value.value.isNotEmpty)
                                                Text(
                                                  e.value.value,
                                                  maxLines: 1,
                                                  overflow: TextOverflow
                                                      .ellipsis,
                                                  style: typography.body.xs3
                                                      .copyWith(
                                                    color: colors
                                                        .mutedForeground,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        HugeIcon(
                                          icon: HugeIcons
                                              .strokeRoundedArrowRight01,
                                          size: 14,
                                          color: colors.mutedForeground
                                              .withValues(alpha: 0.6),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
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

  Widget _picker(
    BuildContext context, {
    required String label,
    required List<MapEntry<String, String>> items,
    required ValueChanged<String> onSelected,
    bool enabled = true,
  }) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return PopupMenuButton<String>(
      enabled: enabled,
      offset: const Offset(0, 44),
      color: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: context.theme.style.borderRadius.lg,
      ),
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final e in items)
          PopupMenuItem(
            value: e.key,
            child: Text(e.value, style: typography.body.xs2),
          ),
      ],
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: colors.border),
          borderRadius: context.theme.style.borderRadius.md,
          color: enabled ? null : colors.secondary.withValues(alpha: 0.4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.body.xs2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: label == context.tr('select_tenant') ||
                          label == context.tr('select_contract')
                      ? colors.mutedForeground
                      : colors.foreground,
                ),
              ),
            ),
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowDown01,
              size: 14,
              color: colors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  Widget _overpaymentCard(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    if (_isPreviewLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const SizedBox(
                width: 14, height: 14, child: FCircularProgress()),
            const SizedBox(width: 10),
            Text(
              context.tr('calculating_coverage'),
              style: typography.body.xs2
                  .copyWith(color: colors.mutedForeground),
            ),
          ],
        ),
      );
    }

    final preview = _overpaymentPreview;
    if (preview == null) return const SizedBox.shrink();

    final monthsCount = preview['months_count'] as int? ?? 0;
    final isOverpayment = preview['is_overpayment'] == true;
    final monthCovered = preview['month_covered'] as String? ?? '';
    final overdueDate = preview['overdue_date'] as String? ?? '';
    final remainder = _parseNum(preview['remainder']);
    final rentAmount = _parseNum(preview['rent_amount']);

    final color =
        monthsCount == 0 ? const Color(0xFFD97706) : const Color(0xFF16A34A);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: context.theme.style.borderRadius.md,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HugeIcon(
                icon: monthsCount == 0
                    ? HugeIcons.strokeRoundedAlert02
                    : HugeIcons.strokeRoundedCheckmarkCircle02,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  monthsCount == 0
                      ? 'Amount is less than one month rent (TZS ${rentAmount.toStringAsFixed(0)}).'
                      : isOverpayment
                          ? context
                              .tr('payment_covers_months')
                              .replaceAll('{0}', monthsCount.toString())
                          : context.tr('payment_covers_one_month'),
                  style: typography.body.xs2.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (monthsCount > 0) ...[
            const SizedBox(height: 8),
            _previewRow(context, context.tr('months_covered'),
                '$monthsCount month(s)'),
            _previewRow(context, context.tr('period'), monthCovered),
            if (overdueDate.isNotEmpty)
              _previewRow(
                  context, context.tr('next_due_date'), overdueDate),
            if (remainder > 0)
              _previewRow(context, context.tr('remainder'),
                  'TZS ${remainder.toStringAsFixed(0)}'),
          ],
        ],
      ),
    );
  }

  Widget _previewRow(BuildContext context, String label, String value) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                typography.body.xs3.copyWith(color: colors.mutedForeground),
          ),
          Text(
            value,
            style:
                typography.body.xs3.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  double _parseNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
