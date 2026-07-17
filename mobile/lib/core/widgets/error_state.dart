import 'package:flutter/material.dart';
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
    final isSetupError = message.toLowerCase().contains('kyc') ||
        message.toLowerCase().contains('subscription') ||
        message.toLowerCase().contains('organization');

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: (isSetupError ? AppColors.warning : AppColors.error).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSetupError ? Icons.lock_outline : Icons.error_outline,
                size: 36,
                color: isSetupError ? AppColors.warning : AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSetupError ? 'Setup Required' : 'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : AppColors.textLight),
            ),
            if (onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(actionLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }
}
