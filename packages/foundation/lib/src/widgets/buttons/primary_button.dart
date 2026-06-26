import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expand = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expand;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors.semantic;
    final spacing = theme.sizes.spacing;
    final radius = theme.sizes.radius.md;

    final child = isLoading
        ? SizedBox(
            height: spacing.lg,
            width: spacing.lg,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: spacing.lg),
                SizedBox(width: spacing.sm),
              ],
              Text(
                label,
                style: theme.typography.title.large.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          );

    final button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        disabledBackgroundColor: colors.primary.withValues(alpha: 0.5),
        foregroundColor: Colors.white,
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
