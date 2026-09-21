import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class TenantCard extends StatelessWidget {
  final Map<String, dynamic> tenant;
  const TenantCard({super.key, required this.tenant});

  double _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    final userData = tenant['user'] as Map<String, dynamic>?;
    final name = userData?['full_name'] ??
        userData?['name'] ??
        tenant['full_name'] ??
        tenant['name'] ??
        'Unknown Tenant';
    final phone = userData?['phone'] ?? tenant['phone'] ?? '';
    final unit = tenant['unit'] as Map<String, dynamic>?;
    final unitName = unit?['name'] ??
        unit?['unit_number'] ??
        tenant['unit_name'] ??
        '';
    final balanceDue = _parseAmount(tenant['balance_due']);
    final tenantId = tenant['id']?.toString() ?? '';
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'T';

    return FTappable(
      onPress: () => context.push('/landlord/tenants/$tenantId'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colors.border.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Initial avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.secondary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.secondaryForeground,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.body.sm
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [
                      if (phone.isNotEmpty) phone,
                      if (unitName.isNotEmpty) unitName,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.body.xs3
                        .copyWith(color: colors.mutedForeground),
                  ),
                  if (balanceDue > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Due: TZS ${balanceDue.toStringAsFixed(0)}',
                      style: typography.body.xs3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              size: 16,
              color: colors.mutedForeground.withValues(alpha: 0.6),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
