import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../providers/tenants_provider.dart';

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
        title: const Text('Tenant Details'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
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
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.info, AppColors.primary]),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          (tenant['full_name'] ?? 'T')[0].toUpperCase(),
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tenant['full_name'] ?? 'Unknown',
                      style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(tenant['phone'] ?? '', style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : AppColors.textLight)),
                    const SizedBox(height: 8),
                    StatusBadge(status: tenant['status'] ?? 'active'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoCard(context, tenant),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.payments),
                      label: const Text('Payments'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      icon: const Icon(Icons.person_remove),
                      label: const Text('Move Out'),
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

  Widget _buildInfoCard(BuildContext context, Map<String, dynamic> tenant) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Column(
        children: [
          _row(context, Icons.email_outlined, 'Email', tenant['email'] ?? 'N/A'),
          const Divider(height: 1, indent: 56),
          _row(context, Icons.meeting_room_outlined, 'Unit', tenant['unit']?['name'] ?? 'No unit'),
          const Divider(height: 1, indent: 56),
          _row(context, Icons.calendar_today, 'Move-in', tenant['move_in_date'] ?? 'N/A'),
          const Divider(height: 1, indent: 56),
          _row(context, Icons.account_balance_wallet, 'Balance', 'TZS '),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : AppColors.textLight)),
      trailing: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
    );
  }
}
