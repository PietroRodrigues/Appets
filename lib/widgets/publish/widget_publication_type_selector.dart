import 'package:flutter/material.dart';

import 'package:appets/core/extensions/extension_pet_publication_type.dart';
import 'package:appets/models/enums/enums_pet.dart';
import 'package:appets/widgets/publish/widget_option_chip.dart';

/// Seletor do tipo de publicação reutilizável do formulário.
///
/// Exibe um chip para cada [AppPetPublicationType],
/// com a cor de destaque de cada tipo.
class AppPublicationTypeSelector extends StatelessWidget {
  const AppPublicationTypeSelector({
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
        return AppOptionChip(
          label: type.label,
          isSelected: selectedType == type,
          accentColor: type.color,
          onSelected: () => onChanged(type),
        );
      }).toList(),
    );
  }
}
