import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../providers/contracts_provider.dart';

class ContractDetailScreen extends ConsumerStatefulWidget {
  const ContractDetailScreen({super.key});

  @override
  ConsumerState<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends ConsumerState<ContractDetailScreen> {
  bool _isPdfLoading = false;

  @override
  Widget build(BuildContext context) {
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    final contractAsync = ref.watch(contractDetailProvider(id));

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(context.tr('contract_details')),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: contractAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(message: AppError.getMessage(e), onRetry: () => ref.invalidate(contractDetailProvider(id))),
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
                      Text(context.tr('contract'), style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          StatusBadge(status: contract['status'] ?? 'active'),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                            child: Text(isManual ? context.tr('manual') : context.tr('digital'), style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(context.tr('tenant'), tenant?['full_name'] ?? tenant?['user']?['full_name'] ?? 'N/A', Icons.person_outline),
                _buildSection(context.tr('property'), property?['name'] ?? 'N/A', Icons.apartment_outlined),
                _buildSection(context.tr('unit'), unit?['name'] ?? unit?['unit_number'] ?? 'N/A', Icons.meeting_room_outlined),
                _buildSection(context.tr('start_date'), _formatDate(contract['start_date']), Icons.calendar_today_outlined),
                _buildSection(context.tr('end_date'), _formatDate(contract['end_date']), Icons.event_outlined),
                _buildSection(context.tr('monthly_rent_label'), 'TZS ${_formatNumber(rent)}', Icons.payments_outlined),
                _buildSection(context.tr('deposit'), 'TZS ${_formatNumber(deposit)}', Icons.savings_outlined),
                const SizedBox(height: 24),
                _buildA4Contract(context, contract),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: context.tr('view_pdf'),
                        icon: const Icon(Icons.picture_as_pdf, size: 18),
                        isLoading: _isPdfLoading,
                        onPressed: () => _downloadAndOpen(context, ref, id),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        text: context.tr('terminate'),
                        color: AppColors.error,
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        onPressed: () async {
                          await ref.read(contractsRepositoryProvider).terminateContract(id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(context.tr('contract_terminated')), backgroundColor: AppColors.warning, behavior: SnackBarBehavior.floating),
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
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: AppColors.success, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(context.tr('signed_on').replaceAll('{0}', _formatDate(contract['signed_at'])), style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: AppColors.success, fontSize: 13)),
                        ),
                      ],
                    ),
                  )
                else
                  PrimaryButton(
                    text: context.tr('sign_contract'),
                    icon: const Icon(Icons.draw, size: 18),
                    color: AppColors.info,
                    onPressed: () => context.push('/landlord/contracts/$id/sign'),
                  ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: context.tr('delete_contract'),
                  color: AppColors.error,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => _confirmDelete(context, ref, id),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(context.tr('delete_contract'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text(context.tr('confirm_delete_contract'), style: GoogleFonts.nunito(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('cancel'))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(contractsRepositoryProvider).deleteContract(id);
                ref.invalidate(contractsListProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.tr('contract_deleted')), backgroundColor: AppColors.success),
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

  double _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String _formatNumber(double amount) {
    return NumberFormat('#,###').format(amount);
  }

  Widget _buildSection(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textLight)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(value, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark), textAlign: TextAlign.end, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAndOpen(BuildContext context, WidgetRef ref, String id) async {
    setState(() => _isPdfLoading = true);
    try {
      final path = await ref.read(contractsRepositoryProvider).downloadPdf(id);
      await OpenFilex.open(path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('could_not_open_pdf').replaceAll('{0}', AppError.getMessage(e))), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
        );
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
    final tenantName = tenant?['full_name'] ?? tenant?['user']?['full_name'] ?? '________________';
    final tenantPhone = tenant?['phone'] ?? tenant?['user']?['phone'] ?? '________________';
    final propertyName = property?['name'] ?? '________________';
    final propertyAddress = property?['address'] ?? '________________';
    final unitName = unit?['name'] ?? unit?['unit_number'] ?? '________________';
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
                Text(context.tr('tenancy_agreement'), style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text(context.tr('contract_no_label').replaceAll('{0}', contractNo), style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 0.5)),
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
                Text(context.tr('tenancy_intro'), style: GoogleFonts.nunito(fontSize: 11, color: Colors.black54, height: 1.6)),
                const SizedBox(height: 24),

                // 1. PARTIES
                _buildDocSection('1. PARTIES', [
                  _buildDocRow(context.tr('landlord_owner'), propertyName),
                  _buildDocRow(context.tr('tenant_name_label'), tenantName),
                  _buildDocRow(context.tr('tenant_phone_label'), tenantPhone),
                ]),
                const SizedBox(height: 20),

                // 2. PROPERTY
                _buildDocSection('2. PROPERTY DETAILS', [
                  _buildDocRow(context.tr('property_name_label'), propertyName),
                  _buildDocRow(context.tr('address_label'), propertyAddress),
                  _buildDocRow(context.tr('unit_no_label'), unitName),
                ]),
                const SizedBox(height: 20),

                // 3. TERM
                _buildDocSection('3. TERM OF TENANCY', [
                  _buildDocRow(context.tr('start_date_label'), start),
                  _buildDocRow(context.tr('end_date_label'), end),
                  _buildDocRow(context.tr('duration_label'), _calcDuration(contract['start_date']?.toString(), contract['end_date']?.toString())),
                ]),
                const SizedBox(height: 20),

                // 4. RENT
                _buildDocSection('4. RENT AND DEPOSIT', [
                  _buildDocRow(context.tr('monthly_rent_label'), 'TZS ${_formatNumber(rent)}'),
                  _buildDocRow(context.tr('security_deposit_label'), 'TZS ${_formatNumber(deposit)}'),
                  _buildDocRow(context.tr('payment_due_label'), context.tr('payment_due_value')),
                ]),
                const SizedBox(height: 20),

                // 5. TERMS AND CONDITIONS
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

                // 6. GOVERNING LAW
                _buildDocSectionTitle('6. GOVERNING LAW'),
                const SizedBox(height: 8),
                Text(context.tr('governing_law_text'), style: GoogleFonts.nunito(fontSize: 11, color: Colors.black87, height: 1.6)),
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
                          Text(context.tr('landlord_label'), style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black87)),
                          const SizedBox(height: 24),
                          Container(
                            height: 1,
                            color: Colors.black38,
                          ),
                          const SizedBox(height: 4),
                          Text(context.tr('signature_date'), style: GoogleFonts.nunito(fontSize: 9, color: Colors.black54)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.tr('tenant_label'), style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black87)),
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
                          Text(isSigned ? context.tr('signed_on_label').replaceAll('{0}', _formatDate(contract['signed_at'])) : context.tr('signature_date'), style: GoogleFonts.nunito(fontSize: 9, color: isSigned ? Colors.green.shade700 : Colors.black54, fontWeight: isSigned ? FontWeight.w700 : FontWeight.w400)),
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
                  child: Text(context.tr('legally_binding_notice'), style: GoogleFonts.nunito(fontSize: 9, color: Colors.black45, fontStyle: FontStyle.italic)),
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

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    final dt = DateTime.tryParse(date.toString());
    if (dt == null) return date.toString();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _calcDuration(String? start, String? end) {
    if (start == null || end == null) return context.tr('custom_duration');
    final startDate = DateTime.tryParse(start);
    final endDate = DateTime.tryParse(end);
    if (startDate == null || endDate == null) return context.tr('custom_duration');
    final months = (endDate.year - startDate.year) * 12 + (endDate.month - startDate.month);
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
