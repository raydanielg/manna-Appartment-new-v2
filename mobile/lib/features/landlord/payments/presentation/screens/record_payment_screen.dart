import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/payments_provider.dart';
import '../../../contracts/providers/contracts_provider.dart';
import '../../../tenants/providers/tenants_provider.dart';

class RecordPaymentScreen extends ConsumerStatefulWidget {
  const RecordPaymentScreen({super.key});

  @override
  ConsumerState<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends ConsumerState<RecordPaymentScreen> {
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _monthController = TextEditingController(text: DateFormat('MMMM yyyy').format(DateTime.now()));
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
    _debounce = Timer(const Duration(milliseconds: 600), _fetchOverpaymentPreview);
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
        monthCovered: _monthController.text.trim().isNotEmpty ? _monthController.text.trim() : null,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select tenant and enter amount'), backgroundColor: AppColors.error),
      );
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
            ? 'Payment recorded! Covered $monthsCount month(s).'
            : 'Payment recorded.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.success),
        );
        if (context.canPop()) context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tenantsAsync = ref.watch(tenantsListProvider);
    final contractsAsync = ref.watch(contractsListProvider);
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Record Payment', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tenant', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 8),
            tenantsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => Text('Failed to load tenants', style: GoogleFonts.nunito(color: Colors.red)),
              data: (tenants) => DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                hint: Text('Select tenant', style: GoogleFonts.nunito(fontSize: 14)),
                items: tenants.map<DropdownMenuItem<String>>((t) {
                  final name = t['user']?['full_name'] ?? t['full_name'] ?? 'Tenant';
                  return DropdownMenuItem(value: t['id'].toString(), child: Text(name, style: GoogleFonts.nunito(fontSize: 14)));
                }).toList(),
                onChanged: (v) => setState(() {
                  _selectedTenantId = v;
                  _selectedContractId = null;
                }),
              ),
            ),
            const SizedBox(height: 16),
            Text('Contract', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 8),
            contractsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => Text('Failed to load contracts', style: GoogleFonts.nunito(color: Colors.red)),
              data: (contracts) {
                final tenantContracts = contracts.where((c) => c['tenant_id'].toString() == _selectedTenantId).toList();
                return DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  hint: Text('Select contract', style: GoogleFonts.nunito(fontSize: 14)),
                  value: _selectedContractId,
                  items: tenantContracts.map<DropdownMenuItem<String>>((c) {
                    final label = c['contract_number'] ?? 'Contract';
                    return DropdownMenuItem(value: c['id'].toString(), child: Text(label, style: GoogleFonts.nunito(fontSize: 14)));
                  }).toList(),
                  onChanged: (v) {
                    setState(() => _selectedContractId = v);
                    _onAmountChanged();
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Text('Payment Type', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildTypeChip('Rent', 'rent', AppColors.primary),
                _buildTypeChip('Water', 'water', Colors.blue),
                _buildTypeChip('Electricity', 'electricity', Colors.amber),
                _buildTypeChip('Other', 'other', Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Amount (TZS)',
              controller: _amountController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _buildOverpaymentCard(isDark),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Method',
              controller: TextEditingController(text: _method),
              readOnly: true,
              onTap: () => _showMethodPicker(context),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Reference Number',
              controller: _referenceController,
            ),
            const SizedBox(height: 16),
            Text('Payment Date', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: isDark ? Colors.white60 : AppColors.textLight),
                    const SizedBox(width: 12),
                    Text(DateFormat('dd MMM yyyy').format(_paymentDate), style: GoogleFonts.nunito(fontSize: 14)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Month Covered (e.g. July 2026)',
              controller: _monthController,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Notes',
              controller: _notesController,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            PrimaryButton(text: 'Save Payment', isLoading: _isLoading, onPressed: _submit),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  if (context.canPop()) context.pop();
                },
                child: Text('Cancel', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverpaymentCard(bool isDark) {
    if (_isPreviewLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 12),
            Text('Calculating coverage...', style: GoogleFonts.nunito(fontSize: 13, color: isDark ? Colors.white60 : AppColors.textLight)),
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
    final remainder = (preview['remainder'] is num)
        ? (preview['remainder'] as num).toDouble()
        : double.tryParse(preview['remainder']?.toString() ?? '0') ?? 0;
    final rentAmount = (preview['rent_amount'] is num)
        ? (preview['rent_amount'] as num).toDouble()
        : double.tryParse(preview['rent_amount']?.toString() ?? '0') ?? 0;

    if (monthsCount == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.orange, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Amount is less than one month rent (TZS ${rentAmount.toStringAsFixed(0)}).',
                style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange.shade800),
              ),
            ),
          ],
        ),
      );
    }

    final cardColor = isOverpayment ? Colors.green : AppColors.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isOverpayment ? Icons.check_circle : Icons.info, color: cardColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isOverpayment
                      ? 'This payment covers $monthsCount months!'
                      : 'This payment covers 1 month.',
                  style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: cardColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _previewRow('Months Covered', '$monthsCount month(s)', isDark),
          _previewRow('Period', monthCovered, isDark),
          if (overdueDate.isNotEmpty)
            _previewRow('Next Due Date', overdueDate, isDark),
          if (remainder > 0)
            _previewRow('Remainder', 'TZS ${remainder.toStringAsFixed(0)}', isDark),
        ],
      ),
    );
  }

  Widget _previewRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.nunito(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, String value, Color color) {
    final isSelected = _paymentType == value;
    return ChoiceChip(
      label: Text(label, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : Colors.black87)),
      selected: isSelected,
      selectedColor: color,
      backgroundColor: Colors.grey.shade200,
      onSelected: (_) => setState(() => _paymentType = value),
    );
  }

  void _showMethodPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text('Cash', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)), onTap: () { setState(() => _method = 'cash'); Navigator.pop(context); }),
            ListTile(title: Text('Bank Transfer', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)), onTap: () { setState(() => _method = 'bank_transfer'); Navigator.pop(context); }),
            ListTile(title: Text('Mobile Money', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)), onTap: () { setState(() => _method = 'mobile_money'); Navigator.pop(context); }),
            ListTile(title: Text('Card', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)), onTap: () { setState(() => _method = 'card'); Navigator.pop(context); }),
          ],
        ),
      ),
    );
  }
}
