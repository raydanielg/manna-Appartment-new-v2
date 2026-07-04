import 'package:flutter/material.dart';

class LanguageToggleScreen extends StatelessWidget {
  const LanguageToggleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Language')),
      body: ListView(
        children: [
          ListTile(title: const Text('English'), onTap: () {}),
          ListTile(title: const Text('Swahili'), onTap: () {}),
        ],
      ),
    );
  }
}
