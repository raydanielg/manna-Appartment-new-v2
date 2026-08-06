import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';

class AppUpdateChecker {
  /// Checks for an in-app update on Android using the Play Store API.
  /// Returns true if app can proceed, false if an update is required.
  /// On non-Android platforms, always returns true.
  static Future<bool> checkForUpdate(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    try {
      final info = await InAppUpdate.checkForUpdate();
      if (!context.mounted) return true;

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        final shouldProceed = await _showUpdateDialog(context, info);
        if (shouldProceed) return true;
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('In-app update check failed: $e');
      return true;
    }
  }

  /// Shows a clean update dialog and handles the update flow.
  /// Returns true if user can proceed (flexible update completed or skipped),
  /// false if immediate update is required and not completed.
  static Future<bool> _showUpdateDialog(BuildContext context, AppUpdateInfo info) async {
    if (info.immediateUpdateAllowed) {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _UpdateDialog(
          title: 'Update Required',
          message: 'A new version of Manna Apartment is available. Please update to continue using the app.',
          isRequired: true,
        ),
      );

      if (result == true) {
        try {
          await InAppUpdate.performImmediateUpdate();
          return false;
        } catch (e) {
          debugPrint('Immediate update failed: $e');
          return false;
        }
      }
      return false;
    }

    if (info.flexibleUpdateAllowed) {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _UpdateDialog(
          title: 'Update Available',
          message: 'A new version of Manna Apartment is available with improvements and bug fixes.',
          isRequired: false,
        ),
      );

      if (result == true) {
        try {
          await InAppUpdate.startFlexibleUpdate();
          await InAppUpdate.completeFlexibleUpdate();
        } catch (e) {
          debugPrint('Flexible update failed: $e');
        }
      }
      return true;
    }

    return true;
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

class _UpdateDialog extends StatelessWidget {
  final String title;
  final String message;
  final bool isRequired;

  const _UpdateDialog({
    required this.title,
    required this.message,
    required this.isRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.system_update, color: Color(0xFF2563EB), size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: GoogleFonts.nunito(fontSize: 14, color: const Color(0xFF6B7280), height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (!isRequired)
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Later',
                        style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF6B7280)),
                      ),
                    ),
                  ),
                if (!isRequired) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Update Now',
                      style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
