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
    final radii = context.theme.style.borderRadius;

    final tenantName = contract['tenant']?['full_name'] ??
        contract['tenant']?['user']?['full_name'] ??
        context.tr('unknown');
    final unitName =
        contract['unit']?['name'] ?? contract['unit']?['unit_number'] ?? 'N/A';
    final startDate = _formatDate(contract['start_date']);
    final endDate = _formatDate(contract['end_date']);
    final status = (contract['status'] ?? 'active').toString();
    final contractId = contract['id']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FTappable(
        onPress: () => context.push('/landlord/contracts/$contractId'),
        child: FCard(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: radii.md,
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedFile01,
                          size: 20,
                          color: colors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                          const SizedBox(height: 2),
                          Text(
                            '${context.tr('unit')}: $unitName',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.body.xs2
                                .copyWith(color: colors.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                    _statusPill(context, colors, typography, status),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.secondary.withValues(alpha: 0.5),
                    borderRadius: radii.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _dateItem(
                          colors,
                          typography,
                          HugeIcons.strokeRoundedCalendarAdd01,
                          context.tr('start_label'),
                          startDate,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        color: colors.border,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dateItem(
                          colors,
                          typography,
                          HugeIcons.strokeRoundedCalendarMinus01,
                          context.tr('end_label'),
                          endDate,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                FButton(
                  variant: .ghost,
                  size: .sm,
                  prefix: const HugeIcon(
                      icon: HugeIcons.strokeRoundedDownload04, size: null),
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
                  child: Text(context.tr('download_pdf')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusPill(
      BuildContext context, FColors colors, FTypography typography, String status) {
    final positive = status == 'active';
    final color = positive ? const Color(0xFF16A34A) : colors.mutedForeground;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: positive
            ? const Color(0xFF16A34A).withValues(alpha: 0.1)
            : colors.secondary,
        borderRadius: context.theme.style.borderRadius.pill,
      ),
      child: Text(
        status.toUpperCase(),
        style: typography.body.xs3.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: color,
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

  Widget _dateItem(
    FColors colors,
    FTypography typography,
    List<List<dynamic>> icon,
    String label,
    String date,
  ) {
    return Row(
      children: [
        HugeIcon(icon: icon, size: 15, color: colors.mutedForeground),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: typography.body.xs3.copyWith(color: colors.mutedForeground),
              ),
              Text(
                date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.body.xs2.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
