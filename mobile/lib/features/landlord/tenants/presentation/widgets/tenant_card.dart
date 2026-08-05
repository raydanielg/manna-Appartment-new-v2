import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/status_badge.dart';

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
    final userData = tenant['user'] as Map<String, dynamic>?;
    final name = userData?['full_name'] ?? userData?['name'] ?? tenant['full_name'] ?? tenant['name'] ?? 'Unknown Tenant';
    final phone = userData?['phone'] ?? tenant['phone'] ?? 'No phone';
    final unit = tenant['unit']?['name'] ?? tenant['unit']?['unit_number'] ?? tenant['unit_name'] ?? 'No unit assigned';
    final status = (tenant['status'] ?? 'active').toString().toLowerCase();
    final balanceDue = _parseAmount(tenant['balance_due']);
    final tenantId = tenant['id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('/landlord/tenants/$tenantId'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'T',
                    style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900, color: const Color(0xFF2563EB)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone_iphone_rounded, size: 14, color: Color(0xFF6B7280)),
                        const SizedBox(width: 6),
                        Text(
                          phone,
                          style: GoogleFonts.nunito(fontSize: 13, color: const Color(0xFF6B7280), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.meeting_room_rounded, size: 12, color: Color(0xFF4B5563)),
                          const SizedBox(width: 4),
                          Text(
                            unit,
                            style: GoogleFonts.nunito(fontSize: 11, color: const Color(0xFF4B5563), fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusBadge(status),
                  if (balanceDue > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'TZS ${balanceDue.toStringAsFixed(0)}',
                      style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFFEF4444)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10, 
          fontWeight: FontWeight.black, 
          color: isActive ? const Color(0xFF166534) : const Color(0xFFB91C1C),
          letterSpacing: 0.5
        ),
      ),
    );
  }
}
