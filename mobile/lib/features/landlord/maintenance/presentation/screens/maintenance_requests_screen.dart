import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/maintenance_provider.dart';

class MaintenanceRequestsScreen extends ConsumerStatefulWidget {
  const MaintenanceRequestsScreen({super.key});

  @override
  ConsumerState<MaintenanceRequestsScreen> createState() =>
      _MaintenanceRequestsScreenState();
}

class _MaintenanceRequestsScreenState
    extends ConsumerState<MaintenanceRequestsScreen> {
  String _searchQuery = '';
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(maintenanceRequestsProvider);
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('maintenance'),
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
        actions: [
          FButton.icon(
            variant: _filterStatus != 'all' ? .secondary : .ghost,
            size: .sm,
            onPress: () => _showFilterSheet(context),
            child: const HugeIcon(
                icon: HugeIcons.strokeRoundedFilterHorizontal, size: null),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: FTextField(
              control: .managed(
                onChange: (v) =>
                    setState(() => _searchQuery = v.text.toLowerCase()),
              ),
              hint: context.tr('search_requests'),
              prefixBuilder: (context, style, variants) =>
                  FTextField.prefixIconBuilder(
                    context,
                    style,
                    variants,
                    const HugeIcon(
                        icon: HugeIcons.strokeRoundedSearch01, size: null),
                  ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(maintenanceRequestsProvider),
              color: colors.primary,
              child: requestsAsync.when(
                loading: () => const LoadingIndicator(),
                error: (e, _) => ErrorState(
                  message: AppError.getMessage(e),
                  onRetry: () =>
                      ref.invalidate(maintenanceRequestsProvider),
                ),
                data: (requests) {
                  final filtered = requests.where((req) {
                    final title =
                        (req['title'] ?? '').toString().toLowerCase();
                    final tenant = (req['tenant']?['full_name'] ?? '')
                        .toString()
                        .toLowerCase();
                    final matchesSearch = title.contains(_searchQuery) ||
                        tenant.contains(_searchQuery);
                    final status = (req['status'] ?? 'open').toString();
                    final matchesStatus = _filterStatus == 'all' ||
                        status == _filterStatus;
                    return matchesSearch && matchesStatus;
                  }).toList();

                  if (filtered.isEmpty) {
                    return EmptyState(
                        message:
                            context.tr('no_maintenance_requests_landlord'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _RequestRow(req: filtered[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterSheet(BuildContext context) async {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    await showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String status = _filterStatus;
        return StatefulBuilder(
          builder: (context, setSheet) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('filter'),
                      style: typography.body.md
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('status').toUpperCase(),
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
                        for (final (label, v) in [
                          (context.tr('all'), 'all'),
                          (context.tr('open'), 'open'),
                          (context.tr('in_progress'), 'in_progress'),
                          (context.tr('resolved'), 'resolved'),
                          (context.tr('cancelled'), 'cancelled'),
                        ])
                          FButton(
                            variant: status == v ? .primary : .outline,
                            size: .xs,
                            mainAxisSize: MainAxisSize.min,
                            onPress: () => setSheet(() => status = v),
                            child: Text(label),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    FButton(
                      variant: .primary,
                      onPress: () {
                        setState(() => _filterStatus = status);
                        Navigator.pop(context);
                      },
                      child: Text(context.tr('apply')),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _RequestRow extends StatelessWidget {
  final Map<String, dynamic> req;
  const _RequestRow({required this.req});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final status = (req['status'] ?? 'open').toString();
    final createdAt = req['created_at'] != null
        ? DateFormat('dd MMM yyyy').format(
            DateTime.tryParse(req['created_at'].toString()) ?? DateTime.now())
        : '-';
    final statusColor = switch (status) {
      'open' => const Color(0xFFD97706),
      'in_progress' => const Color(0xFF0EA5E9),
      'resolved' => const Color(0xFF16A34A),
      _ => colors.mutedForeground,
    };

    return FTappable(
      onPress: () => context.push('/landlord/maintenance/${req['id']}'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      req['title'] ?? context.tr('request'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.sm
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    status.replaceAll('_', ' ').toUpperCase(),
                    style: typography.body.xs3.copyWith(
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                [
                  req['tenant']?['full_name'] ?? context.tr('unknown'),
                  '${context.tr('unit')} ${req['unit']?['name'] ?? req['unit']?['unit_number'] ?? 'N/A'}',
                  createdAt,
                ].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.body.xs3
                    .copyWith(color: colors.mutedForeground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
