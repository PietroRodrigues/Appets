import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings_pet_details.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/models/enums/enums_app.dart';
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

  /// Ícone do gênero (♂ para macho, ♀ para fêmea).
  IconData get genderIcon {
    switch (gender) {
      case AppPetGender.male:
        return Icons.male;
      case AppPetGender.female:
        return Icons.female;
    }
  }

  /// Cor associada ao gênero (azul para macho, rosa para fêmea).
  Color get genderColor {
    switch (gender) {
      case AppPetGender.male:
        return ThemeColors.genderMale;
      case AppPetGender.female:
        return ThemeColors.genderFemale;
    }
  }

  /// Espécie e raça formatadas ("Cachorro · Poodle"), apenas a espécie
  /// quando a raça não foi informada.
  String get speciesRaceLabel {
    final trimmedRace = race.trim();
    if (trimmedRace.isEmpty) return species.label;
    return '${species.label} · $trimmedRace';
  }

  /// Mensagem de compartilhamento do pet, com variação conforme o tipo de
  /// publicação: adoção (procura um novo lar) ou perdido (dono procurando).
  /// Pronta para ser enviada ao share sheet.
  String get shareText {
    final isAdoption = publicationType == AppPetPublicationType.adoption;
    final identity = '$speciesRaceLabel · $ageLabel · $genderLabel';
    final description = (this.description ?? '').trim();
    final location = address.trim();
    final phone = ownerPhone.trim();

    return [
      isAdoption
          ? PetDetailsStrings.shareAdoptionTitle(name)
          : PetDetailsStrings.shareLostTitle(name),
      '',
      isAdoption
          ? PetDetailsStrings.SHARE_ADOPTION_HEADING
          : PetDetailsStrings.SHARE_LOST_HEADING,
      identity,
      if (description.isNotEmpty) ...[
        '',
        description,
      ],
      if (location.isNotEmpty) ...[
        '',
        isAdoption
            ? PetDetailsStrings.shareLocationLine(location)
            : PetDetailsStrings.shareLostRegionLine(location),
      ],
      if (phone.isNotEmpty)
        isAdoption
            ? PetDetailsStrings.sharePhoneLine(phone)
            : PetDetailsStrings.shareLostPhoneLine(phone),
      '',
      PetDetailsStrings.SHARE_FOOTER,
    ].join('\n');
  }
}
