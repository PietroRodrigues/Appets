import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/models/enums/enums_app.dart';

/// Extensões visuais do tipo de publicação do pet.
extension AppPetPublicationTypeX on AppPetPublicationType {
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
