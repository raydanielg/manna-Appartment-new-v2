import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/contracts_provider.dart';

class ContractSignScreen extends ConsumerStatefulWidget {
  const ContractSignScreen({super.key});

  @override
  ConsumerState<ContractSignScreen> createState() => _ContractSignScreenState();
}

class _ContractSignScreenState extends ConsumerState<ContractSignScreen> {
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
        const SnackBar(content: Text('Please sign first'), backgroundColor: AppColors.error),
      );
      return;
    }
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    if (id.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final bytes = await _controller.toPngBytes() ?? Uint8List(0);
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/signature_$id.png';
      await File(path).writeAsBytes(bytes);

      final result = await ref.read(contractsRepositoryProvider).signContract(id, path);
      final pdfUrl = result['pdf_url']?.toString();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contract signed successfully'), backgroundColor: AppColors.success),
        );
      }
      if (pdfUrl != null && pdfUrl.isNotEmpty) {
        await _downloadAndOpen(id);
      }
      if (context.mounted && context.canPop()) context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signing failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadAndOpen(String id) async {
    try {
      final path = await ref.read(contractsRepositoryProvider).downloadPdf(id);
      await OpenFilex.open(path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open PDF: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Sign Contract', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.draw_outlined, color: AppColors.info, size: 24),
                ),
                const SizedBox(height: 14),
                Text(
                  'Draw Your Signature',
                  style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                Text(
                  'Use your finger to sign inside the box below. This will be applied to the contract as your legal signature.',
                  style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textLight),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Signature(
                  controller: _controller,
                  backgroundColor: Colors.white,
                  height: MediaQuery.of(context).size.height * 0.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => _controller.clear(),
                icon: const Icon(Icons.refresh, size: 18, color: AppColors.error),
                label: Text('Clear', style: GoogleFonts.nunito(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              text: 'Sign & Download PDF',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }
}
