import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/widgets/primary_button.dart';

class MoveOutScreen extends StatelessWidget {
  const MoveOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('move_out_tenant_title')), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber, size: 48, color: AppColors.warning),
            const SizedBox(height: 16),
            Text(context.tr('confirm_move_out_title'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(context.tr('confirm_move_out_desc')),
            const SizedBox(height: 24),
            PrimaryButton(
              text: context.tr('confirm_move_out_btn'),
              color: AppColors.error,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('tenant_moved_out')), backgroundColor: AppColors.warning, behavior: SnackBarBehavior.floating),
                );
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
