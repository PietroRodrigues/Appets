import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/utils/pet_filters.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/widgets/filters/widget_pet_filters_sheet.dart';

void main() {
  Pet makePet({
    int age = 3,
    AppPetAgeUnit ageUnit = AppPetAgeUnit.years,
    AppPetGender gender = AppPetGender.male,
    AppPetSpecies species = AppPetSpecies.dog,
    AppPetPublicationType type = AppPetPublicationType.adoption,
  }) {
    return Pet(
      id: 'p1',
      ownerId: 'u1',
      name: 'Rex',
      age: age,
      ageUnit: ageUnit,
      gender: gender,
      address: 'X',
      images: const [],
      species: species,
      publicationType: type,
    );
  }

  PetFilterOption opt(PetFilterCategory category, String value) =>
      PetFilterOption(category: category, value: value, label: value);

  group('ageBracketOf', () {
    test('faixa Filhote: < 12 meses', () {
      expect(ageBracketOf(0, AppPetAgeUnit.years), 'filhote');
      expect(ageBracketOf(11, AppPetAgeUnit.months), 'filhote');
      expect(ageBracketOf(350, AppPetAgeUnit.days), 'filhote');
    });

    test('faixa Jovem: 12 meses a 5 anos', () {
      expect(ageBracketOf(12, AppPetAgeUnit.months), 'jovem');
      expect(ageBracketOf(1, AppPetAgeUnit.years), 'jovem');
      expect(ageBracketOf(5, AppPetAgeUnit.years), 'jovem');
      expect(ageBracketOf(360, AppPetAgeUnit.days), 'jovem');
    });

    test('faixa Adulto: > 5 anos', () {
      expect(ageBracketOf(6, AppPetAgeUnit.years), 'adulto');
      expect(ageBracketOf(61, AppPetAgeUnit.months), 'adulto');
      expect(ageBracketOf(72, AppPetAgeUnit.months), 'adulto');
    });
  });

  group('buildFilterTokens', () {
    test('gera um token por categoria, na ordem fixa', () {
      expect(
        buildFilterTokens(
          species: AppPetSpecies.dog,
          gender: AppPetGender.female,
          publicationType: AppPetPublicationType.lost,
          age: 6,
          ageUnit: AppPetAgeUnit.years,
        ),
        ['cachorro', 'femea', 'perdido', 'adulto'],
      );
    });

    test('usa years como padrão e deriva a faixa de idade', () {
      expect(
        buildFilterTokens(
          species: AppPetSpecies.cat,
          gender: AppPetGender.female,
          publicationType: AppPetPublicationType.adoption,
          age: 4,
        ),
        ['gato', 'femea', 'adocao', 'jovem'],
      );
    });
  });

  group('petMatchesFilters', () {
    test('sem filtros aceita qualquer pet', () {
      expect(petMatchesFilters(makePet(), const []), isTrue);
    });

    test('espécie casa (OR dentro da categoria)', () {
      final dogOrCat = [
        opt(PetFilterCategory.species, 'cachorro'),
        opt(PetFilterCategory.species, 'gato'),
      ];
      expect(petMatchesFilters(makePet(species: AppPetSpecies.dog), dogOrCat), isTrue);
      expect(petMatchesFilters(makePet(species: AppPetSpecies.cat), dogOrCat), isTrue);
      expect(
        petMatchesFilters(makePet(species: AppPetSpecies.bird), dogOrCat),
        isFalse,
      );
    });

    test('gênero exige AND sem false positive do array misto', () {
      // Caso clássico: filtra "cachorro OU gato" E "fêmea".
      final filters = [
        opt(PetFilterCategory.species, 'cachorro'),
        opt(PetFilterCategory.species, 'gato'),
        opt(PetFilterCategory.gender, 'femea'),
      ];
      expect(
        petMatchesFilters(
          makePet(species: AppPetSpecies.dog, gender: AppPetGender.male),
          filters,
        ),
        isFalse,
      );
      expect(
        petMatchesFilters(
          makePet(species: AppPetSpecies.cat, gender: AppPetGender.female),
          filters,
        ),
        isTrue,
      );
    });

    test('tipo de publicação filtra por categoria', () {
      final lost = [opt(PetFilterCategory.publicationType, 'perdido')];
      expect(
        petMatchesFilters(
          makePet(type: AppPetPublicationType.lost),
          lost,
        ),
        isTrue,
      );
      expect(
        petMatchesFilters(
          makePet(type: AppPetPublicationType.adoption),
          lost,
        ),
        isFalse,
      );
    });

    test('idade compara a faixa derivada, não a idade bruta', () {
      final adult = [opt(PetFilterCategory.age, 'adulto')];
      expect(
        petMatchesFilters(makePet(age: 6, ageUnit: AppPetAgeUnit.years), adult),
        isTrue,
      );
      expect(
        petMatchesFilters(makePet(age: 3, ageUnit: AppPetAgeUnit.years), adult),
        isFalse,
      );
    });

    test('combina doses das categorias sem selecionar ignora o resto', () {
      final filters = [
        opt(PetFilterCategory.gender, 'macho'),
        opt(PetFilterCategory.species, 'cachorro'),
      ];
      expect(
        petMatchesFilters(
          makePet(gender: AppPetGender.male, species: AppPetSpecies.dog),
          filters,
        ),
        isTrue,
      );
      // Categorias não selecionadas (idade, tipo) não interferem.
      expect(
        petMatchesFilters(
          makePet(
            gender: AppPetGender.male,
            species: AppPetSpecies.dog,
            age: 8,
            type: AppPetPublicationType.lost,
          ),
          filters,
        ),
        isTrue,
      );
    });
  });
}