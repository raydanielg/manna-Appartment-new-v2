import 'dart:io';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:in_app_update/in_app_update.dart';
import '../storage/local_cache_service.dart';

class AppUpdateChecker {
  static const _lastCheckKey = 'last_update_check_ts';

  /// Checks for an in-app update on Android using the Play Store API.
  /// Throttled to once per day so it doesn't block every launch.
  /// Returns true if app can proceed, false if an update is required.
  /// On non-Android platforms, always returns true.
  static Future<bool> checkForUpdate(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    // Throttle — check at most once every 24h
    try {
      final last = await LocalCacheService.getString(_lastCheckKey);
      final lastTs = int.tryParse(last ?? '') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - lastTs < const Duration(hours: 24).inMilliseconds) {
        return true;
      }
      await LocalCacheService.setString(_lastCheckKey, now.toString());
    } catch (_) {}

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
  static Future<bool> _showUpdateDialog(
      BuildContext context, AppUpdateInfo info) async {
    final isRequired = info.immediateUpdateAllowed;

    final result = await showFDialog<bool>(
      context: context,
      barrierDismissible: !isRequired,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        builder: (context, style) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: context.theme.colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowUpRight01,
                    size: 26,
                    color: context.theme.colors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isRequired ? 'Update Required' : 'Update Available',
                style: style.titleTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isRequired
                    ? 'A new version of Manna Apartment is available. Please update to continue using the app.'
                    : 'A new version of Manna Apartment is available with improvements and bug fixes.',
                style: style.bodyTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FButton(
                variant: .primary,
                onPress: () => Navigator.pop(context, true),
                child: const Text('Update Now'),
              ),
              if (!isRequired) ...[
                const SizedBox(height: 8),
                FButton(
                  variant: .ghost,
                  size: .sm,
                  onPress: () => Navigator.pop(context, false),
                  child: const Text('Later'),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      if (isRequired) {
        try {
          await InAppUpdate.performImmediateUpdate();
        } catch (e) {
          debugPrint('Immediate update failed: $e');
        }
        return false;
      }
      try {
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
      } catch (e) {
        debugPrint('Flexible update failed: $e');
      }
      return true;
    }
    return !isRequired;
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
