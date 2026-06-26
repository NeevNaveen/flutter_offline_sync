import 'package:flutter/material.dart';
import 'package:foundation/src/widgets/inputs/foundation_text_field.dart';

class PrimaryTextInputField extends StatefulWidget {
  const PrimaryTextInputField({
    super.key,
    this.label = 'Name',
    this.hint = 'Enter your name',
    this.controller,
    this.autovalidate = true,
    this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool autovalidate;
  final ValueChanged<String>? onChanged;

  @override
  State<PrimaryTextInputField> createState() => PrimaryTextInputFieldState();
}

class PrimaryTextInputFieldState extends State<PrimaryTextInputField> {
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
      prefixIcon: Icons.person_outline_rounded,
      textInputAction: TextInputAction.next,
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
