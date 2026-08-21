import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';

/// Botão padronizado para ações principais do app.
class WidgetButton extends StatelessWidget {
  const WidgetButton({
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
