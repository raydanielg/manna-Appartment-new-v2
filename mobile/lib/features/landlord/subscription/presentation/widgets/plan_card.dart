import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/primary_button.dart';

class PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isCurrent;
  final VoidCallback? onSelect;
  const PlanCard({super.key, required this.plan, this.isCurrent = false, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final features = (plan['features_json'] as List<dynamic>? ?? (plan['features'] as List<dynamic>? ?? []));
    final billingCycle = plan['billing_cycle']?.toString() ?? 'monthly';
    final isTrial = billingCycle == 'trial';
    final price = plan['price'] ?? 0;
    final propertyLimit = plan['property_limit'] ?? 0;
    final unitLimit = plan['unit_limit'] ?? 0;
    final smsIncluded = plan['sms_included'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: isCurrent
          ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.primary, width: 2))
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(plan['name'] ?? 'Plan', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark)),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                    child: const Text('CURRENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isTrial ? 'Free Trial' : 'TZS $price/${billingCycle.replaceAll('ly', '')}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _LimitItem(label: 'Properties', value: propertyLimit == 0 ? 'Unlimited' : propertyLimit.toString()),
                  _LimitItem(label: 'Units', value: unitLimit == 0 ? 'Unlimited' : unitLimit.toString()),
                  _LimitItem(label: 'SMS', value: smsIncluded.toString()),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                const SizedBox(width: 8),
                Expanded(child: Text(f.toString(), style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : AppColors.textDark))),
              ]),
            )),
            const SizedBox(height: 16),
            if (!isCurrent) PrimaryButton(text: isTrial ? 'Start Free Trial' : 'Select Plan', onPressed: onSelect ?? () {}),
          ],
        ),
      ),
    );
  }
}

class _LimitItem extends StatelessWidget {
  final String label;
  final String value;
  const _LimitItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : AppColors.textLight)),
      ],
    );
  }
}
