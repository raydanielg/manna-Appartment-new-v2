import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/confirm_dialog.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/payments_provider.dart';

import 'package:manna_apartment/core/utils/app_toast.dart';

class PaymentDetailScreen extends ConsumerWidget {
  const PaymentDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    final paymentAsync = ref.watch(paymentDetailProvider(id));
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('payment_details'),
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
        actions: [
          FButton.icon(
            variant: .ghost,
            size: .sm,
            onPress: () => _confirmDelete(context, ref, id),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedDelete02,
              size: 20,
              color: colors.error,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: paymentAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          message: AppError.getMessage(e),
          onRetry: () => ref.invalidate(paymentDetailProvider(id)),
        ),
        data: (payment) {
          final amount = _parseAmount(payment['amount']);
          final tenant = payment['tenant'];
          final contract = payment['contract'];
          final type = (payment['payment_type'] ?? 'rent').toString();
          final date = payment['payment_date'] != null
              ? DateFormat('dd MMM yyyy').format(
                  DateTime.tryParse(payment['payment_date'].toString()) ??
                      DateTime.now())
              : '-';
          final status = payment['status']?.toString() ?? 'confirmed';
          final paid = status == 'confirmed' || status == 'paid';
          final receiptNo = payment['reference_number']?.toString() ??
              'RCP-${date.replaceAll(RegExp(r'[^0-9]'), '')}';
          final method = (payment['method'] ?? 'snippe').toString();
          final monthCovered = payment['month_covered']?.toString() ?? '-';
          final notes = payment['notes']?.toString() ?? '-';
          final tenantName = tenant?['full_name'] ??
              tenant?['user']?['full_name'] ??
              'N/A';
          final unitName = contract?['unit']?['name'] ??
              contract?['unit']?['unit_number'] ??
              'N/A';
          final paymentId = payment['id']?.toString() ?? id;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount card
                FCard(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.tr('amount_label').toUpperCase(),
                              style: typography.body.xs3.copyWith(
                                color: colors.mutedForeground,
                                letterSpacing: 0.6,
                              ),
                            ),
                            _pill(
                              context,
                              paid ? 'PAID' : 'PENDING',
                              paid
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFD97706),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'TZS ${NumberFormat('#,###').format(amount)}',
                          style: typography.display.xl
                              .copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        _pill(context, type.toUpperCase(), colors.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Info card
                FCard(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      children: [
                        _row(colors, typography, HugeIcons.strokeRoundedUser,
                            context.tr('tenant'), tenantName),
                        _divider(colors),
                        _row(colors, typography, HugeIcons.strokeRoundedDoor01,
                            context.tr('unit'), unitName),
                        _divider(colors),
                        _row(colors, typography, HugeIcons.strokeRoundedCalendar01,
                            context.tr('date'), date),
                        _divider(colors),
                        _row(colors, typography, HugeIcons.strokeRoundedCreditCard,
                            context.tr('method'), method.toUpperCase()),
                        _divider(colors),
                        _row(colors, typography, HugeIcons.strokeRoundedTag01,
                            context.tr('reference'),
                            payment['reference_number']?.toString() ?? 'N/A'),
                        _divider(colors),
                        _row(colors, typography, HugeIcons.strokeRoundedCalendarMinus01,
                            context.tr('month_covered'), monthCovered),
                        _divider(colors),
                        _row(colors, typography, HugeIcons.strokeRoundedNote01,
                            context.tr('notes'), notes),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                FButton(
                  variant: .secondary,
                  size: .sm,
                  prefix: const HugeIcon(
                      icon: HugeIcons.strokeRoundedReceipt, size: null),
                  onPress: () => _showReceipt(context, tenantName, unitName,
                      amount, paid, date, method, receiptNo, monthCovered, notes, paymentId, type),
                  child: Text(context.tr('view_receipt')),
                ),
                const SizedBox(height: 10),
                FButton(
                  variant: .outline,
                  size: .sm,
                  prefix: const HugeIcon(
                      icon: HugeIcons.strokeRoundedEdit02, size: null),
                  onPress: () => _showEditDialog(context, ref, id, payment),
                  child: Text(context.tr('edit')),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  Widget _pill(BuildContext context, String label, Color color) {
    final typography = context.theme.typography;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: context.theme.style.borderRadius.pill,
      ),
      child: Text(
        label,
        style: typography.body.xs3.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: color,
        ),
      ),
    );
  }

  Widget _divider(FColors colors) =>
      Divider(height: 1, indent: 14, color: colors.border.withValues(alpha: 0.6));

  Widget _row(FColors colors, FTypography typography, List<List<dynamic>> icon,
      String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          HugeIcon(icon: icon, size: 16, color: colors.mutedForeground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: typography.body.xs2.copyWith(color: colors.mutedForeground),
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.body.xs2
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showReceipt(
      BuildContext context,
      String tenantName,
      String unitName,
      double amount,
      bool paid,
      String date,
      String method,
      String receiptNo,
      String monthCovered,
      String notes,
      String paymentId,
      String type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _PaymentReceiptScreen(
          tenantName: tenantName,
          unitName: unitName,
          amount: amount,
          paid: paid,
          date: date,
          method: method,
          receiptNo: receiptNo,
          monthCovered: monthCovered,
          notes: notes,
          paymentId: paymentId,
          type: type,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showConfirmDialog(
      context,
      title: context.tr('cancel_payment_record'),
      message: context.tr('confirm_delete_payment'),
      confirmText: context.tr('delete'),
      cancelText: context.tr('no'),
      isDestructive: true,
    );
    if (!confirmed) return;
    try {
      await ref.read(paymentsRepositoryProvider).deletePayment(id);
      ref.invalidate(landlordPaymentsProvider);
      if (context.mounted) {
        AppToast.success(context, context.tr('payment_deleted'));
        if (context.canPop()) context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context,
            context.tr('failed_msg').replaceAll('{0}', AppError.getMessage(e)));
      }
    }
  }

  void _showEditDialog(
      BuildContext context, WidgetRef ref, String id, Map<String, dynamic> payment) {
    final amountController =
        TextEditingController(text: (payment['amount'] ?? '').toString());
    final notesController =
        TextEditingController(text: (payment['notes'] ?? '').toString());
    final referenceController = TextEditingController(
        text: (payment['reference_number'] ?? '').toString());
    final monthController = TextEditingController(
        text: (payment['month_covered'] ?? '').toString());
    String paymentType = (payment['payment_type'] ?? 'rent').toString();
    String method = (payment['method'] ?? 'cash').toString();
    DateTime paymentDate = payment['payment_date'] != null
        ? (DateTime.tryParse(payment['payment_date'].toString()) ??
            DateTime.now())
        : DateTime.now();

    showFDialog<void>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        builder: (dialogContext, style) => StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final typography = context.theme.typography;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('edit_payment'), style: style.titleTextStyle),
                  const SizedBox(height: 16),
                  FTextField(
                    control: .managed(controller: amountController),
                    label: Text(context.tr('edit_amount_tzs')),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  Text(context.tr('payment_type_label'),
                      style: typography.body.xs2.copyWith(
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final t in ['rent', 'water', 'electricity', 'other'])
                        FButton(
                          variant: paymentType == t ? .primary : .outline,
                          size: .sm,
                          mainAxisSize: MainAxisSize.min,
                          onPress: () =>
                              setDialogState(() => paymentType = t),
                          child: Text(context.tr(t)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(context.tr('method'),
                      style: typography.body.xs2.copyWith(
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final m in [
                        'cash',
                        'mobile_money',
                        'bank_transfer',
                        'cheque'
                      ])
                        FButton(
                          variant: method == m ? .primary : .outline,
                          size: .sm,
                          mainAxisSize: MainAxisSize.min,
                          onPress: () => setDialogState(() => method = m),
                          child: Text(context.tr(m)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FTextField(
                    control: .managed(
                      controller: TextEditingController(
                          text: DateFormat('dd MMM yyyy').format(paymentDate)),
                    ),
                    label: Text(context.tr('payment_date')),
                    readOnly: true,
                    suffixBuilder: (context, style, variants) => Padding(
                      padding: const EdgeInsetsDirectional.only(end: 12, start: 4),
                      child: const HugeIcon(
                          icon: HugeIcons.strokeRoundedCalendar01, size: null),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: paymentDate,
                        firstDate: DateTime(2020),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() => paymentDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  FTextField(
                    control: .managed(controller: referenceController),
                    label: Text(context.tr('reference_number')),
                  ),
                  const SizedBox(height: 12),
                  FTextField(
                    control: .managed(controller: monthController),
                    label: Text(context.tr('month_covered')),
                  ),
                  const SizedBox(height: 12),
                  FTextField(
                    control: .managed(controller: notesController),
                    label: Text(context.tr('notes')),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FButton(
                        variant: .outline,
                        size: .sm,
                        mainAxisSize: MainAxisSize.min,
                        onPress: () => Navigator.pop(dialogContext),
                        child: Text(context.tr('cancel')),
                      ),
                      const SizedBox(width: 8),
                      FButton(
                        variant: .primary,
                        size: .sm,
                        mainAxisSize: MainAxisSize.min,
                        onPress: () async {
                          Navigator.pop(dialogContext);
                          try {
                            await ref
                                .read(paymentsRepositoryProvider)
                                .updatePayment(id, {
                              'amount': double.tryParse(amountController.text) ??
                                  payment['amount'],
                              'payment_type': paymentType,
                              'method': method,
                              'reference_number':
                                  referenceController.text.trim(),
                              'payment_date':
                                  DateFormat('yyyy-MM-dd').format(paymentDate),
                              'month_covered': monthController.text.trim(),
                              'notes': notesController.text.trim(),
                            });
                            ref.invalidate(paymentDetailProvider(id));
                            ref.invalidate(landlordPaymentsProvider);
                            if (context.mounted) {
                              AppToast.success(
                                  context, context.tr('edit_payment_success'));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              AppToast.error(
                                context,
                                context.tr('failed_msg').replaceAll(
                                    '{0}', AppError.getMessage(e)),
                              );
                            }
                          }
                        },
                        child: Text(context.tr('save')),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PaymentReceiptScreen extends StatelessWidget {
  final String tenantName;
  final String unitName;
  final double amount;
  final bool paid;
  final String date;
  final String method;
  final String receiptNo;
  final String monthCovered;
  final String notes;
  final String paymentId;
  final String type;

  const _PaymentReceiptScreen({
    required this.tenantName,
    required this.unitName,
    required this.amount,
    required this.paid,
    required this.date,
    required this.method,
    required this.receiptNo,
    required this.monthCovered,
    required this.notes,
    required this.paymentId,
    required this.type,
  });

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
          context.tr('efd_receipt'),
          style: typography.display.md.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: FButton.icon(
          variant: .ghost,
          size: .sm,
          onPress: () => Navigator.pop(context),
          child: context.theme.icons.arrowLeft(context),
        ),
        actions: [
          FButton.icon(
            variant: .ghost,
            size: .sm,
            onPress: () => _downloadPdf(context),
            child: const HugeIcon(
                icon: HugeIcons.strokeRoundedDownload01, size: 20),
          ),
          FButton.icon(
            variant: .ghost,
            size: .sm,
            onPress: () => _sharePdf(context),
            child:
                const HugeIcon(icon: HugeIcons.strokeRoundedShare01, size: 20),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildReceiptCard(context, colors, typography),
            const SizedBox(height: 16),
            FButton(
              variant: .primary,
              prefix:
                  const HugeIcon(icon: HugeIcons.strokeRoundedShare01, size: null),
              onPress: () => _sharePdf(context),
              child: Text(context.tr('share')),
            ),
            const SizedBox(height: 10),
            FButton(
              variant: .outline,
              prefix: const HugeIcon(
                  icon: HugeIcons.strokeRoundedDownload01, size: null),
              onPress: () => _downloadPdf(context),
              child: Text(context.tr('download_pdf')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard(
      BuildContext context, FColors colors, FTypography typography) {
    final radii = context.theme.style.borderRadius;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: radii.lg,
        border: Border.all(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header — bleeds to card edges
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
            color: colors.primary,
            child: Column(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedReceipt,
                  size: 26,
                  color: colors.primaryForeground,
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('manna_apartment'),
                  style: typography.display.sm.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.primaryForeground,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('efd_receipt'),
                  style: typography.body.xs3.copyWith(
                    color: colors.primaryForeground.withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primaryForeground.withValues(alpha: 0.15),
                    borderRadius: radii.pill,
                  ),
                  child: Text(
                    paid ? 'PAID' : 'PENDING',
                    style: typography.body.xs3.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.primaryForeground,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _receiptRow(typography, colors, context.tr('receipt_no'), receiptNo),
                _receiptRow(typography, colors, context.tr('payment_id'), paymentId),
                _dashedDivider(colors),
                _receiptRow(typography, colors, context.tr('tenant'), tenantName),
                _receiptRow(typography, colors, context.tr('unit'), unitName),
                _receiptRow(typography, colors, context.tr('payment_type_label'),
                    type.toUpperCase()),
                _dashedDivider(colors),
                _receiptRow(typography, colors, context.tr('amount_label'),
                    'TZS ${amount.toStringAsFixed(0)}'),
                _receiptRow(typography, colors, context.tr('method'),
                    method.toUpperCase()),
                _receiptRow(typography, colors, context.tr('month_covered'),
                    monthCovered),
                _receiptRow(typography, colors, context.tr('date'), date),
                _dashedDivider(colors),
                _receiptRow(typography, colors, context.tr('notes'), notes),
                _dashedDivider(colors),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('total_amount').toUpperCase(),
                        style: typography.body.xs2.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: colors.mutedForeground,
                        ),
                      ),
                      Text(
                        'TZS ${NumberFormat('#,###').format(amount)}',
                        style: typography.display.sm.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                _dashedDivider(colors),
                const SizedBox(height: 12),
                Text(
                  context.tr('computer_generated_receipt'),
                  style: typography.body.xs3.copyWith(
                    color: colors.mutedForeground,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('thank_you_payment'),
                  style: typography.body.xs2.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashedDivider(FColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dashCount = (constraints.maxWidth / 10).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              dashCount,
              (_) => Container(
                width: 5,
                height: 1,
                color: colors.border,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _receiptRow(
      FTypography typography, FColors colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  typography.body.xs2.copyWith(color: colors.mutedForeground)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style:
                  typography.body.xs2.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<pw.Document> _generatePdf() {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('MANNA APARTMENT',
                        style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800)),
                    pw.SizedBox(height: 4),
                    pw.Text('Electronic Fiscal Device Receipt',
                        style: pw.TextStyle(
                            fontSize: 11, color: PdfColors.grey600)),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: paid
                            ? PdfColors.green100
                            : PdfColors.orange100,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        paid ? 'PAID' : 'PENDING',
                        style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: paid
                                ? PdfColors.green800
                                : PdfColors.orange800),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 16),
              _pdfRow('Receipt No.', receiptNo),
              _pdfRow('Payment ID', paymentId),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.grey200),
              pw.SizedBox(height: 8),
              _pdfRow('Tenant', tenantName),
              _pdfRow('Unit', unitName),
              _pdfRow('Payment Type', type.toUpperCase()),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.grey200),
              pw.SizedBox(height: 8),
              _pdfRow('Amount', 'TZS ${amount.toStringAsFixed(0)}'),
              _pdfRow('Method', method.toUpperCase()),
              _pdfRow('Month Covered', monthCovered),
              _pdfRow('Date', date),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.grey200),
              pw.SizedBox(height: 8),
              _pdfRow('Notes', notes),
              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL AMOUNT',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    'TZS ${amount.toStringAsFixed(0)}',
                    style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800),
                  ),
                ],
              ),
              pw.SizedBox(height: 32),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('This is a computer generated receipt.',
                        style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey500,
                            fontStyle: pw.FontStyle.italic)),
                    pw.SizedBox(height: 4),
                    pw.Text('Thank you for your payment!',
                        style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey600)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return Future.value(doc);
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style:
                  pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      final doc = await _generatePdf();
      await Printing.layoutPdf(onLayout: (format) async => doc.save());
    } catch (e) {
      if (context.mounted) {
        AppToast.error(
            context,
            context
                .tr('failed_generate_pdf')
                .replaceAll('{0}', AppError.getMessage(e)));
      }
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      final doc = await _generatePdf();
      final output = await doc.save();
      final bytes = Uint8List.fromList(output);
      final dir = await Directory.systemTemp.createTemp();
      final file = File('${dir.path}/EFD_Receipt_$receiptNo.pdf');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)],
          text: 'EFD Receipt - $tenantName');
    } catch (e) {
      if (context.mounted) {
        AppToast.error(
            context,
            context
                .tr('failed_share_pdf')
                .replaceAll('{0}', AppError.getMessage(e)));
      }
    }
  }
}
