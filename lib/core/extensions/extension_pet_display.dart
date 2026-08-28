import 'package:appets/models/enums/enums_pet.dart';
import 'package:appets/models/model_pet.dart';

/// Extensões de exibição dos dados do pet.
extension AppPetDisplayX on Pet {
  /// Idade formatada de acordo com a unidade ("N dia(s)", "N mês(es)" ou "N ano(s)").
  ///
  /// Usa o singular quando [age] é 1 e reaproveita o rótulo da
  /// unidade ([AppPetAgeUnit.label]) para os valores maiores.
  String get ageLabel {
    if (age == 1) {
      switch (ageUnit) {
        case AppPetAgeUnit.days:
          return '1 dia';
        case AppPetAgeUnit.months:
          return '1 mês';
        case AppPetAgeUnit.years:
          return '1 ano';
      }
    }
    return '$age ${ageUnit.label}';
  }

  /// Gênero formatado ("Macho" ou "Fêmea").
  String get genderLabel => gender.label;
}
