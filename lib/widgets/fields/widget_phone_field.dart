import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:appets/widgets/fields/widget_text_field.dart';

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
/// espelhando a API do [WGTextField].
class WGPhoneField extends StatelessWidget {
  const WGPhoneField({
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
    return WGTextField(
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
