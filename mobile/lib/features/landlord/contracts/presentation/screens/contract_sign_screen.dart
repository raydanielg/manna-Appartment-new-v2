import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/contracts_provider.dart';

class ContractSignScreen extends ConsumerStatefulWidget {
  const ContractSignScreen({super.key});

  @override
  ConsumerState<ContractSignScreen> createState() => _ContractSignScreenState();
}

class _ContractSignScreenState extends ConsumerState<ContractSignScreen> {
  final _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  bool _isLoading = false;
  Uint8List? _signatureBytes;
  bool _isPlaced = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _placeSignature() async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please draw your signature first'), backgroundColor: AppColors.error),
      );
      return;
    }
    final bytes = await _controller.toPngBytes() ?? Uint8List(0);
    setState(() {
      _signatureBytes = bytes;
      _isPlaced = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signature placed on document'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
    );
  }

  void _clearSignature() {
    _controller.clear();
    setState(() {
      _signatureBytes = null;
      _isPlaced = false;
    });
  }

  Future<void> _submit() async {
    if (_signatureBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please place your signature first'), backgroundColor: AppColors.error),
      );
      return;
    }
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    if (id.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final bytes = _signatureBytes!;
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/signature_$id.png';
      await File(path).writeAsBytes(bytes);

      final result = await ref.read(contractsRepositoryProvider).signContract(id, path);
      final pdfUrl = result['pdf_url']?.toString();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contract signed successfully'), backgroundColor: AppColors.success),
        );
      }
      if (pdfUrl != null && pdfUrl.isNotEmpty) {
        await _downloadAndOpen(id);
      }
      if (context.mounted && context.canPop()) context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signing failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadAndOpen(String id) async {
    try {
      final path = await ref.read(contractsRepositoryProvider).downloadPdf(id);
      await OpenFilex.open(path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open PDF: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    final contractAsync = ref.watch(contractDetailProvider(id));

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Sign Contract', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: Stack(
        children: [
          contractAsync.when(
            loading: () => const LoadingIndicator(),
            error: (e, _) => Center(child: Text('Failed to load contract', style: GoogleFonts.nunito(color: AppColors.error))),
            data: (contract) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 340),
              child: _buildContractPreview(contract),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildSignOverlay(),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOverlay() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _isPlaced ? AppColors.success.withValues(alpha: 0.1) : AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_isPlaced ? Icons.check_circle_outline : Icons.draw_outlined, color: _isPlaced ? AppColors.success : AppColors.info, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isPlaced ? 'Signature Placed' : 'Sign Here',
                        style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                      Text(
                        _isPlaced ? 'Review on document and confirm' : 'Draw your signature below',
                        style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _clearSignature,
                  icon: const Icon(Icons.refresh, size: 16, color: AppColors.error),
                  label: Text('Clear', style: GoogleFonts.nunito(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Signature(
                    controller: _controller,
                    backgroundColor: const Color(0xFFFAFAFA),
                  ),
                ),
                if (_controller.isEmpty && !_isPlaced)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: Text(
                          'Sign here',
                          style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade400, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (!_isPlaced)
                  Expanded(
                    child: PrimaryButton(
                      text: 'Place Signature',
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      onPressed: _placeSignature,
                    ),
                  )
                else
                  Expanded(
                    child: PrimaryButton(
                      text: 'Confirm & Submit',
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractPreview(Map<String, dynamic> contract) {
    final tenant = contract['tenant'];
    final unit = contract['unit'];
    final property = unit?['property'];
    final rent = _parseAmount(contract['rent_amount']);
    final deposit = _parseAmount(contract['deposit_amount']);
    final start = _formatDate(contract['start_date']);
    final end = _formatDate(contract['end_date']);
    final tenantName = tenant?['full_name'] ?? tenant?['user']?['full_name'] ?? '________________';
    final tenantPhone = tenant?['phone'] ?? tenant?['user']?['phone'] ?? '________________';
    final propertyName = property?['name'] ?? '________________';
    final propertyAddress = property?['address'] ?? '________________';
    final unitName = unit?['name'] ?? unit?['unit_number'] ?? '________________';
    final contractNo = contract['contract_number'] ?? 'N/A';
    final isManual = contract['contract_type'] == 'manual';
    final customTerms = contract['template_content']?.toString() ?? '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            ),
            child: Column(
              children: [
                Text('TENANCY AGREEMENT', style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text('Contract No: $contractNo', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 0.5)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This Tenancy Agreement is made and executed on this day between the Landlord and the Tenant named below, whereby the Landlord agrees to let and the Tenant agrees to take on rent the premises described herein, subject to the terms and conditions set forth in this agreement.', style: GoogleFonts.nunito(fontSize: 11, color: Colors.black54, height: 1.6)),
                const SizedBox(height: 24),
                _buildDocSection('1. PARTIES', [
                  _buildDocRow('Landlord (Owner)', propertyName),
                  _buildDocRow('Tenant Name', tenantName),
                  _buildDocRow('Tenant Phone', tenantPhone),
                ]),
                const SizedBox(height: 20),
                _buildDocSection('2. PROPERTY DETAILS', [
                  _buildDocRow('Property Name', propertyName),
                  _buildDocRow('Address', propertyAddress),
                  _buildDocRow('Unit No.', unitName),
                ]),
                const SizedBox(height: 20),
                _buildDocSection('3. TERM OF TENANCY', [
                  _buildDocRow('Start Date', start),
                  _buildDocRow('End Date', end),
                  _buildDocRow('Duration', _calcDuration(contract['start_date']?.toString(), contract['end_date']?.toString())),
                ]),
                const SizedBox(height: 20),
                _buildDocSection('4. RENT AND DEPOSIT', [
                  _buildDocRow('Monthly Rent', 'TZS ${_formatNumber(rent)}'),
                  _buildDocRow('Security Deposit', 'TZS ${_formatNumber(deposit)}'),
                  _buildDocRow('Payment Due', 'On or before 5th of each month'),
                ]),
                const SizedBox(height: 20),
                _buildDocSectionTitle('5. TERMS AND CONDITIONS'),
                const SizedBox(height: 10),
                if (isManual && customTerms.isNotEmpty)
                  Text(customTerms, style: GoogleFonts.nunito(fontSize: 11, color: Colors.black87, height: 1.6))
                else ...[
                  _buildDocTerm('5.1', 'The Tenant shall pay the monthly rent on or before the 5th day of each calendar month. Late payment shall attract a penalty as determined by the Landlord.'),
                  _buildDocTerm('5.2', 'The Tenant shall use the premises for residential purposes only and shall not sub-let, assign, or transfer any part of the premises without prior written consent of the Landlord.'),
                  _buildDocTerm('5.3', 'The Tenant shall maintain the premises in good and clean condition and shall be responsible for any damage caused by negligence or misuse, excluding normal wear and tear.'),
                  _buildDocTerm('5.4', 'The Landlord shall be responsible for structural repairs, plumbing, electrical, and other major maintenance. The Tenant shall report any defects promptly.'),
                  _buildDocTerm('5.5', 'The Tenant shall not make any alterations, additions, or improvements to the premises without the prior written consent of the Landlord.'),
                  _buildDocTerm('5.6', 'Either party may terminate this agreement by giving one (1) month written notice to the other party. The Landlord may terminate immediately for non-payment of rent or breach of any term herein.'),
                  _buildDocTerm('5.7', 'Upon termination, the Tenant shall hand over the premises in the same condition as at the commencement of the tenancy, fair wear and tear excepted. The security deposit shall be refunded after deduction of any outstanding rent or damage costs.'),
                  _buildDocTerm('5.8', 'The Tenant shall comply with all building rules, regulations, and by-laws as may be prescribed by the Landlord or local authorities from time to time.'),
                ],
                const SizedBox(height: 24),
                _buildDocSectionTitle('6. GOVERNING LAW'),
                const SizedBox(height: 8),
                Text('This agreement shall be governed by and construed in accordance with the laws of the United Republic of Tanzania. Any dispute arising out of this agreement shall be resolved through arbitration or competent courts of jurisdiction.', style: GoogleFonts.nunito(fontSize: 11, color: Colors.black87, height: 1.6)),
                const SizedBox(height: 32),
                _buildDocSectionTitle('7. SIGNATURES'),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Landlord', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black87)),
                          const SizedBox(height: 8),
                          if (_signatureBytes != null)
                            Container(
                              height: 80,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Image.memory(_signatureBytes!, fit: BoxFit.contain),
                            )
                          else
                            const SizedBox(height: 24),
                          Container(height: 1, color: Colors.black38),
                          const SizedBox(height: 4),
                          Text(
                            _signatureBytes != null ? 'Signed on ${_formatDate(DateTime.now().toIso8601String())}' : 'Signature & Date',
                            style: GoogleFonts.nunito(
                              fontSize: 9,
                              color: _signatureBytes != null ? Colors.green.shade700 : Colors.black54,
                              fontWeight: _signatureBytes != null ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tenant', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black87)),
                          const SizedBox(height: 24),
                          Container(height: 1, color: Colors.black38),
                          const SizedBox(height: 4),
                          Text('Signature & Date', style: GoogleFonts.nunito(fontSize: 9, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(6)),
                  child: Text('This is a legally binding document. Both parties acknowledge having read and understood all terms and conditions herein.', style: GoogleFonts.nunito(fontSize: 9, color: Colors.black45, fontStyle: FontStyle.italic)),
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
    return Text(title, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black87, letterSpacing: 0.3));
  }

  Widget _buildDocRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: GoogleFonts.nunito(fontSize: 11, color: Colors.black54))),
          Expanded(child: Text(value, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black87))),
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
          SizedBox(width: 32, child: Text(number, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black87))),
          Expanded(child: Text(text, style: GoogleFonts.nunito(fontSize: 11, color: Colors.black87, height: 1.5))),
        ],
      ),
    );
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

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    final dt = DateTime.tryParse(date.toString());
    if (dt == null) return date.toString();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _calcDuration(String? start, String? end) {
    if (start == null || end == null) return 'Custom';
    final startDate = DateTime.tryParse(start);
    final endDate = DateTime.tryParse(end);
    if (startDate == null || endDate == null) return 'Custom';
    final months = (endDate.year - startDate.year) * 12 + (endDate.month - startDate.month);
    if (months <= 0) return 'Custom';
    if (months % 12 == 0) {
      final years = months ~/ 12;
      return '$years year${years > 1 ? 's' : ''}';
    }
    return '$months month${months > 1 ? 's' : ''}';
  }
}
