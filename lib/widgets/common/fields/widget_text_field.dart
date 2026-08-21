import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';

/// Campo de texto reutilizável com estilo consistente do app.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
    this.autofocus = false,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.maxLines = 1,
    this.inputFormatters = const [],
  });

  final TextEditingController? controller;

  final FocusNode? focusNode;

  final String? label;
  final String hintText;

  final IconData? prefixIcon;
  final Widget? suffixIcon;

  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  final List<TextInputFormatter> inputFormatters;

  final dynamic maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: labelStyle ?? ThemeTextStyles.body),
          const SizedBox(height: 8),
        ],

        TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          autofocus: autofocus,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: hintStyle ?? ThemeTextStyles.body.copyWith(color: ThemeColors.textSecondary),
            errorStyle: errorStyle,

            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,

            suffixIcon: suffixIcon,

            filled: true,
            fillColor: ThemeColors.white,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: ThemeColors.primary, width: 2),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
