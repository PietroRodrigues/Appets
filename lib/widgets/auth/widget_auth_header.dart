import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/branding/widget_logo.dart';

/// Cabeçalho visual reutilizável para telas de autenticação.
class AppAuthHeader extends StatelessWidget {
  const AppAuthHeader({
    super.key,
    this.logoWidth = 200,
    this.headline,
    this.description = AppStrings.slogan,
    this.spacing = 24,
    this.textColor,
  });

  final double logoWidth;
  final String? headline;
  final String description;
  final double spacing;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = textColor ?? AppColors.textPrimary;

    return Column(
      children: [
        AppLogo(width: logoWidth),

        SizedBox(height: spacing),

        if (headline != null) ...[
          Text(
            headline!,
            textAlign: TextAlign.center,
            style: AppTextStyles.title.copyWith(color: effectiveColor),
          ),

          const SizedBox(height: 12),
        ],

        if (description.isNotEmpty)
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTextStyles.heading.copyWith(color: effectiveColor),
          ),
      ],
    );
  }
}
