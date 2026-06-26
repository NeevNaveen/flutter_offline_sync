import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';

class FoundationBottomSheet {
  const FoundationBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    String? actionLabel,
    VoidCallback? onAction,
    bool showDragHandle = true,
  }) {
    final theme = context.theme;
    final colors = theme.colors.semantic;
    final spacing = theme.sizes.spacing;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(theme.sizes.radius.xl),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: spacing.lg,
            right: spacing.lg,
            top: spacing.md,
            bottom: MediaQuery.viewInsetsOf(context).bottom + spacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showDragHandle)
                Center(
                  child: Container(
                    width: spacing.xxxl,
                    height: spacing.xxs,
                    margin: EdgeInsets.only(bottom: spacing.md),
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(theme.sizes.radius.full),
                    ),
                  ),
                ),
              Text(
                title,
                style: theme.typography.headline.large.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: spacing.md),
              child,
              if (actionLabel != null) ...[
                SizedBox(height: spacing.lg),
                PrimaryButton(
                  label: actionLabel,
                  onPressed: () {
                    onAction?.call();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
