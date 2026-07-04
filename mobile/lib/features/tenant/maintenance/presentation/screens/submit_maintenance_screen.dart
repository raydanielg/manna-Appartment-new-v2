import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';

class SubmitMaintenanceScreen extends StatelessWidget {
  const SubmitMaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Maintenance'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const AppTextField(label: 'Title', hint: 'e.g. Leaking tap'),
            const SizedBox(height: 16),
            const AppTextField(label: 'Description', hint: 'Describe the issue'),
            const SizedBox(height: 24),
            PrimaryButton(text: 'Submit Request', onPressed: () => context.pop()),
          ],
        ),
      ),
    );
  }
}
