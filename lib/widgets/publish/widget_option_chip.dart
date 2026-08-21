import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';

/// Chip de seleção padronizado dos formulários.
///
/// Sem [accentColor], o chip selecionado fica sólido na cor primária
/// com texto branco. Com [accentColor], fica com fundo suave da cor
/// e texto/borda coloridos (estilo das tags dos cards).
class AppOptionChip extends StatelessWidget {
  const AppOptionChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.accentColor,
  });

  // PROPERTIES
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  /// Cor de destaque quando selecionado.
  final Color? accentColor;

  // UI
  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ?? ThemeColors.primary;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (_) => onSelected(),
      selectedColor: accentColor != null
          ? effectiveAccent.withValues(alpha: 0.15)
          : effectiveAccent,
      backgroundColor: ThemeColors.surface,
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? effectiveAccent : ThemeColors.border,
        ),
      ),
      labelStyle: ThemeTextStyles.caption.copyWith(
        color: isSelected ? effectiveAccent : ThemeColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
