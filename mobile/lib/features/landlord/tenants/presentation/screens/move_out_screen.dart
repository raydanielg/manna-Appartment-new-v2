import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/primary_button.dart';

class MoveOutScreen extends StatelessWidget {
  const MoveOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Move Out Tenant'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber, size: 48, color: AppColors.warning),
            const SizedBox(height: 16),
            const Text('Confirm Move Out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('This will mark the tenant as moved out. The unit will become vacant. This action cannot be undone.'),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Confirm Move Out',
              color: AppColors.error,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tenant moved out'), backgroundColor: AppColors.warning, behavior: SnackBarBehavior.floating),
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
