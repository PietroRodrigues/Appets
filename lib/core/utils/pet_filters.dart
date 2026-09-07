import 'package:appets/core/utils/storage_tokens.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/widgets/filters/widget_pet_filters_sheet.dart';

/// Faixas de idade usadas no filtro (em meses):
/// Filhote < 12, Jovem 12 a 60 (até 5 anos), Adulto > 60.
String ageBracketOf(int age, AppPetAgeUnit ageUnit) {
  final months = switch (ageUnit) {
    AppPetAgeUnit.days => age ~/ 30,
    AppPetAgeUnit.months => age,
    AppPetAgeUnit.years => age * 12,
  };
  if (months < 12) return kAgeBracketFilhote;
  if (months <= 60) return kAgeBracketJovem;
  return kAgeBracketAdulto;
}

/// Gera os tokens de filtro do pet, um por categoria (normalizados, em PT),
/// no mesmo formato do [buildSearchTokens] da busca: o array é gravado
/// no documento e consultado pelo servidor com `arrayContainsAny`.
List<String> buildFilterTokens({
  required AppPetSpecies species,
  required AppPetGender gender,
  required AppPetPublicationType publicationType,
  required int age,
  AppPetAgeUnit ageUnit = AppPetAgeUnit.years,
}) {
  return [
    speciesStorageToken(species),
    genderStorageToken(gender),
    publicationTypeStorageToken(publicationType),
    ageBracketOf(age, ageUnit),
  ];
}

/// Verifica se um pet atende ao conjunto de opções de filtro (authority
/// do cliente): AND entre categorias, OR dentro de cada categoria.
///
/// Com a lista vazia, todos os pets são aceitos.
bool petMatchesFilters(Pet pet, List<PetFilterOption> options) {
  if (options.isEmpty) return true;

  final byCategory = <PetFilterCategory, List<PetFilterOption>>{};
  for (final option in options) {
    byCategory.putIfAbsent(option.category, () => []).add(option);
  }

  for (final MapEntry(key: category, value: selected) in byCategory.entries) {
    final matches = switch (category) {
      PetFilterCategory.species =>
        selected.any((o) => o.value == speciesStorageToken(pet.species)),
      PetFilterCategory.gender =>
        selected.any((o) => o.value == genderStorageToken(pet.gender)),
      PetFilterCategory.publicationType => selected.any(
          (o) => o.value == publicationTypeStorageToken(pet.publicationType),
        ),
      PetFilterCategory.age =>
        selected.any((o) => o.value == ageBracketOf(pet.age, pet.ageUnit)),
    };
    if (!matches) return false;
  }
  return true;
}