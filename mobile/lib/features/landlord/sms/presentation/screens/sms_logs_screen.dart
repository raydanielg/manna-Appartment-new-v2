import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../providers/sms_provider.dart';
import '../widgets/sms_log_tile.dart';

class SmsLogsScreen extends ConsumerWidget {
  const SmsLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logsAsync = ref.watch(smsLogsProvider);
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: const Text('SMS Logs'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(smsLogsProvider),
        color: AppColors.primary,
        child: logsAsync.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(smsLogsProvider)),
          data: (logs) => logs.isEmpty
              ? const EmptyState(message: 'No SMS logs yet.', icon: Icons.sms_outlined)
              : ListView.builder(padding: const EdgeInsets.all(16), itemCount: logs.length, itemBuilder: (c, i) => SmsLogTile(log: logs[i])),
        ),
      ),
    );
  }
}
