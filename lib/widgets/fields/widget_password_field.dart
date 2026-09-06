import 'package:flutter/material.dart';

import 'package:appets/widgets/fields/widget_text_field.dart';

/// Campo de senha reutilizável com alternância de visibilidade.
///
/// Encapsula o estado de ocultação e o ícone de olho,
/// espelhando a API do [WGTextField].
class WGPasswordField extends StatefulWidget {
  const WGPasswordField({
    super.key,
    required this.controller,
    this.focusNode,
    this.label,
    this.labelStyle,
    required this.hintText,
    this.prefixIcon = Icons.lock_outline,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.errorStyle,
  });

  // PROPERTIES
  final TextEditingController controller;

  final FocusNode? focusNode;

  final String? label;
  final TextStyle? labelStyle;
  final String hintText;
  final IconData prefixIcon;
  final TextInputAction? textInputAction;

  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final TextStyle? errorStyle;

  @override
  State<WGPasswordField> createState() => _WGPasswordFieldState();
}

class _WGPasswordFieldState extends State<WGPasswordField> {
  // Alterna a visibilidade da senha na interface.
  bool _obscurePassword = true;

  void _toggleVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return WGTextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      label: widget.label,
      labelStyle: widget.labelStyle,
      hintText: widget.hintText,
      obscureText: _obscurePassword,
      prefixIcon: widget.prefixIcon,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      errorStyle: widget.errorStyle,

      suffixIcon: IconButton(
        onPressed: _toggleVisibility,
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
        ),
      ),
    );
  }
}
