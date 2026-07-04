import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../providers/maintenance_provider.dart';

class MaintenanceRequestsScreen extends ConsumerWidget {
  const MaintenanceRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final requestsAsync = ref.watch(maintenanceRequestsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Maintenance Requests'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(maintenanceRequestsProvider),
        color: AppColors.primary,
        child: requestsAsync.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(maintenanceRequestsProvider)),
          data: (requests) => requests.isEmpty
              ? const EmptyState(message: 'No maintenance requests.', icon: Icons.build_outlined)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withValues(alpha: isDark ? 0.15 : 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.build, color: AppColors.warning, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(req['title'] ?? 'Request', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                                      const SizedBox(height: 2),
                                      Text(req['tenant']?['full_name'] ?? 'Unknown', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
                                    ],
                                  ),
                                ),
                                StatusBadge(status: req['status'] ?? 'pending'),
                              ],
                            ),
                            if (req['description'] != null) ...[
                              const SizedBox(height: 12),
                              Text(req['description'], style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : AppColors.textDark)),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      await ref.read(maintenanceRepositoryProvider).updateStatus(req['id'], 'in_progress');
                                      ref.invalidate(maintenanceRequestsProvider);
                                    },
                                    icon: const Icon(Icons.play_arrow, size: 18),
                                    label: const Text('Start'),
                                  ),
                                ),
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      await ref.read(maintenanceRepositoryProvider).updateStatus(req['id'], 'resolved');
                                      ref.invalidate(maintenanceRequestsProvider);
                                    },
                                    icon: const Icon(Icons.check_circle, size: 18),
                                    label: const Text('Resolve'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
