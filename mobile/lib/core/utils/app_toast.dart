import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';

/// Displays animated Forui toasts.
///
/// Falls back to a plain [SnackBar] when the given context is not under an
/// [FToaster] (e.g. widgets mounted outside the app shell).
class AppToast {
  static void show(BuildContext context, String message, {bool isError = false}) =>
      isError ? error(context, message) : success(context, message);

  static void success(BuildContext context, String message) => _show(
        context,
        message,
        variant: .primary,
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedCheckmarkCircle02,
          size: null,
          color: Color(0xFF16A34A),
        ),
      );

  static void error(BuildContext context, String message) => _show(
        context,
        message,
        variant: .destructive,
        icon: const HugeIcon(icon: HugeIcons.strokeRoundedAlert02, size: null),
      );

  static void warning(BuildContext context, String message) => _show(
        context,
        message,
        variant: .primary,
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedAlert02,
          size: null,
          color: Color(0xFFD97706),
        ),
      );

  static void info(BuildContext context, String message) => _show(
        context,
        message,
        variant: .primary,
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedInformationCircle,
          size: null,
          color: context.theme.colors.primary,
        ),
      );

  static void _show(
    BuildContext context,
    String message, {
    required FToastVariant variant,
    required Widget icon,
  }) {
    if (context.findAncestorStateOfType<FToasterState>() == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    showFToast(
      context: context,
      variant: variant,
      icon: icon,
      title: Text(message),
      alignment: FToastAlignment.topCenter,
      duration: const Duration(seconds: 4),
    );
  }
}
