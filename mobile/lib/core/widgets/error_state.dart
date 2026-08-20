import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onAction;
  final String actionLabel;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.onAction,
    this.actionLabel = 'Continue',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lowerMsg = message.toLowerCase();

    // Determine error type
    final isSubscriptionError = lowerMsg.contains('subscription') ||
        lowerMsg.contains('inactive or expired') ||
        lowerMsg.contains('renew to continue');
    final isKycError = lowerMsg.contains('kyc') ||
        lowerMsg.contains('verification is required');
    final isOrgError = lowerMsg.contains('organization') &&
        lowerMsg.contains('inactive');
    final isSetupError = isSubscriptionError || isKycError || isOrgError;
    final isNetworkError = lowerMsg.contains('connection') ||
        lowerMsg.contains('internet') ||
        lowerMsg.contains('timeout') ||
        lowerMsg.contains('connect to server');
    final isNotFound = lowerMsg.contains('not found');

    // Pick icon and colors based on error type
    IconData icon;
    Color iconColor;
    Color bgColor;
    String title;

    if (isSetupError) {
      icon = Icons.lock_outline;
      iconColor = AppColors.warning;
      bgColor = AppColors.warning.withValues(alpha: 0.1);
      if (isKycError) {
        title = 'Verification Required';
      } else if (isSubscriptionError) {
        title = 'Subscription Required';
      } else {
        title = 'Setup Required';
      }
    } else if (isNetworkError) {
      icon = Icons.cloud_off_rounded;
      iconColor = AppColors.textLight;
      bgColor = AppColors.textLight.withValues(alpha: 0.1);
      title = 'Connection Error';
    } else if (isNotFound) {
      icon = Icons.search_off_rounded;
      iconColor = AppColors.textLight;
      bgColor = AppColors.textLight.withValues(alpha: 0.1);
      title = 'Not Found';
    } else {
      icon = Icons.error_outline_rounded;
      iconColor = AppColors.error;
      bgColor = AppColors.error.withValues(alpha: 0.1);
      title = 'Something Went Wrong';
    }

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: iconColor),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : AppColors.textLight,
                  height: 1.5,
                ),
              ),
              if (onAction != null) ...[
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: onAction,
                  icon: Icon(isSetupError ? Icons.arrow_forward_rounded : Icons.refresh_rounded, size: 18),
                  label: Text(
                    actionLabel,
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.35),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
              if (onRetry != null) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(
                    'Retry',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
