import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../../../../core/constants/app_colors.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> invoice;
  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plan = invoice['plan'] ?? {};
    final planName = plan['name']?.toString() ?? 'Subscription';
    final amount = invoice['amount'] ?? 0;
    final amountDouble = (amount is num ? amount.toDouble() : double.tryParse(amount.toString()) ?? 0);
    final amountFormatted = amountDouble.toStringAsFixed(0);
    final status = invoice['status']?.toString() ?? 'unknown';
    final paid = status == 'active' || status == 'paid';
    final startDate = invoice['start_date']?.toString() ?? '-';
    final endDate = invoice['end_date']?.toString() ?? '-';
    final reference = invoice['payment_reference']?.toString() ?? '-';
    final createdAt = invoice['created_at']?.toString() ?? '-';
    final invoiceId = invoice['id']?.toString() ?? invoice['uuid']?.toString() ?? '-';
    final receiptNo = reference != '-' ? reference : 'RCP-${createdAt.replaceAll(RegExp(r'[^0-9]'), '').substring(0, 12)}';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('EFD Receipt', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/landlord/subscription');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadPdf(context, invoice, planName, amountDouble, paid, startDate, endDate, receiptNo, createdAt, invoiceId),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePdf(context, invoice, planName, amountDouble, paid, startDate, endDate, receiptNo, createdAt, invoiceId),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildReceiptCard(
              context, isDark, planName, amountFormatted, paid, startDate, endDate, receiptNo, createdAt, invoiceId,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadPdf(context, invoice, planName, amountDouble, paid, startDate, endDate, receiptNo, createdAt, invoiceId),
                    icon: const Icon(Icons.download, size: 18),
                    label: Text('Download PDF', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sharePdf(context, invoice, planName, amountDouble, paid, startDate, endDate, receiptNo, createdAt, invoiceId),
                    icon: const Icon(Icons.share, size: 18),
                    label: Text('Share', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13)),
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

  Widget _buildReceiptCard(
    BuildContext context, bool isDark, String planName, String amountFormatted,
    bool paid, String startDate, String endDate, String receiptNo, String createdAt, String invoiceId,
  ) {
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
                Text('MANNA APARTMENT', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text('Electronic Fiscal Device Receipt', style: GoogleFonts.nunito(fontSize: 11, color: Colors.white70, letterSpacing: 0.5)),
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
                _buildReceiptRow(isDark, 'Receipt No.', receiptNo),
                _buildReceiptRow(isDark, 'Invoice ID', invoiceId),
                _buildDivider(isDark),
                _buildReceiptRow(isDark, 'Plan', planName),
                _buildReceiptRow(isDark, 'Amount', amountFormatted == '0' ? 'FREE' : 'TZS $amountFormatted'),
                _buildReceiptRow(isDark, 'Period', '$startDate to $endDate'),
                _buildDivider(isDark),
                _buildReceiptRow(isDark, 'Payment Ref', receiptNo),
                _buildReceiptRow(isDark, 'Date Issued', createdAt == '-' ? '-' : createdAt.substring(0, 10)),
                _buildDivider(isDark),
                // Total
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TOTAL AMOUNT', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark)),
                      Text(
                        amountFormatted == '0' ? 'FREE' : 'TZS $amountFormatted',
                        style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                _buildDivider(isDark),
                const SizedBox(height: 12),
                // Footer
                Text('This is a computer generated receipt.', style: GoogleFonts.nunito(fontSize: 10, color: isDark ? Colors.white38 : Colors.grey.shade500, fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                Text('Thank you for your subscription!', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.white60 : AppColors.textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(bool isDark, String label, String value) {
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

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
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
              // Header
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
              // Receipt details
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
              // Total
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
              // Footer
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e'), backgroundColor: AppColors.error),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share PDF: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}
