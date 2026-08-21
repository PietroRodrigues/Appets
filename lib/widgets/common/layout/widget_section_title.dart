import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';

/// Título de seção reutilizável das telas de configurações e dados da conta.
class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: ThemeTextStyles.subtitle.copyWith(
          color: ThemeColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
