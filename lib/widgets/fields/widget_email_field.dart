import 'package:appets/core/constants/constants_strings_auth.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/fields/widget_text_field.dart';
import 'package:flutter/material.dart';

/// Campo de e-mail reutilizável com teclado e ícone padronizados.
///
/// Encapsula a configuração do e-mail das telas de autenticação,
/// espelhando a API do [WGTextField].
class WGEmailField extends StatelessWidget {
  const WGEmailField({
    super.key,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.errorStyle,
  });

  // PROPERTIES
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final TextStyle? errorStyle;

  @override
  Widget build(BuildContext context) {
    return WGTextField(
      controller: controller,
      focusNode: focusNode,
      label: AuthStrings.EMAIL,
      labelStyle: ThemeTextStyles.authBody,
      hintText: AuthStrings.EMAIL_HINT,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_outlined,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      errorStyle: errorStyle,
    );
  }
}
