import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Shows a Forui confirmation dialog. Returns true if confirmed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDestructive = false,
}) async {
  final result = await showFDialog<bool>(
    context: context,
    builder: (context, style, animation) => FDialog(
      animation: animation,
      builder: (context, style) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: style.titleTextStyle),
            const SizedBox(height: 8),
            Text(message, style: style.bodyTextStyle),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton(
                  variant: .outline,
                  size: .sm,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () => Navigator.pop(context, false),
                  child: Text(cancelText),
                ),
                const SizedBox(width: 8),
                FButton(
                  variant: isDestructive ? .destructive : .primary,
                  size: .sm,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () => Navigator.pop(context, true),
                  child: Text(confirmText),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}
