import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/tenants_provider.dart';
import '../widgets/tenant_card.dart';

class TenantsListScreen extends ConsumerStatefulWidget {
  const TenantsListScreen({super.key});

  @override
  ConsumerState<TenantsListScreen> createState() => _TenantsListScreenState();
}

class _TenantsListScreenState extends ConsumerState<TenantsListScreen> {
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, active, moved_out

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tenantsAsync = ref.watch(tenantsListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Tenants', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search tenants...',
                hintStyle: GoogleFonts.nunito(fontSize: 14),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Active', 'active'),
                const SizedBox(width: 8),
                _buildFilterChip('Moved Out', 'moved_out'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(tenantsListProvider),
              color: AppColors.primary,
              child: tenantsAsync.when(
                loading: () => const LoadingIndicator(),
                error: (e, _) {
                  final message = e.toString();
                  final isSetupError = message.toLowerCase().contains('kyc') ||
                      message.toLowerCase().contains('subscription') ||
                      message.toLowerCase().contains('organization');
                  return ErrorState(
                    message: message,
                    onRetry: () => ref.invalidate(tenantsListProvider),
                    onAction: isSetupError ? () => context.go('/landlord/subscription') : null,
                    actionLabel: 'Complete Setup',
                  );
                },
                data: (tenants) {
                  final filtered = tenants.where((t) {
                    final name = (t['user']?['full_name'] ?? t['full_name'] ?? '').toString().toLowerCase();
                    final phone = (t['user']?['phone'] ?? t['phone'] ?? '').toString().toLowerCase();
                    final matchesSearch = name.contains(_searchQuery) || phone.contains(_searchQuery);
                    final status = (t['status'] ?? 'active').toString();
                    final matchesStatus = _filterStatus == 'all' || status == _filterStatus;
                    return matchesSearch && matchesStatus;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const EmptyState(message: 'No tenants found. Add your first tenant.', icon: Icons.people_outline);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => TenantCard(tenant: filtered[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/landlord/tenants/add'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add),
        label: const Text('Add'),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return ChoiceChip(
      label: Text(label, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.textLight))),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
      onSelected: (_) => setState(() => _filterStatus = value),
    );
  }
}
