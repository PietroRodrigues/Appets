import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/display/widget_logo.dart';
import 'package:flutter/material.dart';

/// Cabeçalho visual reutilizável para telas de autenticação.
class WGAuthHeader extends StatelessWidget {
  const WGAuthHeader({
    super.key,
    this.logoWidth = 200,
    this.headline,
    this.description = SharedStrings.SLOGAN,
    this.spacing = 24,
    this.textColor,
  });

  /// Cabeçalho padrão das telas de autenticação (logo 240, texto escuro
  /// sobre o laranja e sem slogan).
  const WGAuthHeader.auth({super.key, this.headline, this.spacing = 24})
    : logoWidth = 240,
      description = '',
      textColor = _authTextColor;

  /// Cor do texto padrão dos cabeçalhos `.auth` sobre o laranja: creme
  /// [AppColors.onPrimary], idêntico nas paletas clara e escura.
  ///
  /// Declarada como literal porque um default de construtor `const` precisa
  /// ser uma expressão constante e não pode acessar a propriedade de outra
  /// constante (ex.: `AppColors.light.onPrimary`).
  static const Color _authTextColor = Color(0xFFF5E2C7);

  final double logoWidth;
  final String? headline;
  final String description;
  final double spacing;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = textColor ?? context.appColors.textPrimary;

    return Column(
      children: [
        WGLogo(width: logoWidth),

        SizedBox(height: spacing),

        if (headline != null) ...[
          Text(
            headline!,
            textAlign: TextAlign.center,
            style: ThemeTextStyles.title(
              context.appColors,
            ).copyWith(color: effectiveColor),
          ),

          const SizedBox(height: 12),
        ],

        if (description.isNotEmpty)
          Text(
            description,
            textAlign: TextAlign.center,
            style: ThemeTextStyles.heading(
              context.appColors,
            ).copyWith(color: effectiveColor),
          ),
      ],
    );
  }
}
