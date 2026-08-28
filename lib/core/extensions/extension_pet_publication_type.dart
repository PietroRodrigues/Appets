import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/models/enums/enums_pet.dart';

/// Extensões visuais do tipo de publicação do pet.
extension AppPetPublicationTypeX on AppPetPublicationType {
  /// Rótulo exibido na interface.
  String get label {
    switch (this) {
      case AppPetPublicationType.adoption:
        return 'Adoção';

      case AppPetPublicationType.lost:
        return 'Perdido';
    }
  }

  /// Ícone representativo.
  IconData get icon {
    switch (this) {
      case AppPetPublicationType.adoption:
        return Icons.pets;

      case AppPetPublicationType.lost:
        return Icons.search;
    }
  }

  /// Cor de destaque.
  Color get color {
    switch (this) {
      case AppPetPublicationType.adoption:
        return ThemeColors.success;

      case AppPetPublicationType.lost:
        return ThemeColors.error;
    }
  }
}
