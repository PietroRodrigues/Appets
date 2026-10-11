import 'package:flutter/material.dart';

import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/widgets/buttons/widget_buttons.dart';

/// Botão principal das telas de autenticação: fundo claro (superfície do
/// tema) com texto secundário e borda, no tamanho padrão de login/cadastro.
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
      backgroundColor: context.appColors.surface,
      foregroundColor: context.appColors.secondary,
      borderColor: context.appColors.secondary,
    );
  }
}

/// Botão secundário das telas de autenticação: contorno e texto na cor
/// sobre a primária (creme), no tamanho padrão de login/cadastro.
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
      borderColor: context.appColors.onPrimary,
      textColor: context.appColors.onPrimary,
    );
  }
}
