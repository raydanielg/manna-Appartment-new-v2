import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../providers/payments_provider.dart';

class PaymentDetailScreen extends ConsumerWidget {
  const PaymentDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    final paymentAsync = ref.watch(paymentDetailProvider(id));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(context.tr('payment_details'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _confirmDelete(context, ref, id),
          ),
        ],
      ),
      body: paymentAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(message: AppError.getMessage(e), onRetry: () => ref.invalidate(paymentDetailProvider(id))),
        data: (payment) {
          final rawAmount = payment['amount'];
          final amount = (rawAmount is num
              ? rawAmount.toDouble()
              : double.tryParse(rawAmount?.toString() ?? '0') ?? 0.0);
          final tenant = payment['tenant'];
          final contract = payment['contract'];
          final type = (payment['payment_type'] ?? 'rent').toString();
          final date = payment['payment_date'] != null ? DateFormat('dd MMM yyyy').format(DateTime.tryParse(payment['payment_date'].toString()) ?? DateTime.now()) : '-';
          final status = payment['status']?.toString() ?? 'confirmed';
          final paid = status == 'confirmed' || status == 'paid';
          final receiptNo = payment['reference_number']?.toString() ?? 'RCP-${date.replaceAll(RegExp(r'[^0-9]'), '')}';
          final method = (payment['method'] ?? 'snippe').toString();
          final monthCovered = payment['month_covered']?.toString() ?? '-';
          final notes = payment['notes']?.toString() ?? '-';
          final tenantName = tenant?['full_name'] ?? tenant?['user']?['full_name'] ?? 'N/A';
          final unitName = contract?['unit']?['name'] ?? contract?['unit']?['unit_number'] ?? 'N/A';
          final paymentId = payment['id']?.toString() ?? id;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.success, AppColors.primary]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('amount_label'), style: GoogleFonts.nunito(fontSize: 14, color: Colors.white70)),
                      Text('TZS ${amount.toStringAsFixed(0)}', style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          StatusBadge(status: status),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                            child: Text(type.toUpperCase(), style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildRow(context, Icons.person, context.tr('tenant'), tenantName),
                _buildRow(context, Icons.meeting_room, context.tr('unit'), unitName),
                _buildRow(context, Icons.calendar_today, context.tr('date'), date),
                _buildRow(context, Icons.payment, context.tr('method'), method),
                _buildRow(context, Icons.receipt, context.tr('reference'), payment['reference_number'] ?? 'N/A'),
                _buildRow(context, Icons.calendar_month, context.tr('month_covered'), monthCovered),
                _buildRow(context, Icons.note, context.tr('notes'), notes),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showReceipt(context, isDark, tenantName, unitName, amount, paid, date, method, receiptNo, monthCovered, notes, paymentId, type),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.info),
                        icon: const Icon(Icons.receipt_long),
                        label: Text(context.tr('view_receipt')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showEditDialog(context, ref, id, payment),
                        icon: const Icon(Icons.edit),
                        label: Text(context.tr('edit')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showReceipt(BuildContext context, bool isDark, String tenantName, String unitName, double amount, bool paid,
      String date, String method, String receiptNo, String monthCovered, String notes, String paymentId, String type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _PaymentReceiptScreen(
          isDark: isDark,
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

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('cancel_payment_record')),
        content: Text(context.tr('confirm_delete_payment')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('no'))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(paymentsRepositoryProvider).deletePayment(id);
                ref.invalidate(landlordPaymentsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.tr('payment_deleted')), backgroundColor: AppColors.success),
                  );
                  if (context.canPop()) context.pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.tr('failed_msg').replaceAll('{0}', AppError.getMessage(e))), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: Text(context.tr('delete'), style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, String id, Map<String, dynamic> payment) {
    final amountController = TextEditingController(text: (payment['amount'] ?? '').toString());
    final notesController = TextEditingController(text: (payment['notes'] ?? '').toString());
    final referenceController = TextEditingController(text: (payment['reference_number'] ?? '').toString());
    final monthController = TextEditingController(text: (payment['month_covered'] ?? '').toString());
    String paymentType = (payment['payment_type'] ?? 'rent').toString();
    String method = (payment['method'] ?? 'cash').toString();
    DateTime paymentDate = payment['payment_date'] != null
        ? (DateTime.tryParse(payment['payment_date'].toString()) ?? DateTime.now())
        : DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(context.tr('edit_payment')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: context.tr('edit_amount_tzs')),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: paymentType,
                      decoration: InputDecoration(labelText: context.tr('payment_type_label')),
                      items: [
                        DropdownMenuItem(value: 'rent', child: Text(context.tr('rent'))),
                        DropdownMenuItem(value: 'water', child: Text(context.tr('water'))),
                        DropdownMenuItem(value: 'electricity', child: Text(context.tr('electricity'))),
                        DropdownMenuItem(value: 'other', child: Text(context.tr('other'))),
                      ],
                      onChanged: (v) => setDialogState(() => paymentType = v ?? 'rent'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: method,
                      decoration: InputDecoration(labelText: context.tr('method')),
                      items: [
                        DropdownMenuItem(value: 'cash', child: Text(context.tr('cash'))),
                        DropdownMenuItem(value: 'mobile_money', child: Text(context.tr('mobile_money'))),
                        DropdownMenuItem(value: 'bank_transfer', child: Text(context.tr('bank_transfer'))),
                        DropdownMenuItem(value: 'cheque', child: Text(context.tr('cheque'))),
                      ],
                      onChanged: (v) => setDialogState(() => method = v ?? 'cash'),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: paymentDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setDialogState(() => paymentDate = picked);
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(labelText: context.tr('payment_date')),
                        child: Text(DateFormat('dd MMM yyyy').format(paymentDate)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: referenceController,
                      decoration: InputDecoration(labelText: context.tr('reference_number')),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(labelText: context.tr('notes')),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('cancel'))),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await ref.read(paymentsRepositoryProvider).updatePayment(id, {
                        'amount': double.tryParse(amountController.text) ?? payment['amount'],
                        'payment_type': paymentType,
                        'method': method,
                        'reference_number': referenceController.text.trim(),
                        'payment_date': DateFormat('yyyy-MM-dd').format(paymentDate),
                        'month_covered': monthController.text.trim(),
                        'notes': notesController.text.trim(),
                      });
                      ref.invalidate(paymentDetailProvider(id));
                      ref.invalidate(landlordPaymentsProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.tr('edit_payment_success')), backgroundColor: AppColors.success),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.tr('failed_msg').replaceAll('{0}', AppError.getMessage(e))), backgroundColor: AppColors.error),
                        );
                      }
                    }
                  },
                  child: Text(context.tr('save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRow(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label, style: GoogleFonts.nunito(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
        trailing: Text(value, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
      ),
    );
  }
}

