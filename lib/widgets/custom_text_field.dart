import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final Function(String)? onChanged;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: AppConstants.inputDecoration(label).copyWith(
        hintText: hint,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      onChanged: onChanged,
      style: AppConstants.bodyStyle,
    );
  }
}
