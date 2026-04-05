import 'package:flutter/material.dart';

import '../../../../shared/widgets/finn_text_field.dart';

class AuthFormField extends StatelessWidget {
  const AuthFormField({
    super.key,
    required this.name,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
  });

  final String name;
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return FinnTextField(
      name: name,
      controller: controller,
      label: label,
      hint: hint,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
    );
  }
}
