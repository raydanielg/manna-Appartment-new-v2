import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../providers/properties_provider.dart';

class PropertyDetailScreen extends ConsumerWidget {
  const PropertyDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = GoRouterState.of(context);
    final id = state.pathParameters['id'] ?? '';
    final propertyAsync = ref.watch(propertyDetailProvider(id));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Property Details'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/landlord/properties/add?id='),
          ),
        ],
      ),
      body: propertyAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(propertyDetailProvider(id))),
        data: (property) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(Icons.apartment, size: 64, color: Colors.white70),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                property.name,
                style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark),
              ),
              const SizedBox(height: 4),
              Text(
                property.address ?? 'No address',
                style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : AppColors.textLight),
              ),
              const SizedBox(height: 20),
              _buildInfoRow(context, Icons.category_outlined, 'Type', property.type ?? 'N/A'),
              _buildInfoRow(context, Icons.meeting_room_outlined, 'Total Units', ''),
              _buildInfoRow(context, Icons.check_circle_outline, 'Occupied', ''),
              _buildInfoRow(context, Icons.highlight_off, 'Vacant', ''),
              if (property.monthlyRevenue != null)
                _buildInfoRow(context, Icons.account_balance_wallet, 'Monthly Revenue', 'TZS '),
              if (property.description != null) ...[
                const SizedBox(height: 20),
                Text('Description', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                const SizedBox(height: 8),
                Text(property.description!, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : AppColors.textDark)),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/landlord/properties/add?id='),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.info),
                      icon: const Icon(Icons.meeting_room),
                      label: const Text('Units'),
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
