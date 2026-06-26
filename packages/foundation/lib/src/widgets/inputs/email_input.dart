import 'package:flutter/material.dart';
import 'package:foundation/src/widgets/inputs/foundation_text_field.dart';

class EmailInputField extends StatefulWidget {
  const EmailInputField({
    super.key,
    this.label = 'Email',
    this.hint = 'you@example.com',
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
  State<EmailInputField> createState() => EmailInputFieldState();
}

class EmailInputFieldState extends State<EmailInputField> {
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
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      prefixIcon: Icons.email_outlined,
      onChanged: widget.onChanged,
      validator: foundationEmailValidator,
    );
  }
}
