import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/maintenance_provider.dart';

class SubmitMaintenanceScreen extends ConsumerStatefulWidget {
  const SubmitMaintenanceScreen({super.key});

  @override
  ConsumerState<SubmitMaintenanceScreen> createState() => _SubmitMaintenanceScreenState();
}

class _SubmitMaintenanceScreenState extends ConsumerState<SubmitMaintenanceScreen> {
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('please_describe_issue')), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(tenantMaintenanceRepositoryProvider).submitRequest({
        'description': _descriptionController.text.trim(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('maintenance_submitted')), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
        );
        ref.invalidate(myMaintenanceRequestsProvider);
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        String msg = 'Failed: $e';
        if (e is DioException && e.response?.statusCode == 404) {
          msg = context.tr('no_unit_assigned_msg');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(context.tr('submit_maintenance'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.build_outlined, color: AppColors.warning, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('report_issue'), style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        const SizedBox(height: 2),
                        Text(context.tr('describe_problem'), style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(context.tr('description'), style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 6,
                minLines: 4,
                style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textDark, height: 1.5),
                decoration: InputDecoration(
                  hintText: context.tr('describe_issue_hint'),
                  hintStyle: GoogleFonts.nunito(fontSize: 13, color: AppColors.textLight, height: 1.5),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              text: context.tr('submit_request'),
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
