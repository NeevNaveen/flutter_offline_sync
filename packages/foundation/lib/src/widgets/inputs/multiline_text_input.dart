import 'package:flutter/material.dart';
import 'package:foundation/src/widgets/inputs/foundation_text_field.dart';

class MultilineTextInputField extends StatefulWidget {
  const MultilineTextInputField({
    super.key,
    this.label = 'Notes',
    this.hint = 'Add details...',
    this.controller,
    this.minLines = 3,
    this.maxLines = 6,
    this.autovalidate = true,
    this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final int minLines;
  final int maxLines;
  final bool autovalidate;
  final ValueChanged<String>? onChanged;

  @override
  State<MultilineTextInputField> createState() => MultilineTextInputFieldState();
}

class MultilineTextInputFieldState extends State<MultilineTextInputField> {
  final _fieldKey = GlobalKey<FoundationTextFieldState>();

  bool validate() => _fieldKey.currentState?.validate() ?? false;

  @override
  Widget build(BuildContext context) {
    return FoundationTextField(
      key: _fieldKey,
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      autovalidate: widget.autovalidate,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      prefixIcon: Icons.notes_outlined,
      onChanged: widget.onChanged,
      validator: (value) {
        if (value.trim().isEmpty) {
          return '${widget.label} is required';
        }
        return null;
      },
    );
  }
}
