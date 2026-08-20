import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../providers/maintenance_provider.dart';

class MyMaintenanceRequestsScreen extends ConsumerWidget {
  const MyMaintenanceRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(myMaintenanceRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(title: Text(context.tr('my_maintenance_requests'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myMaintenanceRequestsProvider),
        color: AppColors.primary,
        child: requestsAsync.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) {
            if (e is DioException && e.response?.statusCode == 404) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(color: AppColors.textLight.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.build_outlined, size: 36, color: AppColors.textLight),
                      ),
                      const SizedBox(height: 20),
                      Text(context.tr('no_requests_yet'), style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                      const SizedBox(height: 8),
                      Text(context.tr('no_requests_desc'), textAlign: TextAlign.center, style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textLight, height: 1.5)),
                    ],
                  ),
                ),
              );
            }
            return ErrorState(message: AppError.getMessage(e), onRetry: () => ref.invalidate(myMaintenanceRequestsProvider));
          },
          data: (requests) => requests.isEmpty
              ? EmptyState(message: context.tr('no_maintenance_yet'), icon: Icons.build_outlined)
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
                                    color: AppColors.warning.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.build, color: AppColors.warning, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(req['title'] ?? req['description'] ?? 'Request', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                                ),
                                StatusBadge(status: req['status'] ?? 'pending'),
                              ],
                            ),
                            if (req['description'] != null) ...[
                              const SizedBox(height: 12),
                              Text(req['description'], style: TextStyle(fontSize: 13, color: AppColors.textDark)),
                            ],
                            if (req['created_at'] != null) ...[
                              const SizedBox(height: 8),
                              Text('${context.tr('submitted')}: ${req['created_at']}', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tenant/maintenance/submit'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: Text(context.tr('new_request')),
      ),
    );
  }
}
