import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? color;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final bg = backgroundColor ?? color;

    return FButton(
      // No-op while loading so the button keeps its full color instead of dimming.
      onPress: isLoading ? () {} : onPressed,
      size: .lg,
      style: bg == null
          ? const .context()
          : .delta(
              decoration: .delta([
                .all(.shapeDelta(color: bg)),
                .match({.hovered, .pressed}, .shapeDelta(color: colors.hover(bg))),
                .match({.selected}, .shapeDelta(color: colors.hover(bg))),
                .match({.disabled}, .shapeDelta(color: colors.disable(bg))),
                .exact({.selected.and(.disabled)}, .shapeDelta(color: colors.disable(colors.hover(bg)))),
              ]),
            ),
      prefix: isLoading ? null : icon,
      builder: isLoading
          ? (_, _, _, _, progressStyle, child) => Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FCircularProgress(style: progressStyle),
                const SizedBox(width: 10),
                child!,
              ],
            )
          : FButton.defaultContentBuilder,
      child: Text(
        text,
        style: foregroundColor != null ? TextStyle(color: foregroundColor) : null,
      ),
    );
  }
}
