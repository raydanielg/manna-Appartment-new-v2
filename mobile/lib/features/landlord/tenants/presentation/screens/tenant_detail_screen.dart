import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../providers/tenants_provider.dart';
import '../../../contracts/providers/contracts_provider.dart';

class TenantDetailScreen extends ConsumerWidget {
  const TenantDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    final tenantAsync = ref.watch(tenantDetailProvider(id));

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Tenant Details', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
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
      body: tenantAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(tenantDetailProvider(id))),
        data: (tenant) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.info, AppColors.primary]),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: Center(
                        child: Text(
                          _getTenantName(tenant)[0].toUpperCase(),
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _getTenantName(tenant),
                      style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(_getTenantPhone(tenant), style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textLight)),
                    const SizedBox(height: 10),
                    StatusBadge(status: tenant['status'] ?? 'active'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoCard(context, tenant),
              const SizedBox(height: 24),
              _buildContractsSection(context, tenant, id, ref),
              const SizedBox(height: 24),
              _buildPaymentsSection(context, tenant, id, ref),
            ],
          ),
        ),
      ),
    );
  }

  String _getTenantName(Map<String, dynamic> t) {
    final userData = t['user'] as Map<String, dynamic>?;
    return userData?['full_name'] ?? t['full_name'] ?? t['name'] ?? 'Unknown';
  }

  String _getTenantPhone(Map<String, dynamic> t) {
    final userData = t['user'] as Map<String, dynamic>?;
    return userData?['phone'] ?? t['phone'] ?? '';
  }

  double _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  String _formatAmount(dynamic value) {
    return NumberFormat('#,###').format(_parseAmount(value));
  }

  Widget _buildInfoCard(BuildContext context, Map<String, dynamic> tenant) {
    final balance = _parseAmount(tenant['balance_due']);
    final unit = tenant['unit'] ?? {};
    final property = unit['property'] ?? {};

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _row(Icons.apartment_outlined, 'Property', property['name'] ?? 'N/A'),
          const Divider(height: 1, indent: 56),
          _row(Icons.location_on_outlined, 'Address', property['address'] ?? 'N/A'),
          const Divider(height: 1, indent: 56),
          _row(Icons.meeting_room_outlined, 'Unit', unit['name'] ?? 'No unit'),
          const Divider(height: 1, indent: 56),
          _row(Icons.payments_outlined, 'Rent', 'TZS ${_formatAmount(tenant['rent_amount'])}'),
          const Divider(height: 1, indent: 56),
          _row(Icons.account_balance_wallet_outlined, 'Total Paid', 'TZS ${_formatAmount(tenant['total_paid'])}'),
          const Divider(height: 1, indent: 56),
          _row(Icons.warning_amber_rounded, 'Balance Due', 'TZS ${_formatAmount(balance)}', color: balance > 0 ? AppColors.error : AppColors.success),
          const Divider(height: 1, indent: 56),
          _row(Icons.calendar_today_outlined, 'Move-in', tenant['moved_in_date'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildContractsSection(BuildContext context, Map<String, dynamic> tenant, String id, WidgetRef ref) {
    final contracts = (tenant['contracts'] ?? []) as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Contracts', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            TextButton.icon(
              onPressed: () => context.push('/landlord/contracts/create'),
              icon: const Icon(Icons.add, size: 18),
              label: Text('New Contract', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (contracts.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(child: Text('No contracts yet', style: GoogleFonts.nunito(color: AppColors.textLight))),
          )
        else
          ...contracts.map((c) {
            final contract = c is Map<String, dynamic> ? c : <String, dynamic>{};
            return _buildContractCard(context, contract, ref);
          }),
      ],
    );
  }

  Widget _buildContractCard(BuildContext context, Map<String, dynamic> contract, WidgetRef ref) {
    final unitName = contract['unit']?['name'] ?? contract['unit']?['unit_number'] ?? 'N/A';
    final startDate = _formatDate(contract['start_date']);
    final endDate = _formatDate(contract['end_date']);
    final status = contract['status'] ?? 'active';
    final contractId = contract['id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/landlord/contracts/$contractId'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.description_outlined, color: AppColors.info, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Unit: $unitName', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        const SizedBox(height: 2),
                        Text('$startDate - $endDate', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                  StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          final path = await ref.read(contractsRepositoryProvider).downloadPdf(contractId);
                          await OpenFilex.open(path);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Download failed: $e'), backgroundColor: AppColors.error),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.download, size: 16),
                      label: Text('Download PDF', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                        minimumSize: const Size(double.infinity, 36),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentsSection(BuildContext context, Map<String, dynamic> tenant, String id, WidgetRef ref) {
    final payments = (tenant['payments'] ?? []) as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Payment History', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            TextButton.icon(
              onPressed: () => context.push('/landlord/payments/record'),
              icon: const Icon(Icons.add, size: 18),
              label: Text('Record', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (payments.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(child: Text('No payments recorded', style: GoogleFonts.nunito(color: AppColors.textLight))),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: payments.asMap().entries.map((entry) {
                final payment = entry.value is Map<String, dynamic> ? entry.value as Map<String, dynamic> : <String, dynamic>{};
                final index = entry.key;
                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.success.withValues(alpha: 0.1),
                        child: const Icon(Icons.check, size: 14, color: AppColors.success),
                      ),
                      title: Text(
                        'TZS ${_formatAmount(payment['amount'])}',
                        style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                      subtitle: Text(
                        payment['payment_date'] != null ? DateFormat('dd MMM yyyy').format(DateTime.tryParse(payment['payment_date'].toString()) ?? DateTime.now()) : '-',
                        style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textLight),
                      ),
                      trailing: Text(
                        (payment['status'] ?? 'paid').toString().toUpperCase(),
                        style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.success),
                      ),
                    ),
                    if (index < payments.length - 1) const Divider(height: 1, indent: 72),
                  ],
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showEditDialog(context, ref, id, tenant),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _confirmMoveOut(context, id, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                icon: const Icon(Icons.person_remove_outlined, size: 18),
                label: const Text('Move Out'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    final dt = DateTime.tryParse(date.toString());
    if (dt == null) return date.toString();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  void _confirmMoveOut(BuildContext context, String id, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Move Out Tenant', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to mark this tenant as moved out?', style: GoogleFonts.nunito(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(tenantsRepositoryProvider).moveOut(id);
                ref.invalidate(tenantDetailProvider(id));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tenant moved out'), backgroundColor: AppColors.success),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: const Text('Move Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, String id, Map<String, dynamic> tenant) {
    final nameController = TextEditingController(text: _getTenantName(tenant));
    final phoneController = TextEditingController(text: _getTenantPhone(tenant));
    final emailController = TextEditingController(text: (tenant['email'] ?? tenant['user']?['email'] ?? '').toString());
    final emergencyController = TextEditingController(text: tenant['emergency_contact'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Tenant', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
                TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone')),
                TextField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
                TextField(controller: emergencyController, decoration: const InputDecoration(labelText: 'Emergency Contact')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await ref.read(tenantsRepositoryProvider).updateTenant(id, {
                    'full_name': nameController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'email': emailController.text.trim(),
                    'emergency_contact': emergencyController.text.trim(),
                  });
                  ref.invalidate(tenantDetailProvider(id));
                  ref.invalidate(tenantsListProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tenant updated'), backgroundColor: AppColors.success),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Tenant', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete this tenant?', style: GoogleFonts.nunito(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(tenantsRepositoryProvider).deleteTenant(id);
                ref.invalidate(tenantsListProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tenant deleted'), backgroundColor: AppColors.success),
                  );
                  if (context.canPop()) context.pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(label, style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textLight)),
      trailing: Text(
        value,
        style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: color ?? AppColors.textDark),
      ),
    );
  }
}
