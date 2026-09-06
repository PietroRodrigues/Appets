import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/widgets/buttons/widget_buttons.dart';

/// Botão principal das telas de autenticação: fundo branco com texto
/// escuro e borda, no tamanho padrão das telas de login/cadastro.
class WGAuthButton extends StatelessWidget {
  const WGAuthButton({super.key, required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return WGButton(
      text: text,
      onPressed: onPressed,
      height: 48,
      backgroundColor: ThemeColors.white,
      foregroundColor: ThemeColors.secondary,
      borderColor: ThemeColors.secondary,
    );
  }
}

/// Botão secundário das telas de autenticação: contorno branco com
/// texto branco, no tamanho padrão das telas de login/cadastro.
class WGAuthSecondaryButton extends StatelessWidget {
  const WGAuthSecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return WGOutlinedButton(
      text: text,
      onPressed: onPressed,
      height: 48,
      borderColor: ThemeColors.white,
      textColor: ThemeColors.white,
    );
  }
}
