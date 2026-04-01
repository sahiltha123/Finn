import 'package:flutter/material.dart';

class FinnTextField extends StatelessWidget {
  const FinnTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.textInputAction,
    this.maxLines = 1,
    this.prefix,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final int maxLines;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      textInputAction: textInputAction,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefix,
      ),
    );
  }
}
