import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';

class SmsBroadcastScreen extends StatelessWidget {
  const SmsBroadcastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send SMS Broadcast'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const AppTextField(label: 'Recipients', hint: 'All tenants / Select group'),
            const SizedBox(height: 16),
            const AppTextField(label: 'Message', hint: 'Type your message here'),
            const SizedBox(height: 24),
            PrimaryButton(text: 'Send Broadcast', onPressed: () => context.pop()),
          ],
        ),
      ),
    );
  }
}
