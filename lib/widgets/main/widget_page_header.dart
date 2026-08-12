import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/main/widget_search_bar.dart';

/// Cabeçalho reutilizável das páginas com título e campo de busca.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader.user({
    super.key,
    required String this.userName,
    this.hintText,
    this.onSearchChanged,
    this.onFilterPressed,
  }) : title = null;

  const AppPageHeader.title({
    super.key,
    required String this.title,
    this.hintText,
    this.onSearchChanged,
    this.onFilterPressed,
  }) : userName = null;

  final String? title;
  final String? userName;
  final String? hintText;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName != null ? 'Olá, $userName' : title!,
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.white,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 12),
              AppSearchBar(
                hintText: hintText,
                onChanged: onSearchChanged,
                onFilterPressed: onFilterPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
