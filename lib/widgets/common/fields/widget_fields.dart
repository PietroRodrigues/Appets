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
              borderSide: const BorderSide(color: ThemeColors.error, width: 2),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: ThemeColors.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// Rótulo padronizado dos campos de formulário.
///
/// Exibe o texto em estilo subtítulo com espaçamento
/// padrão antes do campo correspondente.
class AppFieldLabel extends StatelessWidget {
  const AppFieldLabel({
    super.key,
    required this.text,
  });

  // PROPERTIES
  final String text;

  // UI
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: ThemeTextStyles.subtitle),

        const SizedBox(height: 8),
      ],
    );
  }
}

/// Campo de senha reutilizável com alternância de visibilidade.
///
/// Encapsula o estado de ocultação e o ícone de olho,
/// espelhando a API do [AppTextField].
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
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
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
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
    return AppTextField(
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

/// Formatter de máscara telefônica brasileira: `(XX) XXXXX-XXXX`.
class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    var formatted = '';
    if (digits.isNotEmpty) {
      if (digits.length <= 2) {
        formatted = digits;
      } else if (digits.length <= 6) {
        formatted = '(${digits.substring(0, 2)}) ${digits.substring(2)}';
      } else if (digits.length <= 10) {
        formatted =
            '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}';
      } else {
        final max = digits.length > 11 ? 11 : digits.length;
        formatted =
            '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7, max)}';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Campo de telefone reutilizável com máscara brasileira.
///
/// Encapsula a formatação `(XX) XXXXX-XXXX` e o teclado numérico,
/// espelhando a API do [AppTextField].
class AppPhoneField extends StatelessWidget {
  const AppPhoneField({
    super.key,
    required this.controller,
    this.focusNode,
    this.label,
    this.labelStyle,
    required this.hintText,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.onChanged,
  });

  // PROPERTIES
  final TextEditingController controller;

  final FocusNode? focusNode;

  final String? label;
  final TextStyle? labelStyle;
  final String hintText;
  final TextInputAction? textInputAction;

  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      focusNode: focusNode,
      label: label,
      labelStyle: labelStyle,
      hintText: hintText,
      keyboardType: TextInputType.phone,
      prefixIcon: Icons.phone_outlined,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _PhoneInputFormatter(),
      ],
    );
  }
}