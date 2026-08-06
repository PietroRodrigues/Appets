import 'package:flutter/material.dart';

import 'package:appets/core/constants/app_strings.dart';
import 'package:appets/core/theme/app_text_styles.dart';
import 'package:appets/widgets/branding/app_logo.dart';

class AppAuthHeader extends StatelessWidget {
  const AppAuthHeader({
    super.key,
    this.logoWidth = 200,
    this.headline,
    this.description = AppStrings.slogan,
    this.spacing = 24,
  });

  final double logoWidth;
  final String? headline;
  final String description;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppLogo(width: logoWidth),

        SizedBox(height: spacing),

        if (headline != null) ...[
          Text(
            headline!,
            textAlign: TextAlign.center,
            style: AppTextStyles.title,
          ),

          const SizedBox(height: 12),
        ],

        Text(
          description,
          textAlign: TextAlign.center,
          style: AppTextStyles.heading,
        ),
      ],
    );
  }
}