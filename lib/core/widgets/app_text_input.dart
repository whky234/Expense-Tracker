import 'package:flutter/material.dart';

class AppTextInput extends StatelessWidget {
  const AppTextInput({
    this.controller,
    required this.labelText,
    this.prefixIcon,
    this.prefixText,
    this.keyboardType,
    this.maxLines = 1,
    this.obscureText = false,
    this.validator,
    super.key,
  });

  final TextEditingController? controller;
  final String labelText;
  final Widget? prefixIcon;
  final String? prefixText;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool obscureText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final InputDecoration decoration = InputDecoration(
      labelText: labelText,
      prefixIcon: prefixIcon,
      prefixText: prefixText,
    );

    if (validator != null) {
      return TextFormField(
        controller: controller,
        decoration: decoration,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
      );
    }

    return TextField(
      controller: controller,
      decoration: decoration,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
    );
  }
}
