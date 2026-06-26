import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';

class SuccessAlert extends StatelessWidget {
  const SuccessAlert({
    super.key,
    required this.message,
    this.title,
    this.onDismiss,
    this.visible = true,
  });

  final String message;
  final String? title;
  final VoidCallback? onDismiss;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors.semantic;
    final spacing = theme.sizes.spacing;

    return FoundationAnimatedPresence(
      visible: visible,
      child: Material(
        color: colors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(theme.sizes.radius.md),
        child: Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_rounded, color: colors.success),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: theme.typography.title.large.copyWith(
                          color: colors.success,
                        ),
                      ),
                    if (title != null) SizedBox(height: spacing.xxs),
                    Text(
                      message,
                      style: theme.typography.body.medium.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  onPressed: onDismiss,
                  icon: Icon(Icons.close, color: colors.textSecondary),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
