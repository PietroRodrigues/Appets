import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';

/// Linha de informação reutilizável com ícone e texto.
///
/// Usada na tela de detalhes do pet para exibir
/// idade, gênero, cidade e tipo de publicação.
class AppInfoRow extends StatelessWidget {
  const AppInfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor = ThemeColors.secondary,
    this.textStyle,
  });

  // PROPERTIES
  final IconData icon;
  final String text;

  /// Cor do ícone (padrão: secundária).
  final Color iconColor;

  /// Estilo do texto (padrão: [ThemeTextStyles.body]).
  final TextStyle? textStyle;

  // UI
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
        ),

        const SizedBox(width: 8),

        Text(
          text,
          style: textStyle ?? ThemeTextStyles.body,
        ),
      ],
    );
  }
}
