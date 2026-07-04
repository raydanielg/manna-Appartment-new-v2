import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../providers/staff_provider.dart';

class StaffListScreen extends ConsumerWidget {
  const StaffListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final staffAsync = ref.watch(staffListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Staff'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(staffListProvider),
        color: AppColors.primary,
        child: staffAsync.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(staffListProvider)),
          data: (staff) => staff.isEmpty
              ? const EmptyState(message: 'No staff members yet.', icon: Icons.badge_outlined)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: staff.length,
                  itemBuilder: (context, index) {
                    final s = staff[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: isDark ? 0.15 : 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.badge, color: AppColors.gold, size: 22),
                        ),
                        title: Text(s['full_name'] ?? 'Unknown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                        subtitle: Text(s['role'] ?? 'Staff', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
                        trailing: StatusBadge(status: s['status'] ?? 'active'),
                        onTap: () => context.push('/landlord/staff/${s['id']}/permissions'),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/landlord/staff/add'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Staff'),
      ),
    );
  }
}
