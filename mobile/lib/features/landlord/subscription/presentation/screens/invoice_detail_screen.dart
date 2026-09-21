import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';

import 'package:manna_apartment/core/utils/app_toast.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> invoice;
  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    final plan = invoice['plan'] ?? {};
    final planName = plan['name']?.toString() ?? 'Subscription';
    final amount = invoice['amount'] ?? 0;
    final amountDouble = (amount is num
        ? amount.toDouble()
        : double.tryParse(amount.toString()) ?? 0.0);
    final amountFormatted = amountDouble.toStringAsFixed(0);
    final status = invoice['status']?.toString() ?? 'unknown';
    final paid = status == 'active' || status == 'paid';
    final startDate = invoice['start_date']?.toString() ?? '-';
    final endDate = invoice['end_date']?.toString() ?? '-';
    final reference = invoice['payment_reference']?.toString() ?? '-';
    final createdAt = invoice['created_at']?.toString() ?? '-';
    final invoiceId =
        invoice['id']?.toString() ?? invoice['uuid']?.toString() ?? '-';
    final receiptNo = reference != '-'
        ? reference
        : 'RCP-${createdAt.replaceAll(RegExp(r'[^0-9]'), '').substring(0, 12)}';

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
          onPress: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/landlord/subscription');
            }
          },
          child: context.theme.icons.arrowLeft(context),
        ),
        actions: [
          FButton.icon(
            variant: .ghost,
            size: .sm,
            onPress: () => _downloadPdf(context, invoice, planName,
                amountDouble, paid, startDate, endDate, receiptNo, createdAt, invoiceId),
            child: const HugeIcon(
                icon: HugeIcons.strokeRoundedDownload01, size: 20),
          ),
          FButton.icon(
            variant: .ghost,
            size: .sm,
            onPress: () => _sharePdf(context, invoice, planName, amountDouble,
                paid, startDate, endDate, receiptNo, createdAt, invoiceId),
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
            _buildReceiptCard(context, colors, typography, planName,
                amountFormatted, paid, startDate, endDate, receiptNo, createdAt, invoiceId),
            const SizedBox(height: 16),
            FButton(
              variant: .primary,
              prefix:
                  const HugeIcon(icon: HugeIcons.strokeRoundedShare01, size: null),
              onPress: () => _sharePdf(context, invoice, planName, amountDouble,
                  paid, startDate, endDate, receiptNo, createdAt, invoiceId),
              child: Text(context.tr('share')),
            ),
            const SizedBox(height: 10),
            FButton(
              variant: .outline,
              prefix: const HugeIcon(
                  icon: HugeIcons.strokeRoundedDownload01, size: null),
              onPress: () => _downloadPdf(context, invoice, planName,
                  amountDouble, paid, startDate, endDate, receiptNo, createdAt, invoiceId),
              child: Text(context.tr('download_pdf')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard(
    BuildContext context,
    FColors colors,
    FTypography typography,
    String planName,
    String amountFormatted,
    bool paid,
    String startDate,
    String endDate,
    String receiptNo,
    String createdAt,
    String invoiceId,
  ) {
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
                  icon: HugeIcons.strokeRoundedInvoice01,
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
                _receiptRow(typography, colors, 'Receipt No.', receiptNo),
                _receiptRow(typography, colors, 'Invoice ID', invoiceId),
                _dashedDivider(colors),
                _receiptRow(typography, colors, 'Plan', planName),
                _receiptRow(typography, colors, 'Amount',
                    amountFormatted == '0' ? 'FREE' : 'TZS $amountFormatted'),
                _receiptRow(typography, colors, 'Period', '$startDate to $endDate'),
                _dashedDivider(colors),
                _receiptRow(typography, colors, 'Payment Ref', receiptNo),
                _receiptRow(typography, colors, 'Date Issued',
                    createdAt == '-' ? '-' : createdAt.substring(0, 10)),
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
                        amountFormatted == '0'
                            ? context.tr('free_label')
                            : 'TZS $amountFormatted',
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
                  context.tr('thank_you_subscription'),
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
              (_) => Container(width: 5, height: 1, color: colors.border),
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
              style: typography.body.xs2.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<pw.Document> _generatePdf(
    String planName, double amount, bool paid, String startDate, String endDate, String receiptNo, String createdAt, String invoiceId,
  ) {
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
              _pdfRow('Invoice ID', invoiceId),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.grey200),
              pw.SizedBox(height: 8),
              _pdfRow('Plan', planName),
              _pdfRow('Amount', amount == 0 ? 'FREE' : 'TZS ${amount.toStringAsFixed(0)}'),
              _pdfRow('Period', '$startDate to $endDate'),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.grey200),
              pw.SizedBox(height: 8),
              _pdfRow('Payment Reference', receiptNo),
              _pdfRow('Date Issued', createdAt == '-' ? '-' : createdAt.substring(0, 10)),
              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL AMOUNT', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    amount == 0 ? 'FREE' : 'TZS ${amount.toStringAsFixed(0)}',
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
                    pw.Text('Thank you for your subscription!', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
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

  Future<void> _downloadPdf(
    BuildContext context, Map<String, dynamic> invoice, String planName, double amount, bool paid,
    String startDate, String endDate, String receiptNo, String createdAt, String invoiceId,
  ) async {
    try {
    final doc = await _generatePdf(planName, amount, paid, startDate, endDate, receiptNo, createdAt, invoiceId);
      await Printing.layoutPdf(onLayout: (format) async => doc.save());
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context, context.tr('failed_generate_pdf').replaceAll('{0}', AppError.getMessage(e)));
      }
    }
  }

  Future<void> _sharePdf(
    BuildContext context, Map<String, dynamic> invoice, String planName, double amount, bool paid,
    String startDate, String endDate, String receiptNo, String createdAt, String invoiceId,
  ) async {
    try {
    final doc = await _generatePdf(planName, amount, paid, startDate, endDate, receiptNo, createdAt, invoiceId);
      final output = await doc.save();
      final bytes = Uint8List.fromList(output);
      final dir = await Directory.systemTemp.createTemp();
      final file = File('${dir.path}/EFD_Receipt_$receiptNo.pdf');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: 'EFD Receipt - $planName');
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context, context.tr('failed_share_pdf').replaceAll('{0}', AppError.getMessage(e)));
      }
    }
  }
}
