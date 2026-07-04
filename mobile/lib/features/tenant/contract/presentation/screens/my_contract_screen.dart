import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyContractScreen extends StatelessWidget {
  const MyContractScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Contract'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: const Center(child: Text('My Contract Details')),
    );
  }
}

