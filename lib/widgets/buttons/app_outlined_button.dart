import 'package:flutter/material.dart';

import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/core/theme/app_text_styles.dart';

class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width = double.infinity,
    this.height = 52,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null
            ? Icon(
                icon,
                size: 20,
                color: AppColors.primary,
              )
            : const SizedBox.shrink(),
        label: Text(
          text,
          style: AppTextStyles.button.copyWith(
            color: AppColors.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }
}