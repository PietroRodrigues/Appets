import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_pet_details.dart';
import 'package:appets/core/extensions/extension_pet_display.dart';
import 'package:appets/core/utils/search_tokens.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';

void main() {
  group('Pet model', () {
    test('cria pet com campos obrigatórios', () {
      final pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 3,
        gender: AppPetGender.male,
        address: 'São Paulo',
        images: ['assets/images/dog.png'],
      );

      expect(pet.id, 'pet_001');
      expect(pet.ownerId, 'user_001');
      expect(pet.name, 'Rex');
      expect(pet.age, 3);
      expect(pet.gender, AppPetGender.male);
      expect(pet.address, 'São Paulo');
      expect(pet.images, ['assets/images/dog.png']);
      expect(pet.description, isNull);
      expect(pet.ageUnit, AppPetAgeUnit.years);
      expect(pet.publicationType, AppPetPublicationType.adoption);
      expect(pet.species, AppPetSpecies.dog);
      expect(pet.race, isEmpty);
      expect(pet.ownerPhone, isEmpty);
      expect(pet.ownerAddress, isEmpty);
    });

    test('cria pet com campos opcionais', () {
      final pet = Pet(
        id: 'pet_002',
        ownerId: 'user_001',
        name: 'Luna',
        age: 6,
        ageUnit: AppPetAgeUnit.months,
        gender: AppPetGender.female,
        address: 'Campinas',
        description: 'Luna é muito carinhosa.',
        publicationType: AppPetPublicationType.lost,
        species: AppPetSpecies.cat,
        race: 'Persa',
        images: ['assets/images/cat.png'],
      );

      expect(pet.description, 'Luna é muito carinhosa.');
      expect(pet.ageUnit, AppPetAgeUnit.months);
      expect(pet.publicationType, AppPetPublicationType.lost);
      expect(pet.species, AppPetSpecies.cat);
      expect(pet.race, 'Persa');
    });
  });

  group('Pet.toMap/fromMap', () {
    const original = Pet(
      id: 'pet_001',
      ownerId: 'user_001',
      name: 'Rex',
      age: 2,
      ageUnit: AppPetAgeUnit.years,
      gender: AppPetGender.male,
      address: 'São Paulo',
      description: 'Muito dócil.',
      publicationType: AppPetPublicationType.adoption,
      species: AppPetSpecies.dog,
      race: 'Poodle',
      images: ['a.png', 'b.png'],
    );

    Map<String, dynamic> map = {};

    setUp(() {
      map = original.toMap();
    });

    test('toMap inclui todos os campos persistidos', () {
      expect(map['ownerId'], 'user_001');
      expect(map['name'], 'Rex');
      expect(map['age'], 2);
      expect(map['ageUnit'], 'anos');
      expect(map['gender'], 'macho');
      expect(map['address'], 'São Paulo');
      expect(map['description'], 'Muito dócil.');
      expect(map['publicationType'], 'adocao');
      expect(map['species'], 'cachorro');
      expect(map['race'], 'Poodle');
      expect(map['images'], ['a.png', 'b.png']);
      expect(map['createdAt'], isNotNull);
    });

    test('toMap persiste specifications (1 token por categoria, em PT)', () {
      expect(map['specifications'], ['cachorro', 'macho', 'adocao', 'jovem']);
    });

    test('pet.specifications deriva dos campos atuais', () {
      expect(original.specifications, ['cachorro', 'macho', 'adocao', 'jovem']);

      final diferente = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Frajola',
        age: 6,
        ageUnit: AppPetAgeUnit.years,
        gender: AppPetGender.female,
        address: 'Rio',
        publicationType: AppPetPublicationType.lost,
        species: AppPetSpecies.cat,
        images: [],
      );
      expect(diferente.specifications, ['gato', 'femea', 'perdido', 'adulto']);
    });

    test('toMap persiste searchTokens normalizados para a busca', () {
      final tokens = map['searchTokens'] as List;
      expect(tokens, containsAll(buildSearchTokens(name: 'Rex')));
      expect(tokens, contains('docil'));
    });

    test('fromMap restaura os campos persistidos', () {
      final pet = Pet.fromMap('pet_001', map);

      expect(pet.id, 'pet_001');
      expect(pet.ownerId, 'user_001');
      expect(pet.name, 'Rex');
      expect(pet.age, 2);
      expect(pet.ageUnit, AppPetAgeUnit.years);
      expect(pet.gender, AppPetGender.male);
      expect(pet.address, 'São Paulo');
      expect(pet.description, 'Muito dócil.');
      expect(pet.publicationType, AppPetPublicationType.adoption);
      expect(pet.species, AppPetSpecies.dog);
      expect(pet.race, 'Poodle');
      expect(pet.images, ['a.png', 'b.png']);
    });

    test('fromMap usa padrões quando os campos de espécie/raça faltam', () {
      final legacy = Pet.fromMap('pet_001', {
        'ownerId': 'user_001',
        'name': 'Rex',
        'age': 2,
        'gender': 'male',
        'address': 'São Paulo',
      });

      expect(legacy.species, AppPetSpecies.dog);
      expect(legacy.race, isEmpty);
      // Sem specifications no documento, o getter recalcula dos campos.
      expect(legacy.specifications, ['cachorro', 'macho', 'adocao', 'jovem']);
    });

    test('fromMap tolera os códigos legados em inglês', () {
      final legacy = Pet.fromMap('pet_001', {
        'ownerId': 'user_001',
        'name': 'Rex',
        'age': 2,
        'ageUnit': 'years',
        'gender': 'male',
        'address': 'São Paulo',
        'publicationType': 'adoption',
        'species': 'dog',
      });

      expect(legacy.ageUnit, AppPetAgeUnit.years);
      expect(legacy.gender, AppPetGender.male);
      expect(legacy.publicationType, AppPetPublicationType.adoption);
      expect(legacy.species, AppPetSpecies.dog);
      expect(legacy.specifications, ['cachorro', 'macho', 'adocao', 'jovem']);
    });

    test('fromMap ignora espécie desconhecida com fallback', () {
      final pet = Pet.fromMap('pet_001', {
        'ownerId': 'user_001',
        'name': 'Rex',
        'age': 2,
        'gender': 'male',
        'address': 'São Paulo',
        'species': 'dragon',
      });

      expect(pet.species, AppPetSpecies.dog);
    });

    test('fromMap lê imagens quando a lista é válida', () {
      final pet = Pet.fromMap('pet_001', {
        'ownerId': 'user_001',
        'name': 'Rex',
        'age': 2,
        'ageUnit': 'years',
        'gender': 'male',
        'address': 'São Paulo',
        'images': ['a.png', 'b.png'],
      });

      expect(pet.id, 'pet_001');
      expect(pet.images, ['a.png', 'b.png']);
    });

    test(
      'fromMap ignora elementos não-string em images (dados corrompidos)',
      () {
        final pet = Pet.fromMap('pet_001', {
          'ownerId': 'user_001',
          'name': 'Rex',
          'age': 2,
          'gender': 'male',
          'address': 'São Paulo',
          'images': ['a.png', 123, null, 'b.png', true],
        });

        expect(pet.images, ['a.png', 'b.png']);
      },
    );

    test('fromMap não lança quando images falta ou não é uma lista', () {
      final withoutImages = Pet.fromMap('pet_001', {
        'ownerId': 'user_001',
        'name': 'Rex',
        'age': 2,
        'gender': 'male',
        'address': 'São Paulo',
      });
      expect(withoutImages.images, isEmpty);

      final stringImages = Pet.fromMap('pet_001', {
        'ownerId': 'user_001',
        'name': 'Rex',
        'age': 2,
        'gender': 'male',
        'address': 'São Paulo',
        'images': 'not-a-list',
      });
      expect(stringImages.images, isEmpty);
    });
  });

  group('Pet.toUpdateMap', () {
    const pet = Pet(
      id: 'pet_001',
      ownerId: 'user_001',
      name: 'Rex',
      age: 2,
      ageUnit: AppPetAgeUnit.years,
      gender: AppPetGender.male,
      address: 'São Paulo',
      description: 'Muito dócil.',
      publicationType: AppPetPublicationType.adoption,
      species: AppPetSpecies.dog,
      race: 'Poodle',
      images: ['a.png', 'b.png'],
    );

    late Map<String, dynamic> map;

    setUp(() {
      map = pet.toUpdateMap();
    });

    test('inclui os dados editáveis', () {
      expect(map['name'], 'Rex');
      expect(map['age'], 2);
      expect(map['ageUnit'], 'anos');
      expect(map['gender'], 'macho');
      expect(map['address'], 'São Paulo');
      expect(map['description'], 'Muito dócil.');
      expect(map['publicationType'], 'adocao');
      expect(map['species'], 'cachorro');
      expect(map['race'], 'Poodle');
      expect(map['ownerPhone'], isEmpty);
      expect(map['ownerAddress'], isEmpty);
    });

    test('persiste specifications e searchTokens atualizados', () {
      expect(map['specifications'], ['cachorro', 'macho', 'adocao', 'jovem']);
      final tokens = map['searchTokens'] as List;
      expect(tokens, contains('rex'));
      expect(tokens, contains('docil'));
    });

    test('exclui id, ownerId, createdAt e images (não alteráveis na edição)', () {
      expect(map.containsKey('id'), isFalse);
      expect(map.containsKey('ownerId'), isFalse);
      expect(map.containsKey('createdAt'), isFalse);
      expect(map.containsKey('images'), isFalse);
    });
  });

  group('ageLabel extension', () {
    test('retorna "1 ano" para age=1 e years', () {
      final pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 1,
        ageUnit: AppPetAgeUnit.years,
        gender: AppPetGender.male,
        address: 'São Paulo',
        images: [],
      );

      expect(pet.ageLabel, '1 ano');
    });

    test('retorna "3 anos" para age=3 e years', () {
      final pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 3,
        ageUnit: AppPetAgeUnit.years,
        gender: AppPetGender.male,
        address: 'São Paulo',
        images: [],
      );

      expect(pet.ageLabel, '3 anos');
    });

    test('retorna "1 mês" para age=1 e months', () {
      final pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 1,
        ageUnit: AppPetAgeUnit.months,
        gender: AppPetGender.male,
        address: 'São Paulo',
        images: [],
      );

      expect(pet.ageLabel, '1 mês');
    });

    test('retorna "6 meses" para age=6 e months', () {
      final pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 6,
        ageUnit: AppPetAgeUnit.months,
        gender: AppPetGender.male,
        address: 'São Paulo',
        images: [],
      );

      expect(pet.ageLabel, '6 meses');
    });

    test('retorna "1 dia" para age=1 e days', () {
      final pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 1,
        ageUnit: AppPetAgeUnit.days,
        gender: AppPetGender.male,
        address: 'São Paulo',
        images: [],
      );

      expect(pet.ageLabel, '1 dia');
    });

    test('retorna "15 dias" para age=15 e days', () {
      final pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 15,
        ageUnit: AppPetAgeUnit.days,
        gender: AppPetGender.male,
        address: 'São Paulo',
        images: [],
      );

      expect(pet.ageLabel, '15 dias');
    });
  });

  group('genderLabel extension', () {
    test('retorna "Macho" para male', () {
      final pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 3,
        gender: AppPetGender.male,
        address: 'São Paulo',
        images: [],
      );

      expect(pet.genderLabel, 'Macho');
    });

    test('retorna "Fêmea" para female', () {
      final pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Luna',
        age: 3,
        gender: AppPetGender.female,
        address: 'São Paulo',
        images: [],
      );

      expect(pet.genderLabel, 'Fêmea');
    });
  });

  group('speciesRaceLabel extension', () {
    test('retorna apenas a espécie quando a raça não foi informada', () {
      final pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 3,
        gender: AppPetGender.male,
        address: 'São Paulo',
        species: AppPetSpecies.dog,
        images: [],
      );

      expect(pet.speciesRaceLabel, 'Cachorro');
    });

    test('ignora espaços em branco na raça', () {
      final pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 3,
        gender: AppPetGender.male,
        address: 'São Paulo',
        species: AppPetSpecies.dog,
        race: '   ',
        images: [],
      );

      expect(pet.speciesRaceLabel, 'Cachorro');
    });

    test('retorna "Espécie · Raça" quando a raça é informada', () {
      final pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 3,
        gender: AppPetGender.male,
        address: 'São Paulo',
        species: AppPetSpecies.dog,
        race: 'Poodle',
        images: [],
      );

      expect(pet.speciesRaceLabel, 'Cachorro · Poodle');
    });
  });

  group('shareText extension', () {
    test('adoção: anúncio completo procurando um novo lar', () {
      const pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 2,
        ageUnit: AppPetAgeUnit.years,
        gender: AppPetGender.male,
        address: 'Rua das Flores, 123',
        description: 'Muito dócil.',
        publicationType: AppPetPublicationType.adoption,
        species: AppPetSpecies.dog,
        race: 'Poodle',
        ownerPhone: '(11) 99999-0000',
        images: [],
      );

      final expected = [
        '🐾 Rex está procurando um novo lar!',
        '',
        '💰 Adoção',
        'Cachorro · Poodle · 2 anos · Macho',
        '',
        'Muito dócil.',
        '',
        '📍 Rua das Flores, 123',
        '📞 (11) 99999-0000',
        '',
        '📲 Entre em contato direto no APPets',
      ].join('\n');

      expect(pet.shareText, expected);
    });

    test('perdido: apelo mostrando que o dono procura o pet', () {
      const pet = Pet(
        id: 'pet_002',
        ownerId: 'user_001',
        name: 'Luna',
        age: 6,
        ageUnit: AppPetAgeUnit.months,
        gender: AppPetGender.female,
        address: 'Campinas',
        description: 'Luna é muito carinhosa.',
        publicationType: AppPetPublicationType.lost,
        species: AppPetSpecies.cat,
        race: 'Persa',
        ownerPhone: '(19) 98888-7777',
        images: [],
      );

      final expected = [
        '🐾 AJUDA! Encontre o Luna!',
        '',
        '⚠️ Perdido',
        'Gato · Persa · 6 meses · Fêmea',
        '',
        'Luna é muito carinhosa.',
        '',
        '📍 Foi visto na região de: Campinas',
        '📞 Se encontrar, entre em contato: (19) 98888-7777',
        '',
        '📲 Entre em contato direto no APPets',
      ].join('\n');

      expect(pet.shareText, expected);
    });

    test('sem raça mantém apenas a espécie na identidade', () {
      const pet = Pet(
        id: 'pet_003',
        ownerId: 'user_001',
        name: 'Rex',
        age: 2,
        ageUnit: AppPetAgeUnit.years,
        gender: AppPetGender.male,
        address: 'São Paulo',
        publicationType: AppPetPublicationType.adoption,
        species: AppPetSpecies.dog,
        images: [],
      );

      expect(pet.shareText, contains('Cachorro · 2 anos · Macho'));
      expect(pet.shareText, isNot(contains('· ·')));
    });

    test('sem descrição, sem endereço e sem telefone omite as linhas', () {
      const pet = Pet(
        id: 'pet_004',
        ownerId: 'user_001',
        name: 'Rex',
        age: 2,
        ageUnit: AppPetAgeUnit.years,
        gender: AppPetGender.male,
        address: '   ',
        publicationType: AppPetPublicationType.lost,
        species: AppPetSpecies.dog,
        images: [],
      );

      expect(pet.shareText, isNot(contains('Muito dócil')));
      expect(pet.shareText, isNot(contains('📍')));
      expect(pet.shareText, isNot(contains('📞')));
      expect(pet.shareText, endsWith(PetDetailsStrings.SHARE_FOOTER));
    });
  });

  group('AppPetSpecies', () {
    test('expõe todas as espécies com rótulos', () {
      expect(AppPetSpecies.values, hasLength(8));
      expect(AppPetSpecies.dog.label, 'Cachorro');
      expect(AppPetSpecies.cat.label, 'Gato');
      expect(AppPetSpecies.rabbit.label, 'Coelho');
      expect(AppPetSpecies.hamster.label, 'Hamster');
      expect(AppPetSpecies.bird.label, 'Pássaro');
      expect(AppPetSpecies.turtle.label, 'Tartaruga');
      expect(AppPetSpecies.reptile.label, 'Réptil');
      expect(AppPetSpecies.other.label, 'Outro');
    });
  });
}
