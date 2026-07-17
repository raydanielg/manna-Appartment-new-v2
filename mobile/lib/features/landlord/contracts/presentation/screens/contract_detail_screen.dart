import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../providers/contracts_provider.dart';

class ContractDetailScreen extends ConsumerWidget {
  const ContractDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    final contractAsync = ref.watch(contractDetailProvider(id));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Contract Details'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: contractAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(contractDetailProvider(id))),
        data: (contract) {
          final tenant = contract['tenant'];
          final unit = contract['unit'];
          final property = unit?['property'];
          final rent = _parseAmount(contract['rent_amount']);
          final deposit = _parseAmount(contract['deposit_amount']);
          final isManual = contract['contract_type'] == 'manual';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.info, AppColors.primary]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contract', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          StatusBadge(status: contract['status'] ?? 'active'),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                            child: Text(isManual ? 'Manual' : 'Digital', style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(context, 'Tenant', tenant?['full_name'] ?? tenant?['user']?['full_name'] ?? 'N/A', Icons.person),
                _buildSection(context, 'Property', property?['name'] ?? 'N/A', Icons.apartment),
                _buildSection(context, 'Unit', unit?['name'] ?? unit?['unit_number'] ?? 'N/A', Icons.meeting_room),
                _buildSection(context, 'Start Date', _formatDate(contract['start_date']), Icons.calendar_today),
                _buildSection(context, 'End Date', _formatDate(contract['end_date']), Icons.event),
                _buildSection(context, 'Monthly Rent', 'TZS ${rent.toStringAsFixed(0)}', Icons.account_balance_wallet),
                _buildSection(context, 'Deposit', 'TZS ${deposit.toStringAsFixed(0)}', Icons.savings),
                const SizedBox(height: 24),
                _buildA4Contract(context, contract),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (isManual)
                      Expanded(
                        child: PrimaryButton(
                          text: 'Download Word',
                          icon: const Icon(Icons.download),
                          onPressed: () => _downloadTemplate(context, ref, contract['tenant_id']?.toString()),
                        ),
                      )
                    else
                      Expanded(
                        child: PrimaryButton(
                          text: 'View PDF',
                          icon: const Icon(Icons.picture_as_pdf),
                          onPressed: () => _downloadAndOpen(context, ref, id),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Terminate',
                        color: AppColors.error,
                        icon: const Icon(Icons.cancel),
                        onPressed: () async {
                          await ref.read(contractsRepositoryProvider).terminateContract(id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Contract terminated'), backgroundColor: AppColors.warning, behavior: SnackBarBehavior.floating),
                            );
                            context.pop();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (contract['signed_at'] != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: AppColors.success),
                        const SizedBox(width: 8),
                        Text('Signed on ${contract['signed_at']}', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: AppColors.success)),
                      ],
                    ),
                  )
                else
                  PrimaryButton(
                    text: 'Sign Contract',
                    icon: const Icon(Icons.draw),
                    color: AppColors.info,
                    onPressed: () => context.push('/landlord/contracts/$id/sign'),
                  ),
                const SizedBox(height: 12),
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
    return double.tryParse(value.toString()) ?? 0;
  }

  Widget _buildSection(BuildContext context, String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: GoogleFonts.nunito(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(value, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark), textAlign: TextAlign.end, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadTemplate(BuildContext context, WidgetRef ref, String? tenantId) async {
    try {
      final path = await ref.read(contractsRepositoryProvider).downloadTemplate(tenantId: tenantId);
      await OpenFilex.open(path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _downloadAndOpen(BuildContext context, WidgetRef ref, String id) async {
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

  Widget _buildA4Contract(BuildContext context, Map<String, dynamic> contract) {
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
    final isSigned = contract['signed_at'] != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header band
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
          // Body
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Intro paragraph
                Text('This Tenancy Agreement is made and executed on this day between the Landlord and the Tenant named below, whereby the Landlord agrees to let and the Tenant agrees to take on rent the premises described herein, subject to the terms and conditions set forth in this agreement.', style: GoogleFonts.nunito(fontSize: 11, color: Colors.black54, height: 1.6)),
                const SizedBox(height: 24),

                // 1. PARTIES
                _buildDocSection('1. PARTIES', [
                  _buildDocRow('Landlord (Owner)', propertyName),
                  _buildDocRow('Tenant Name', tenantName),
                  _buildDocRow('Tenant Phone', tenantPhone),
                ]),
                const SizedBox(height: 20),

                // 2. PROPERTY
                _buildDocSection('2. PROPERTY DETAILS', [
                  _buildDocRow('Property Name', propertyName),
                  _buildDocRow('Address', propertyAddress),
                  _buildDocRow('Unit No.', unitName),
                ]),
                const SizedBox(height: 20),

                // 3. TERM
                _buildDocSection('3. TERM OF TENANCY', [
                  _buildDocRow('Start Date', start),
                  _buildDocRow('End Date', end),
                  _buildDocRow('Duration', _calcDuration(contract['start_date']?.toString(), contract['end_date']?.toString())),
                ]),
                const SizedBox(height: 20),

                // 4. RENT
                _buildDocSection('4. RENT AND DEPOSIT', [
                  _buildDocRow('Monthly Rent', 'TZS ${_formatNumber(rent)}'),
                  _buildDocRow('Security Deposit', 'TZS ${_formatNumber(deposit)}'),
                  _buildDocRow('Payment Due', 'On or before 5th of each month'),
                ]),
                const SizedBox(height: 20),

                // 5. TERMS AND CONDITIONS
                _buildDocSectionTitle('5. TERMS AND CONDITIONS'),
                const SizedBox(height: 10),
                _buildDocTerm('5.1', 'The Tenant shall pay the monthly rent on or before the 5th day of each calendar month. Late payment shall attract a penalty as determined by the Landlord.'),
                _buildDocTerm('5.2', 'The Tenant shall use the premises for residential purposes only and shall not sub-let, assign, or transfer any part of the premises without prior written consent of the Landlord.'),
                _buildDocTerm('5.3', 'The Tenant shall maintain the premises in good and clean condition and shall be responsible for any damage caused by negligence or misuse, excluding normal wear and tear.'),
                _buildDocTerm('5.4', 'The Landlord shall be responsible for structural repairs, plumbing, electrical, and other major maintenance. The Tenant shall report any defects promptly.'),
                _buildDocTerm('5.5', 'The Tenant shall not make any alterations, additions, or improvements to the premises without the prior written consent of the Landlord.'),
                _buildDocTerm('5.6', 'Either party may terminate this agreement by giving one (1) month written notice to the other party. The Landlord may terminate immediately for non-payment of rent or breach of any term herein.'),
                _buildDocTerm('5.7', 'Upon termination, the Tenant shall hand over the premises in the same condition as at the commencement of the tenancy, fair wear and tear excepted. The security deposit shall be refunded after deduction of any outstanding rent or damage costs.'),
                _buildDocTerm('5.8', 'The Tenant shall comply with all building rules, regulations, and by-laws as may be prescribed by the Landlord or local authorities from time to time.'),
                const SizedBox(height: 24),

                // 6. GOVERNING LAW
                _buildDocSectionTitle('6. GOVERNING LAW'),
                const SizedBox(height: 8),
                Text('This agreement shall be governed by and construed in accordance with the laws of the United Republic of Tanzania. Any dispute arising out of this agreement shall be resolved through arbitration or competent courts of jurisdiction.', style: GoogleFonts.nunito(fontSize: 11, color: Colors.black87, height: 1.6)),
                const SizedBox(height: 32),

                // 7. SIGNATURES
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
                          const SizedBox(height: 24),
                          Container(
                            height: 1,
                            color: Colors.black38,
                          ),
                          const SizedBox(height: 4),
                          Text('Signature & Date', style: GoogleFonts.nunito(fontSize: 9, color: Colors.black54)),
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
                          if (isSigned && contract['signature_path'] != null)
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.green.shade700, width: 1.5)),
                              ),
                              child: const Icon(Icons.draw, color: Colors.green, size: 28),
                            )
                          else
                            Container(height: 1, color: Colors.black38),
                          const SizedBox(height: 4),
                          Text(isSigned ? 'Signed on ${_formatDate(contract['signed_at'])}' : 'Signature & Date', style: GoogleFonts.nunito(fontSize: 9, color: isSigned ? Colors.green.shade700 : Colors.black54, fontWeight: isSigned ? FontWeight.w700 : FontWeight.w400)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Footer
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
          SizedBox(
            width: 120,
            child: Text(label, style: GoogleFonts.nunito(fontSize: 11, color: Colors.black54)),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black87)),
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
            child: Text(number, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black87)),
          ),
          Expanded(
            child: Text(text, style: GoogleFonts.nunito(fontSize: 11, color: Colors.black87, height: 1.5)),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double amount) {
    return amount.toStringAsFixed(0);
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
