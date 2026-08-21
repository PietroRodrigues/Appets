import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_text_styles.dart';

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
