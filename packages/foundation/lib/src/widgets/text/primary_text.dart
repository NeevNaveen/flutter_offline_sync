import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';

class PrimaryText extends StatelessWidget {
  const PrimaryText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Text(
      data,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: (style ?? theme.typography.body.large).copyWith(
        color: theme.colors.semantic.textPrimary,
      ),
    );
  }
}
