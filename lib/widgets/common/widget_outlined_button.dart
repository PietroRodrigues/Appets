import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';

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
    final effectiveBorder = borderColor ?? AppColors.primary;
    final effectiveText = textColor ?? AppColors.primary;
    final effectiveIcon = iconColor ?? AppColors.primary;

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
          style: AppTextStyles.button.copyWith(color: effectiveText),
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
