import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/admin_landlords_provider.dart';

class AdminLandlordDetailScreen extends ConsumerStatefulWidget {
  const AdminLandlordDetailScreen({super.key});

  @override
  ConsumerState<AdminLandlordDetailScreen> createState() => _AdminLandlordDetailScreenState();
}

class _AdminLandlordDetailScreenState extends ConsumerState<AdminLandlordDetailScreen> {
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String id, String status) async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(adminLandlordsRepositoryProvider);
      await repo.updateStatus(id, status, reason: _reasonController.text.trim());
      ref.invalidate(adminLandlordDetailProvider(id));
      ref.invalidate(adminLandlordsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $status'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateKyc(String id, String status) async {
    try {
      final repo = ref.read(adminLandlordsRepositoryProvider);
      await repo.updateKycStatus(id, status);
      ref.invalidate(adminLandlordDetailProvider(id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('KYC status updated'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    final landlordAsync = ref.watch(adminLandlordDetailProvider(id));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Landlord Details', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: landlordAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(adminLandlordDetailProvider(id))),
        data: (org) {
          final status = org['status'] ?? 'active';
          final owner = org['owner'];
          final kyc = org['kyc_status'] ?? 'pending';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(context, org, owner),
                const SizedBox(height: 20),
                Text('Status Actions', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Reason (for suspension/deactivation)',
                  controller: _reasonController,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: 'Activate',
                        color: AppColors.success,
                        isLoading: _isLoading && status != 'active',
                        onPressed: () => _updateStatus(id, 'active'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Suspend',
                        color: AppColors.warning,
                        isLoading: _isLoading && status != 'suspended',
                        onPressed: () => _updateStatus(id, 'suspended'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'Deactivate',
                    color: Colors.grey,
                    isLoading: _isLoading && status != 'deactivated',
                    onPressed: () => _updateStatus(id, 'deactivated'),
                  ),
                ),
                const SizedBox(height: 20),
                Text('KYC Actions', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                        onPressed: () => _updateKyc(id, 'approved'),
                        child: Text('Approve KYC', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        onPressed: () => _updateKyc(id, 'rejected'),
                        child: Text('Reject KYC', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (org['suspension_reason'] != null && org['suspension_reason'].toString().isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text('Reason: ${org['suspension_reason']}', style: GoogleFonts.nunito(color: AppColors.warning)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, Map<String, dynamic> org, Map<String, dynamic>? owner) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(org['business_name'] ?? 'Organization', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark)),
          const SizedBox(height: 12),
          _buildRow('Owner', owner?['full_name'] ?? 'N/A'),
          _buildRow('Phone', owner?['phone'] ?? 'N/A'),
          _buildRow('Email', owner?['email'] ?? 'N/A'),
          _buildRow('Status', (org['status'] ?? 'active').toString()),
          _buildRow('KYC', (org['kyc_status'] ?? 'pending').toString()),
          _buildRow('SMS Balance', (org['sms_balance'] ?? 0).toString()),
          _buildRow('Properties', (org['properties'] is List ? org['properties'].length : 0).toString()),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text('$label: ', style: GoogleFonts.nunito(fontSize: 13, color: isDark ? Colors.white60 : AppColors.textLight)),
          Expanded(child: Text(value, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark))),
        ],
      ),
    );
  }
}
