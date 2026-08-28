import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';

/// Título de seção reutilizável das telas de configurações e dados da conta.
class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle({
    super.key,
    required this.title,
    this.titleColor,
  });

  final String title;

  /// Cor do título. Quando nula, usa a cor primária.
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: ThemeTextStyles.subtitle.copyWith(
          color: titleColor ?? ThemeColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
