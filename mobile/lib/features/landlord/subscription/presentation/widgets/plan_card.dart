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
    final planName = plan['name']?.toString() ?? 'Plan';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent ? AppColors.primary : const Color(0xFFE5E7EB),
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: icon + name + current badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: (isTrial ? AppColors.gold : AppColors.primary).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isTrial ? Icons.auto_awesome_rounded : Icons.workspace_premium_rounded,
                          color: isTrial ? AppColors.goldDark : AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          planName,
                          style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 12, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          'CURRENT',
                          style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.success, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isTrial ? 'FREE' : 'TZS ${price.toStringAsFixed(0)}',
                  style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary),
                ),
                if (!isTrial) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '/ ${billingCycle.replaceAll('ly', '')}',
                      style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textLight),
                    ),
                  ),
                ],
                if (isTrial) ...[
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '3 days',
                      style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textLight),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 20),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFE5E7EB), Colors.transparent],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Limits row
            Row(
              children: [
                _LimitItem(icon: Icons.home_work_rounded, label: 'Properties', value: propertyLimit == 0 ? 'Unlimited' : propertyLimit.toString()),
                _divider(),
                _LimitItem(icon: Icons.apartment_rounded, label: 'Units', value: unitLimit == 0 ? 'Unlimited' : unitLimit.toString()),
                _divider(),
                _LimitItem(icon: Icons.sms_rounded, label: 'SMS', value: smsIncluded.toString()),
              ],
            ),

            // Features
            if (features.isNotEmpty) ...[
              const SizedBox(height: 18),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFE5E7EB), Colors.transparent],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ...features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, size: 12, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _formatFeature(f.toString()),
                        style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              )),
            ],

            const SizedBox(height: 20),
            if (!isCurrent)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onSelect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isTrial ? AppColors.primary : AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _divider() => Container(width: 1, height: 36, color: const Color(0xFFE5E7EB), margin: const EdgeInsets.symmetric(horizontal: 8));

  String _formatFeature(String f) {
    return f
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

class _LimitItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _LimitItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textLight)),
        ],
      ),
    );
  }
}
