import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../providers/units_provider.dart';

class UnitDetailScreen extends ConsumerWidget {
  const UnitDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    final unitAsync = ref.watch(unitDetailProvider(id));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Unit Details'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => context.push('/landlord/units/add?id=')),
        ],
      ),
      body: unitAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(unitDetailProvider(id))),
        data: (unit) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(unit['name'] ?? unit['unit_number'] ?? 'Unit', style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('TZS /month', style: const TextStyle(fontSize: 16, color: Colors.white70)),
                    const SizedBox(height: 12),
                    StatusBadge(status: unit['status'] ?? 'vacant'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoRow(context, Icons.category_outlined, 'Type', unit['type'] ?? 'N/A'),
              _buildInfoRow(context, Icons.square_foot, 'Size', ' sqm'),
              _buildInfoRow(context, Icons.bed, 'Bedrooms', ''),
              _buildInfoRow(context, Icons.bathtub, 'Bathrooms', ''),
              if (unit['tenant'] != null) ...[
                const SizedBox(height: 20),
                Text('Current Tenant', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person, color: AppColors.info),
                    title: Text(unit['tenant']['full_name'] ?? 'Unknown'),
                    subtitle: Text(unit['tenant']['phone'] ?? ''),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : AppColors.textLight)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
        ],
      ),
    );
  }
}
