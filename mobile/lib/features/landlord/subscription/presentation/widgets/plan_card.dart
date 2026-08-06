import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isCurrent;
  final VoidCallback? onSelect;
  const PlanCard({super.key, required this.plan, this.isCurrent = false, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final features = (plan['features_json'] as List<dynamic>? ?? (plan['features'] as List<dynamic>? ?? []));
    final billingCycle = plan['billing_cycle']?.toString() ?? 'monthly';
    final isTrial = billingCycle == 'trial';
    final price = (plan['price'] is num
        ? (plan['price'] as num).toDouble()
        : double.tryParse(plan['price']?.toString() ?? '0') ?? 0.0);
    final propertyLimit = plan['property_limit'] ?? 0;
    final unitLimit = plan['unit_limit'] ?? 0;
    final smsIncluded = plan['sms_included'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent ? AppColors.primary : const Color(0xFFE5E7EB),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan['name'] ?? 'Plan',
                  style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'CURRENT',
                      style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF166534), letterSpacing: 0.5),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isTrial ? 'Free Trial' : 'TZS ${price.toStringAsFixed(0)}/${billingCycle.replaceAll('ly', '')}',
              style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
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
            const SizedBox(height: 14),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(f.toString(), style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark))),
              ]),
            )),
            const SizedBox(height: 18),
            if (!isCurrent)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onSelect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    isTrial ? 'Start Free Trial' : 'Select Plan',
                    style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
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
    return Column(
      children: [
        Text(value, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textLight)),
      ],
    );
  }
}
