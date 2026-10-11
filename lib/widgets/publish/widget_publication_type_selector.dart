import 'package:flutter/material.dart';

import 'package:appets/core/extensions/extension_pet_publication_type.dart';
import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/models/enums/enums_app.dart';

/// Chip de seleção padronizado dos formulários.
///
/// Sem [accentColor], o chip selecionado fica sólido na cor primária
/// com texto branco. Com [accentColor], fica com fundo suave da cor
/// e texto/borda coloridos (estilo das tags dos cards).
class WGOptionChip extends StatelessWidget {
  const WGOptionChip({
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
    final effectiveAccent = accentColor ?? context.appColors.primary;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (_) => onSelected(),
      selectedColor: accentColor != null
          ? effectiveAccent.withValues(alpha: 0.15)
          : effectiveAccent,
      backgroundColor: context.appColors.surface,
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? effectiveAccent : context.appColors.border,
        ),
      ),
      labelStyle: ThemeTextStyles.caption(context.appColors).copyWith(
        color: isSelected ? effectiveAccent : context.appColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

/// Seletor do tipo de publicação reutilizável do formulário.
///
/// Exibe um chip para cada [AppPetPublicationType],
/// com a cor de destaque de cada tipo.
class WGPublicationTypeSelector extends StatelessWidget {
  const WGPublicationTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  // PROPERTIES

  /// Tipo atualmente selecionado.
  final AppPetPublicationType selectedType;

  /// Notifica o tipo de publicação selecionado.
  final ValueChanged<AppPetPublicationType> onChanged;

  // UI
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppPetPublicationType.values.map((type) {
        return WGOptionChip(
          label: type.label,
          isSelected: selectedType == type,
          accentColor: type.color(context.appColors),
          onSelected: () => onChanged(type),
        );
      }).toList(),
    );
  }
}
