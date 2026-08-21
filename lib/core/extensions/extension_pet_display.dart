import 'package:appets/models/model_pet.dart';

/// Extensões de exibição dos dados do pet.
extension AppPetDisplayX on Pet {
  /// Idade formatada ("1 ano" ou "N anos").
  String get ageLabel {
    if (age == 1) {
      return '1 ano';
    }

    return '$age anos';
  }

  /// Gênero formatado ("Macho" ou "Fêmea").
  String get genderLabel {
    return gender.name == 'male' ? 'Macho' : 'Fêmea';
  }
}
