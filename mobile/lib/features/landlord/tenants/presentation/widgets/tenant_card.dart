import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../../core/localization/app_localizations.dart';

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
    final radii = context.theme.style.borderRadius;

    final userData = tenant['user'] as Map<String, dynamic>?;
    final name = userData?['full_name'] ??
        userData?['name'] ??
        tenant['full_name'] ??
        tenant['name'] ??
        'Unknown Tenant';
    final phone = userData?['phone'] ?? tenant['phone'] ?? 'No phone';
    final unit = tenant['unit'] as Map<String, dynamic>?;
    final unitName = unit?['name'] ??
        unit?['unit_number'] ??
        tenant['unit_name'] ??
        'No unit';
    final propertyName = unit?['property']?['name'] ??
        tenant['property_name'] ??
        context.tr('no_property_assigned');
    final status = (tenant['status'] ?? 'active').toString().toLowerCase();
    final balanceDue = _parseAmount(tenant['balance_due']);
    final tenantId = tenant['id']?.toString() ?? '';
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'T';

    final isActive = status == 'active';
    final badgeBg = isActive
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFEE2E2);
    final badgeFg = isActive
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FTappable(
        onPress: () => context.push('/landlord/tenants/$tenantId'),
        child: FCard(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: radii.md,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: typography.display.sm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.body.sm.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: radii.pill,
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: badgeFg,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedCall,
                          size: 13,
                          color: colors.mutedForeground,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          phone,
                          style: typography.body.xs2.copyWith(
                            color: colors.mutedForeground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedBuilding03,
                          size: 12,
                          color: colors.mutedForeground,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            propertyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.body.xs3.copyWith(
                              color: colors.mutedForeground,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '•',
                            style: TextStyle(
                              fontSize: 10,
                              color: colors.mutedForeground,
                            ),
                          ),
                        ),
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedDoor01,
                          size: 12,
                          color: colors.mutedForeground,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            unitName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.body.xs3.copyWith(
                              color: colors.mutedForeground,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (balanceDue > 0) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.error.withValues(alpha: 0.1),
                          borderRadius: radii.xs,
                        ),
                        child: Text(
                          'Due: TZS ${balanceDue.toStringAsFixed(0)}',
                          style: typography.body.xs3.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  size: 16,
                  color: colors.mutedForeground.withValues(alpha: 0.6),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
