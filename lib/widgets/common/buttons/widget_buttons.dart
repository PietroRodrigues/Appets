import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';

/// Botão padronizado para ações principais do app.
///
/// Oferece variações de cor de fundo, texto, borda e um estado
/// de carregamento com indicador de progresso.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 52,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  /// Cor da borda do botão. Quando nula, o botão não tem borda.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final buttonForeground = foregroundColor ?? Colors.white;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? ThemeColors.secondary,
          foregroundColor: buttonForeground,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: borderColor != null
                ? BorderSide(color: borderColor!, width: 1.5)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: buttonForeground,
                ),
              )
            : Text(text, style: ThemeTextStyles.button.copyWith(color: buttonForeground)),
      ),
    );
  }
}

/// Botão com borda para ações secundárias.
class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width = double.infinity,
    this.height = 52,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.iconColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double width;
  final double height;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final effectiveBackground = backgroundColor ?? Colors.transparent;
    final effectiveBorder = borderColor ?? ThemeColors.primary;
    final effectiveText = textColor ?? ThemeColors.primary;
    final effectiveIcon = iconColor ?? ThemeColors.primary;

    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null
            ? Icon(icon, size: 20, color: effectiveIcon)
            : const SizedBox.shrink(),
        label: Text(
          text,
          style: ThemeTextStyles.button.copyWith(color: effectiveText),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: effectiveBorder, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: effectiveBackground,
          elevation: 0,
        ),
      ),
    );
  }
}

/// Botão branco no estilo clássico "Continuar com Google".
class AppGoogleButton extends StatelessWidget {
  const AppGoogleButton({
    super.key,
    required this.onPressed,
    this.text = AppStrings.googleLogin,
    this.width = double.infinity,
    this.height = 52,
  });

  final VoidCallback? onPressed;
  final String text;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Image(
          image: AssetImage('assets/logos/google_logo.png'),
          height: 22,
          width: 22,
        ),
        label: Text(
          text,
          style: ThemeTextStyles.button.copyWith(
            color: ThemeColors.secondary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: ThemeColors.white,
          foregroundColor: ThemeColors.secondary,
          side: BorderSide(color: ThemeColors.secondary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.25),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
      ),
    );
  }
}