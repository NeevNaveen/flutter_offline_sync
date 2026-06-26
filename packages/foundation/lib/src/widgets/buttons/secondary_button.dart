import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors.semantic;
    final spacing = theme.sizes.spacing;
    final radius = theme.sizes.radius.md;

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: spacing.lg, color: colors.primary),
          SizedBox(width: spacing.sm),
        ],
        Text(
          label,
          style: theme.typography.title.large.copyWith(color: colors.primary),
        ),
      ],
    );

    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        side: BorderSide(color: colors.border),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.xl,
          vertical: spacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      child: child,
    );

    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
