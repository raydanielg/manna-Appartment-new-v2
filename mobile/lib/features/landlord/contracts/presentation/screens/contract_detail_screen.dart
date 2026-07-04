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
          final rent = (contract['rent_amount'] ?? 0).toDouble();
          final deposit = (contract['deposit_amount'] ?? 0).toDouble();
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
                _buildSection(context, 'Start Date', contract['start_date'] ?? 'N/A', Icons.calendar_today),
                _buildSection(context, 'End Date', contract['end_date'] ?? 'N/A', Icons.event),
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

  Widget _buildSection(BuildContext context, String label, String value, IconData icon) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tenant = contract['tenant'];
    final unit = contract['unit'];
    final property = unit?['property'];
    final rent = (contract['rent_amount'] ?? 0).toDouble();
    final deposit = (contract['deposit_amount'] ?? 0).toDouble();
    final start = contract['start_date'] ?? '_______';
    final end = contract['end_date'] ?? '_______';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text('TENANCY AGREEMENT', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black)),
                const SizedBox(height: 4),
                Text('Contract No: ${contract['contract_number'] ?? 'N/A'}', style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey.shade700)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('1. PARTIES', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
          const SizedBox(height: 6),
          Text('Landlord: ${property?['name'] ?? '________________'}', style: GoogleFonts.nunito(fontSize: 12, color: Colors.black87)),
          Text('Tenant: ${tenant?['full_name'] ?? tenant?['user']?['full_name'] ?? '________________'}', style: GoogleFonts.nunito(fontSize: 12, color: Colors.black87)),
          Text('Phone: ${tenant?['phone'] ?? tenant?['user']?['phone'] ?? '________________'}', style: GoogleFonts.nunito(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 16),
          Text('2. PROPERTY', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
          const SizedBox(height: 6),
          Text('Property: ${property?['name'] ?? '________________'}', style: GoogleFonts.nunito(fontSize: 12, color: Colors.black87)),
          Text('Address: ${property?['address'] ?? '________________'}', style: GoogleFonts.nunito(fontSize: 12, color: Colors.black87)),
          Text('Unit: ${unit?['name'] ?? unit?['unit_number'] ?? '________________'}', style: GoogleFonts.nunito(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 16),
          Text('3. TERM', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
          const SizedBox(height: 6),
          Text('Start Date: $start', style: GoogleFonts.nunito(fontSize: 12, color: Colors.black87)),
          Text('End Date: $end', style: GoogleFonts.nunito(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 16),
          Text('4. RENT', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
          const SizedBox(height: 6),
          Text('Monthly Rent: TZS ${rent.toStringAsFixed(0)}', style: GoogleFonts.nunito(fontSize: 12, color: Colors.black87)),
          Text('Deposit: TZS ${deposit.toStringAsFixed(0)}', style: GoogleFonts.nunito(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 16),
          Text('5. TERMS', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
          const SizedBox(height: 6),
          Text('The tenant agrees to pay rent on time, keep the property in good condition, and comply with all house rules. The landlord may terminate this agreement for non-payment or breach.', style: GoogleFonts.nunito(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: Text('Landlord: _______________', style: GoogleFonts.nunito(fontSize: 11, color: Colors.black87))),
              Expanded(child: Text('Tenant: _______________', style: GoogleFonts.nunito(fontSize: 11, color: Colors.black87))),
            ],
          ),
        ],
      ),
    );
  }
}
