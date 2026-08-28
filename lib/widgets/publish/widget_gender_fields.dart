import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/models/enums/enums_pet.dart';

/// Campos de gênero reutilizáveis do formulário de publicação.
///
/// Exibe as opções "Macho" e "Fêmea" lado a lado.
class AppGenderFields extends StatelessWidget {
  const AppGenderFields({
    super.key,
    this.groupValue,
    required this.onChanged,
  });

  // PROPERTIES

  /// Gênero atualmente selecionado.
  final AppPetGender? groupValue;

  /// Notifica o gênero selecionado (pode ser `null`).
  final ValueChanged<AppPetGender?> onChanged;

  // UI
  @override
  Widget build(BuildContext context) {
    return RadioGroup<AppPetGender>(
      groupValue: groupValue,
      onChanged: onChanged,
      child: Row(
        children: [
          Expanded(
            child: RadioListTile<AppPetGender>(
              contentPadding: EdgeInsets.zero,
              title: Text(AppPetGender.male.label),
              value: AppPetGender.male,
              activeColor: ThemeColors.primary,
            ),
          ),

          Expanded(
            child: RadioListTile<AppPetGender>(
              contentPadding: EdgeInsets.zero,
              title: Text(AppPetGender.female.label),
              value: AppPetGender.female,
              activeColor: ThemeColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
