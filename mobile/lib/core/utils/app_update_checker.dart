import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

class AppUpdateChecker {
  /// Checks for an in-app update on Android using the Play Store API.
  /// On other platforms this is a no-op.
  static Future<void> checkForUpdate(BuildContext context) async {
    if (!Platform.isAndroid) return;

    try {
      final info = await InAppUpdate.checkForUpdate();
      if (!context.mounted) return;

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (info.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        } else if (info.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
        }
      }
    } catch (e) {
      // Silently ignore: Play Store may not be available during development.
      debugPrint('In-app update check failed: $e');
    }
  }

  /// Completes a pending flexible update if one is downloaded.
  static Future<void> completeFlexibleUpdate() async {
    if (!Platform.isAndroid) return;
    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e) {
      debugPrint('Complete flexible update failed: $e');
    }
  }
}