class _PaymentReceiptScreen extends StatelessWidget {
  final bool isDark;
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
    required this.isDark,
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
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(context.tr('efd_receipt'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadPdf(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePdf(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildReceiptCard(context),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadPdf(context),
                    icon: const Icon(Icons.download, size: 18),
                    label: Text(context.tr('download_pdf'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sharePdf(context),
                    icon: const Icon(Icons.share, size: 18),
                    label: Text(context.tr('share'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Column(
              children: [
                Text(context.tr('manna_apartment'), style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(context.tr('efd_receipt'), style: GoogleFonts.nunito(fontSize: 11, color: Colors.white70, letterSpacing: 0.5)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: paid ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    paid ? 'PAID' : 'PENDING',
                    style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: paid ? Colors.green : Colors.orange),
                  ),
                ),
              ],
            ),
          ),
          // Receipt body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildReceiptRow(context.tr('receipt_no'), receiptNo),
                _buildReceiptRow(context.tr('payment_id'), paymentId),
                _buildDivider(),
                _buildReceiptRow(context.tr('tenant'), tenantName),
                _buildReceiptRow(context.tr('unit'), unitName),
                _buildReceiptRow(context.tr('payment_type_label'), type.toUpperCase()),
                _buildDivider(),
                _buildReceiptRow(context.tr('amount_label'), 'TZS ${amount.toStringAsFixed(0)}'),
                _buildReceiptRow(context.tr('method'), method.toUpperCase()),
                _buildReceiptRow(context.tr('month_covered'), monthCovered),
                _buildReceiptRow(context.tr('date'), date),
                _buildDivider(),
                _buildReceiptRow(context.tr('notes'), notes),
                _buildDivider(),
                // Total
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.tr('total_amount'), style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark)),
                      Text(
                        'TZS ${amount.toStringAsFixed(0)}',
                        style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                _buildDivider(),
                const SizedBox(height: 12),
                // Footer
                Text(context.tr('computer_generated_receipt'), style: GoogleFonts.nunito(fontSize: 10, color: isDark ? Colors.white38 : Colors.grey.shade500, fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                Text(context.tr('thank_you_payment'), style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.white60 : AppColors.textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.nunito(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
          const SizedBox(width: 16),
          Expanded(
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

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
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
                    pw.Text('MANNA APARTMENT', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                    pw.SizedBox(height: 4),
                    pw.Text('Electronic Fiscal Device Receipt', style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: paid ? PdfColors.green100 : PdfColors.orange100,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        paid ? 'PAID' : 'PENDING',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: paid ? PdfColors.green800 : PdfColors.orange800),
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
                  pw.Text('TOTAL AMOUNT', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    'TZS ${amount.toStringAsFixed(0)}',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
                  ),
                ],
              ),
              pw.SizedBox(height: 32),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('This is a computer generated receipt.', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500, fontStyle: pw.FontStyle.italic)),
                    pw.SizedBox(height: 4),
                    pw.Text('Thank you for your payment!', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
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
          pw.Text(label, style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('failed_generate_pdf').replaceAll('{0}', AppError.getMessage(e))), backgroundColor: AppColors.error),
        );
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
      await Share.shareXFiles([XFile(file.path)], text: 'EFD Receipt - $tenantName');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('failed_share_pdf').replaceAll('{0}', AppError.getMessage(e))), backgroundColor: AppColors.error),
        );
      }
    }
  }
}
