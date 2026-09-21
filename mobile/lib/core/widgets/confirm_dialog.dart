import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      content: Text(message),
      actions: [
        FButton(
          variant: .ghost,
          size: .sm,
          mainAxisSize: .min,
          onPress: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        FButton(
          variant: isDestructive ? .destructive : .primary,
          size: .sm,
          mainAxisSize: .min,
          onPress: () => Navigator.of(context).pop(true),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
