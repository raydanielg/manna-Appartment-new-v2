import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../providers/tenants_provider.dart';

class TenantDetailScreen extends ConsumerWidget {
  const TenantDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    final tenantAsync = ref.watch(tenantDetailProvider(id));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Tenant Details', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
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
                          (tenant['full_name'] ?? 'T')[0].toUpperCase(),
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      tenant['full_name'] ?? 'Unknown',
                      style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(tenant['phone'] ?? '', style: GoogleFonts.nunito(fontSize: 14, color: isDark ? Colors.white60 : AppColors.textLight)),
                    const SizedBox(height: 10),
                    StatusBadge(status: tenant['status'] ?? 'active'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoCard(context, tenant),
              const SizedBox(height: 24),
              _buildPaymentsSection(context, tenant, id, ref),
            ],
          ),
        ),
      ),
    );
  }

  double _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  Widget _buildInfoCard(BuildContext context, Map<String, dynamic> tenant) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final balance = _parseAmount(tenant['balance_due']);
    final unit = tenant['unit'] ?? {};
    final property = unit['property'] ?? {};

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _row(context, Icons.apartment, 'Property', property['name'] ?? 'N/A'),
          const Divider(height: 1, indent: 56),
          _row(context, Icons.location_on_outlined, 'Address', property['address'] ?? 'N/A'),
          const Divider(height: 1, indent: 56),
          _row(context, Icons.meeting_room_outlined, 'Unit', unit['name'] ?? 'No unit'),
          const Divider(height: 1, indent: 56),
          _row(context, Icons.money_outlined, 'Rent', 'TZS ${_parseAmount(tenant['rent_amount']).toStringAsFixed(0)}'),
          const Divider(height: 1, indent: 56),
          _row(context, Icons.account_balance_wallet, 'Total Paid', 'TZS ${_parseAmount(tenant['total_paid']).toStringAsFixed(0)}'),
          const Divider(height: 1, indent: 56),
          _row(context, Icons.warning_amber_rounded, 'Balance Due', 'TZS ${balance.toStringAsFixed(0)}', color: balance > 0 ? Colors.red : AppColors.success),
          const Divider(height: 1, indent: 56),
          _row(context, Icons.calendar_today, 'Move-in', tenant['moved_in_date'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildPaymentsSection(BuildContext context, Map<String, dynamic> tenant, String id, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final payments = (tenant['payments'] ?? []) as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Payment History', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
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
            decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text('No payments recorded', style: GoogleFonts.nunito(color: isDark ? Colors.white60 : AppColors.textLight))),
          )
        else
          Container(
            decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: payments.asMap().entries.map((entry) {
                final payment = entry.value as Map<String, dynamic>;
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
                        'TZS ${(payment['amount'] ?? 0).toDouble().toStringAsFixed(0)}',
                        style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark),
                      ),
                      subtitle: Text(
                        payment['payment_date'] != null ? DateFormat('dd MMM yyyy').format(DateTime.tryParse(payment['payment_date'].toString()) ?? DateTime.now()) : '-',
                        style: GoogleFonts.nunito(fontSize: 11, color: isDark ? Colors.white60 : AppColors.textLight),
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
                onPressed: () => context.push('/landlord/contracts/create'),
                icon: const Icon(Icons.description),
                label: const Text('Contract'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _confirmMoveOut(context, id, ref),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                icon: const Icon(Icons.person_remove),
                label: const Text('Move Out'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _confirmMoveOut(BuildContext context, String id, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move Out Tenant'),
        content: const Text('Are you sure you want to mark this tenant as moved out?'),
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

  Widget _row(BuildContext context, IconData icon, String label, String value, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(label, style: GoogleFonts.nunito(fontSize: 13, color: isDark ? Colors.white60 : AppColors.textLight)),
      trailing: Text(
        value,
        style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: color ?? (isDark ? Colors.white : AppColors.textDark)),
      ),
    );
  }
}
