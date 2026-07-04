import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';

class RecordPaymentScreen extends StatelessWidget {
  const RecordPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Payment'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const AppTextField(label: 'Tenant', hint: 'Select tenant'),
            const SizedBox(height: 16),
            const AppTextField(label: 'Amount', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            const AppTextField(label: 'Payment Date', hint: 'YYYY-MM-DD'),
            const SizedBox(height: 24),
            PrimaryButton(text: 'Save Payment', onPressed: () => context.pop()),
          ],
        ),
      ),
    );
  }
}
