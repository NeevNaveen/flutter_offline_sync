import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foundation/src/widgets/inputs/foundation_text_field.dart';

class PhoneInputField extends StatefulWidget {
  const PhoneInputField({
    super.key,
    this.label = 'Phone number',
    this.hint = '+1 (555) 000-0000',
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
  State<PhoneInputField> createState() => PhoneInputFieldState();
}

class PhoneInputFieldState extends State<PhoneInputField> {
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
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      prefixIcon: Icons.phone_outlined,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d\s()+-]')),
        LengthLimitingTextInputFormatter(20),
      ],
      onChanged: widget.onChanged,
      validator: foundationPhoneValidator,
    );
  }
}
