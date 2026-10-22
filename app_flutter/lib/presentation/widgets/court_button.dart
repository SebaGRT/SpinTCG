import 'package:flutter/material.dart';
import '../theme.dart';

enum ButtonVariant { primary, accent, secondary, ghost, onDark }

enum ButtonSize { lg, md, sm }

class CourtButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final IconData? iconRight;
  final bool full;

  const CourtButton(
    this.label, {
    super.key,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.icon,
    this.iconRight,
    this.full = false,
  });

  @override
  Widget build(BuildContext context) {
    final (height, radius, fontSize, padding) = switch (size) {
      ButtonSize.lg => (56.0, 16.0, 16.0, 24.0),
      ButtonSize.md => (48.0, 12.0, 15.0, 20.0),
      ButtonSize.sm => (40.0, 12.0, 14.0, 14.0),
    };
    final (
      Color background,
      Color foreground,
      Color? border,
    ) = onPressed == null
        ? (Court.disabled, Court.disabledText, null)
        : switch (variant) {
            ButtonVariant.primary => (Court.c800, Colors.white, null),
            ButtonVariant.accent => (Court.ball, Court.c900, null),
            ButtonVariant.secondary => (Colors.white, Court.c900, Court.line),
            ButtonVariant.ghost => (Colors.transparent, Court.c800, null),
            ButtonVariant.onDark => (
              Colors.white.withValues(alpha: 0.1),
              Colors.white,
              Colors.white.withValues(alpha: 0.2),
            ),
          };
    final iconSize = size == ButtonSize.sm ? 17.0 : 20.0;

    return SizedBox(
      height: height,
      width: full ? double.infinity : null,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: background,
          disabledForegroundColor: foreground,
          padding: EdgeInsets.symmetric(horizontal: padding),
          textStyle: display(fontSize, weight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: border == null ? BorderSide.none : BorderSide(color: border),
          ),
        ),
        child: Row(
          mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: iconSize),
              const SizedBox(width: 8),
            ],
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            if (iconRight != null) ...[
              const SizedBox(width: 8),
              Icon(iconRight, size: iconSize),
            ],
          ],
        ),
      ),
    );
  }
}
