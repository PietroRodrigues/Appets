import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/main/widget_search_bar.dart';

/// Cabeçalho reutilizável das páginas com título e campo de busca.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader.user({
    super.key,
    required String this.userName,
    this.description,
    this.hintText,
    this.onSearchChanged,
    this.onFilterPressed,
    this.showSearchBar = true,
  }) : title = null;

  const AppPageHeader.title({
    super.key,
    required String this.title,
    this.description,
    this.hintText,
    this.onSearchChanged,
    this.onFilterPressed,
    this.showSearchBar = true,
  }) : userName = null;

  final String? title;
  final String? userName;
  final String? description;
  final String? hintText;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterPressed;
  final bool showSearchBar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: ThemeColors.primary,
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
                style: ThemeTextStyles.heading.copyWith(
                  color: ThemeColors.white,
                  fontSize: 24,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 4),
                Text(
                  description!,
                  style: ThemeTextStyles.caption.copyWith(
                    color: ThemeColors.white,
                  ),
                ),
              ],
              if (showSearchBar) ...[
                const SizedBox(height: 12),
                AppSearchBar(
                  hintText: hintText,
                  onChanged: onSearchChanged,
                  onFilterPressed: onFilterPressed,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
