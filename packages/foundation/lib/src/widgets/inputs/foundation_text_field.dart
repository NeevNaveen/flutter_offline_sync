import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foundation/foundation.dart';

typedef FoundationFieldValidator = String? Function(String value);

class FoundationTextField extends StatefulWidget {
  const FoundationTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.validator,
    this.autovalidate = false,
    this.prefixIcon,
    this.onChanged,
    this.onSubmitted,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final FoundationFieldValidator? validator;
  final bool autovalidate;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<FoundationTextField> createState() => FoundationTextFieldState();
}

class FoundationTextFieldState extends State<FoundationTextField> {
  String? _error;
  int _shakeTrigger = 0;
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  bool validate() {
    final error = widget.validator?.call(_controller.text);
    setState(() {
      _error = error;
      if (error != null) {
        _shakeTrigger++;
      }
    });
    return error == null;
  }

  void clearError() {
    if (_error != null) {
      setState(() => _error = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors.semantic;
    final spacing = theme.sizes.spacing;
    final hasError = _error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.typography.label.medium.copyWith(
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: spacing.xs),
        ],
        FoundationShake(
          trigger: _shakeTrigger,
          child: TextField(
            controller: _controller,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            inputFormatters: widget.inputFormatters,
            onChanged: (value) {
              if (widget.autovalidate) {
                setState(() => _error = widget.validator?.call(value));
              } else {
                clearError();
              }
              widget.onChanged?.call(value);
            },
            onSubmitted: widget.onSubmitted,
            style: theme.typography.body.large.copyWith(
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: theme.typography.body.medium.copyWith(
                color: colors.textSecondary,
              ),
              prefixIcon: widget.prefixIcon == null
                  ? null
                  : Icon(widget.prefixIcon, color: colors.textSecondary),
              filled: true,
              fillColor: colors.surface,
              contentPadding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.md,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(theme.sizes.radius.md),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(theme.sizes.radius.md),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(theme.sizes.radius.md),
                borderSide: BorderSide(color: colors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(theme.sizes.radius.md),
                borderSide: BorderSide(color: colors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(theme.sizes.radius.md),
                borderSide: BorderSide(color: colors.error, width: 2),
              ),
            ),
          ),
        ),
        FoundationAnimatedPresence(
          visible: hasError,
          slideOffset: const Offset(0, -0.04),
          child: Padding(
            padding: EdgeInsets.only(top: spacing.xs, left: spacing.xxs),
            child: Text(
              _error ?? '',
              style: theme.typography.label.medium.copyWith(
                color: colors.error,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String? _requiredValidator(String value, {String field = 'This field'}) {
  if (value.trim().isEmpty) {
    return '$field is required';
  }
  return null;
}

String? foundationEmailValidator(String value) {
  final required = _requiredValidator(value, field: 'Email');
  if (required != null) return required;
  final pattern = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$');
  if (!pattern.hasMatch(value.trim())) {
    return 'Enter a valid email address';
  }
  return null;
}

String? foundationPhoneValidator(String value) {
  final required = _requiredValidator(value, field: 'Phone number');
  if (required != null) return required;
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 10) {
    return 'Enter a valid phone number';
  }
  return null;
}
