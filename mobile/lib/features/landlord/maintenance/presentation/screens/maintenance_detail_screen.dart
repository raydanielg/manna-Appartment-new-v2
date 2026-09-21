import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/maintenance_provider.dart';

import 'package:manna_apartment/core/utils/app_toast.dart';

class MaintenanceDetailScreen extends ConsumerStatefulWidget {
  const MaintenanceDetailScreen({super.key});

  @override
  ConsumerState<MaintenanceDetailScreen> createState() =>
      _MaintenanceDetailScreenState();
}

class _MaintenanceDetailScreenState
    extends ConsumerState<MaintenanceDetailScreen> {
  final _notesController = TextEditingController();
  String? _selectedStatus;
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String id, String status) async {
    if (_selectedStatus == null) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(maintenanceRepositoryProvider);
      await repo.updateStatus(id, status,
          notes: _notesController.text.trim());
      ref.invalidate(maintenanceDetailProvider(id));
      ref.invalidate(maintenanceRequestsProvider);
      if (mounted) {
        AppToast.success(
          context,
          context
              .tr('status_updated_to')
              .replaceAll('{0}', status.replaceAll('_', ' ')),
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(
          context,
          context
              .tr('failed_msg')
              .replaceAll('{0}', AppError.getMessage(e)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    final requestAsync = ref.watch(maintenanceDetailProvider(id));
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final initialStatus = extra?['initialStatus']?.toString();

    final statusOptions = [
      ('open', context.tr('open'), const Color(0xFFD97706)),
      ('in_progress', context.tr('in_progress'), const Color(0xFF0EA5E9)),
      ('resolved', context.tr('resolved'), const Color(0xFF16A34A)),
      ('cancelled', context.tr('cancelled'), colors.mutedForeground),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('request_details'),
          style: typography.display.md.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: FButton.icon(
          variant: .ghost,
          size: .sm,
          onPress: () {
            if (context.canPop()) context.pop();
          },
          child: context.theme.icons.arrowLeft(context),
        ),
      ),
      body: requestAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          message: AppError.getMessage(e),
          onRetry: () => ref.invalidate(maintenanceDetailProvider(id)),
        ),
        data: (req) {
          final status = req['status'] ?? 'open';
          _selectedStatus ??= initialStatus ?? status;
          final createdAt = req['created_at'] != null
              ? DateFormat('dd MMM yyyy, HH:mm').format(
                  DateTime.tryParse(req['created_at'].toString()) ??
                      DateTime.now())
              : '-';
          final tenant = req['tenant'];
          final unit = req['unit'];
          final statusColor = statusOptions
              .firstWhere((o) => o.$1 == status,
                  orElse: () => statusOptions.first)
              .$3;
          final stepIndex = switch (status) {
            'in_progress' => 1,
            'resolved' => 2,
            _ => 0,
          };
          final isCancelled = status == 'cancelled';

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              // Title + status pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      req['title'] ?? context.tr('request'),
                      style: typography.display.sm
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _pill(context, status.toString(), statusColor),
                ],
              ),
              const SizedBox(height: 14),

              // Progress stepper
              if (!isCancelled)
                _stepper(context, stepIndex)
              else
                Text(
                  context.tr('cancelled').toUpperCase(),
                  style: typography.body.xs3.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.mutedForeground,
                  ),
                ),
              const SizedBox(height: 16),
              Divider(
                  height: 1, color: colors.border.withValues(alpha: 0.6)),
              const SizedBox(height: 8),

              // Info rows — plain
              _row(context, HugeIcons.strokeRoundedUser, context.tr('tenant'),
                  tenant?['full_name'] ??
                      tenant?['user']?['full_name'] ??
                      context.tr('unknown')),
              _row(context, HugeIcons.strokeRoundedDoor01,
                  context.tr('unit'),
                  unit?['name'] ?? unit?['unit_number'] ?? 'N/A'),
              _row(context, HugeIcons.strokeRoundedCalendar01,
                  context.tr('submitted'), createdAt),
              const SizedBox(height: 8),
              Divider(
                  height: 1, color: colors.border.withValues(alpha: 0.6)),
              const SizedBox(height: 16),

              // Description
              Text(
                context.tr('description').toUpperCase(),
                style: typography.body.xs3.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                req['description'] ??
                    context.tr('no_description_provided'),
                style: typography.body.sm.copyWith(
                  color: colors.foreground,
                  height: 1.55,
                ),
              ),
              if (req['landlord_notes'] != null) ...[
                const SizedBox(height: 16),
                Text(
                  context.tr('landlord_notes').toUpperCase(),
                  style: typography.body.xs3.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  req['landlord_notes'],
                  style: typography.body.xs2.copyWith(
                    color: colors.mutedForeground,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Update status
              Text(
                context.tr('update_status').toUpperCase(),
                style: typography.body.xs3.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final opt in statusOptions)
                    FButton(
                      variant:
                          _selectedStatus == opt.$1 ? .primary : .outline,
                      size: .xs,
                      mainAxisSize: MainAxisSize.min,
                      onPress: () =>
                          setState(() => _selectedStatus = opt.$1),
                      child: Text(opt.$2),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              FTextField.multiline(
                control: .managed(controller: _notesController),
                label: Text(context.tr('response_notes')),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: context.tr('update_status'),
                isLoading: _isLoading,
                onPressed: () => _updateStatus(id, _selectedStatus!),
              ),
              const SizedBox(height: 12),
              if (req['resolved_at'] != null)
                Center(
                  child: Text(
                    context.tr('resolved_on').replaceAll(
                        '{0}',
                        DateFormat('dd MMM yyyy, HH:mm').format(
                            DateTime.tryParse(
                                    req['resolved_at'].toString()) ??
                                DateTime.now())),
                    style: typography.body.xs2
                        .copyWith(color: const Color(0xFF16A34A)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _stepper(BuildContext context, int current) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final steps = [
      context.tr('open'),
      context.tr('in_progress'),
      context.tr('resolved'),
    ];

    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: i <= current
                      ? colors.primary
                      : colors.secondary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: i < current
                      ? HugeIcon(
                          icon: HugeIcons.strokeRoundedTick01,
                          size: 12,
                          color: colors.primaryForeground,
                        )
                      : Text(
                          '${i + 1}',
                          style: typography.body.xs3.copyWith(
                            fontWeight: FontWeight.w700,
                            color: i <= current
                                ? colors.primaryForeground
                                : colors.mutedForeground,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[i],
                style: typography.body.xs3.copyWith(
                  fontWeight:
                      i <= current ? FontWeight.w700 : FontWeight.w400,
                  color: i <= current
                      ? colors.foreground
                      : colors.mutedForeground,
                ),
              ),
            ],
          ),
          if (i < steps.length - 1)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Container(
                  height: 1.5,
                  color: i < current
                      ? colors.primary
                      : colors.border.withValues(alpha: 0.6),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _pill(BuildContext context, String label, Color color) {
    final typography = context.theme.typography;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: context.theme.style.borderRadius.pill,
      ),
      child: Text(
        label.replaceAll('_', ' ').toUpperCase(),
        style: typography.body.xs3.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: color,
        ),
      ),
    );
  }

  Widget _row(BuildContext context, List<List<dynamic>> icon, String label,
      String value) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          HugeIcon(icon: icon, size: 15, color: colors.mutedForeground),
          const SizedBox(width: 10),
          Text(
            label,
            style:
                typography.body.xs2.copyWith(color: colors.mutedForeground),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  typography.body.xs2.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
