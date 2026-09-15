import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/contract_provider.dart';

class TenantContractSignScreen extends ConsumerStatefulWidget {
  const TenantContractSignScreen({super.key});

  @override
  ConsumerState<TenantContractSignScreen> createState() => _TenantContractSignScreenState();
}

class _TenantContractSignScreenState extends ConsumerState<TenantContractSignScreen> {
  final _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('please_draw_signature')), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final bytes = await _controller.toPngBytes() ?? Uint8List(0);
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/tenant_signature.png';
      await File(path).writeAsBytes(bytes);

      await ref.read(contractRepositoryProvider).signMyContract(path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('contract_signed_success')), backgroundColor: AppColors.success),
        );
      }
      ref.invalidate(myContractProvider);
      if (context.mounted && context.canPop()) context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('signing_failed').replaceAll('{0}', AppError.getMessage(e))), backgroundColor: AppColors.error),
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
        title: Text(context.tr('sign_contract'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('sign_contract_note'),
                    style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textLight, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Signature(
                        controller: _controller,
                        backgroundColor: const Color(0xFFFAFAFA),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _controller.clear(),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(context.tr('clear'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: PrimaryButton(
              text: context.tr('confirm_submit'),
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }
}
