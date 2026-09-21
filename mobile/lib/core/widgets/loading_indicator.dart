import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Themed loading state — Forui circular progress + optional message.
/// Used across screens as the FutureProvider/AsyncValue `loading` case.
class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    final colors = context.theme.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FCircularProgress(),
          if (message != null) ...[
            const SizedBox(height: 14),
            Text(
              message!,
              style: typography.body.xs2
                  .copyWith(color: colors.mutedForeground),
            ),
          ],
        ],
      ),
    );
  }
}
