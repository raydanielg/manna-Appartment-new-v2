import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../providers/contracts_provider.dart';

import 'package:manna_apartment/core/utils/app_toast.dart';

class ContractCard extends ConsumerWidget {
  final Map<String, dynamic> contract;
  const ContractCard({super.key, required this.contract});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    final tenantName = contract['tenant']?['full_name'] ??
        contract['tenant']?['user']?['full_name'] ??
        context.tr('unknown');
    final unitName =
        contract['unit']?['name'] ?? contract['unit']?['unit_number'] ?? 'N/A';
    final startDate = _formatDate(contract['start_date']);
    final endDate = _formatDate(contract['end_date']);
    final status = (contract['status'] ?? 'active').toString();
    final contractId = contract['id']?.toString() ?? '';
    final statusColor =
        status == 'active' ? const Color(0xFF16A34A) : colors.mutedForeground;

    return FTappable(
      onPress: () => context.push('/landlord/contracts/$contractId'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenantName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.sm
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${context.tr('unit')} $unitName · $startDate → $endDate',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.xs3
                          .copyWith(color: colors.mutedForeground),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    status.toUpperCase(),
                    style: typography.body.xs3.copyWith(
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FButton.icon(
                    variant: .ghost,
                    size: .sm,
                    onPress: () async {
                      try {
                        final path = await ref
                            .read(contractsRepositoryProvider)
                            .downloadPdf(contractId);
                        await OpenFilex.open(path);
                      } catch (e) {
                        if (context.mounted) {
                          AppToast.error(
                            context,
                            context.tr('download_failed_msg').replaceAll(
                                '{0}', AppError.getMessage(e)),
                          );
                        }
                      }
                    },
                    child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedDownload04, size: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    final dt = DateTime.tryParse(date.toString());
    if (dt == null) return date.toString();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
