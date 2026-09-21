import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../data/models/property_model.dart';

class PropertyGridCard extends StatelessWidget {
  final PropertyModel property;
  const PropertyGridCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final radii = context.theme.style.borderRadius;

    return FTappable(
      onPress: () => context.push('/landlord/properties/${property.id}'),
      child: FCard(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: radii.md,
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedBuilding03,
                        size: 17,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      borderRadius: radii.xs,
                    ),
                    child: Text(
                      _capitalize(property.type ?? 'N/A'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.xs3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.secondaryForeground,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                property.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: typography.body.xs2
                    .copyWith(fontWeight: FontWeight.w700, height: 1.3),
              ),
              const Spacer(),
              Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedLocation01,
                    size: 11,
                    color: colors.mutedForeground,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      property.address ?? 'No location',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.xs3
                          .copyWith(color: colors.mutedForeground),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
