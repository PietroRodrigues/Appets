import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_pet_details.dart';
import 'package:appets/core/extensions/extension_pet_display.dart';
import 'package:appets/core/utils/search_tokens.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';

void main() {
  group('Pet model', () {
    //139
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

    //140
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
      gender: AppPetGender.male,
      address: 'São Paulo',
      description: 'Muito dócil.',
      race: 'Poodle',
      images: ['a.png', 'b.png'],
    );

    Map<String, dynamic> map = {};

    setUp(() {
      map = original.toMap();
    });

    //141
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

    //142
    test('toMap omite weight quando não informado', () {
      expect(map.containsKey('weight'), isFalse);
    });

    //143
    test('toMap grava weight quando definido', () {
      final comPeso = Pet(
        id: 'pet_002',
        ownerId: 'user_001',
        name: 'Rex',
        age: 2,
        gender: AppPetGender.male,
        address: 'São Paulo',
        weight: 12.5,
        images: [],
      );

      expect(comPeso.toMap()['weight'], 12.5);
    });

    //144
    test('toMap persiste specifications (1 token por categoria, em PT)', () {
      expect(map['specifications'], ['cachorro', 'macho', 'adocao', 'jovem']);
    });

    //145
    test('pet.specifications deriva dos campos atuais', () {
      expect(original.specifications, ['cachorro', 'macho', 'adocao', 'jovem']);

      final diferente = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Frajola',
        age: 6,
        gender: AppPetGender.female,
        address: 'Rio',
        publicationType: AppPetPublicationType.lost,
        species: AppPetSpecies.cat,
        images: [],
      );
      expect(diferente.specifications, ['gato', 'femea', 'perdido', 'adulto']);
    });

    //146
    test('toMap persiste searchTokens normalizados para a busca', () {
      final tokens = map['searchTokens'] as List;
      expect(tokens, containsAll(buildSearchTokens(name: 'Rex')));
      expect(tokens, contains('docil'));
    });

    //147
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

    //148
    test('fromMap restaura weight (double) e tolera int/ausência', () {
      final fromDouble = Pet.fromMap('pet_001', {
        ...map,
        'weight': 12.5,
      });
      expect(fromDouble.weight, 12.5);

      // Firestore pode devolver inteiros num campo numérico.
      final fromInt = Pet.fromMap('pet_001', {
        ...map,
        'weight': 12,
      });
      expect(fromInt.weight, 12.0);

      final semPeso = Pet.fromMap('pet_001', map);
      expect(semPeso.weight, isNull);
    });

    //149
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

    //150
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

    //151
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

    //152
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

    //153
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

    //154
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
      gender: AppPetGender.male,
      address: 'São Paulo',
      description: 'Muito dócil.',
      race: 'Poodle',
      images: ['a.png', 'b.png'],
    );

    late Map<String, dynamic> map;

    setUp(() {
      map = pet.toUpdateMap();
    });

    //155
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

    //156
    test('persiste specifications e searchTokens atualizados', () {
      expect(map['specifications'], ['cachorro', 'macho', 'adocao', 'jovem']);
      final tokens = map['searchTokens'] as List;
      expect(tokens, contains('rex'));
      expect(tokens, contains('docil'));
    });

    //157
    test('exclui id, ownerId, createdAt e images (não alteráveis na edição)', () {
      expect(map.containsKey('id'), isFalse);
      expect(map.containsKey('ownerId'), isFalse);
      expect(map.containsKey('createdAt'), isFalse);
      expect(map.containsKey('images'), isFalse);
    });

    //158
    test('compartilha os mesmos campos editáveis do toMap', () {
      // A unificação (helper comum) garante que todo campo do update
      // existe no create com o MESMO valor — só ownerId/images/createdAt
      // são exclusivos do create.
      final create = pet.toMap();
      expect(create.keys.toSet().containsAll(map.keys.toSet()), isTrue);
      for (final key in map.keys) {
        expect(create[key], map[key], reason: 'campo divergente: $key');
      }
    });
  });

  group('ageLabel extension', () {
    //159
    test('retorna "1 ano" para age=1 e years', () {
      final pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 1,
        gender: AppPetGender.male,
        address: 'São Paulo',
        images: [],
      );

      expect(pet.ageLabel, '1 ano');
    });

    //160
    test('retorna "3 anos" para age=3 e years', () {
      final pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 3,
        gender: AppPetGender.male,
        address: 'São Paulo',
        images: [],
      );

      expect(pet.ageLabel, '3 anos');
    });

    //161
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

    //162
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

    //163
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

    //164
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
    //165
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

    //166
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

  group('weightLabel extension', () {
    //167
    test('formata peso decimal com vírgula e "kg"', () {
      final pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 3,
        gender: AppPetGender.male,
        address: 'São Paulo',
        weight: 12.5,
        images: [],
      );

      expect(pet.weightLabel, '12,5 kg');
    });

    //168
    test('peso inteiro sem ",0" e null quando não informado', () {
      final inteiro = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 3,
        gender: AppPetGender.male,
        address: 'São Paulo',
        weight: 12,
        images: [],
      );
      expect(inteiro.weightLabel, '12 kg');

      final semPeso = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 3,
        gender: AppPetGender.male,
        address: 'São Paulo',
        images: [],
      );
      expect(semPeso.weightLabel, isNull);
    });
  });

  group('speciesRaceLabel extension', () {
    //169
    test('retorna apenas a espécie quando a raça não foi informada', () {
      final pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 3,
        gender: AppPetGender.male,
        address: 'São Paulo',
        images: [],
      );

      expect(pet.speciesRaceLabel, 'Cachorro');
    });

    //170
    test('ignora espaços em branco na raça', () {
      final pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 3,
        gender: AppPetGender.male,
        address: 'São Paulo',
        race: '   ',
        images: [],
      );

      expect(pet.speciesRaceLabel, 'Cachorro');
    });

    //171
    test('retorna "Espécie · Raça" quando a raça é informada', () {
      final pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 3,
        gender: AppPetGender.male,
        address: 'São Paulo',
        race: 'Poodle',
        images: [],
      );

      expect(pet.speciesRaceLabel, 'Cachorro · Poodle');
    });
  });

  group('shareText extension', () {
    //172
    test('adoção: anúncio completo procurando um novo lar', () {
      const pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 2,
        gender: AppPetGender.male,
        address: 'Rua das Flores, 123',
        description: 'Muito dócil.',
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

    //173
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

    //174
    test('sem raça mantém apenas a espécie na identidade', () {
      const pet = Pet(
        id: 'pet_003',
        ownerId: 'user_001',
        name: 'Rex',
        age: 2,
        gender: AppPetGender.male,
        address: 'São Paulo',
        images: [],
      );

      expect(pet.shareText, contains('Cachorro · 2 anos · Macho'));
      expect(pet.shareText, isNot(contains('· ·')));
    });

    //175
    test('inclui o peso na identidade quando informado', () {
      const pet = Pet(
        id: 'pet_005',
        ownerId: 'user_001',
        name: 'Rex',
        age: 2,
        gender: AppPetGender.male,
        address: 'São Paulo',
        weight: 12.5,
        images: [],
      );

      expect(pet.shareText, contains('Cachorro · 2 anos · Macho · 12,5 kg'));
    });

    //176
    test('sem descrição, sem endereço e sem telefone omite as linhas', () {
      const pet = Pet(
        id: 'pet_004',
        ownerId: 'user_001',
        name: 'Rex',
        age: 2,
        gender: AppPetGender.male,
        address: '   ',
        publicationType: AppPetPublicationType.lost,
        images: [],
      );

      expect(pet.shareText, isNot(contains('Muito dócil')));
      expect(pet.shareText, isNot(contains('📍')));
      expect(pet.shareText, isNot(contains('📞')));
      expect(pet.shareText, endsWith(PetDetailsStrings.SHARE_FOOTER));
    });
  });

  group('AppPetSpecies', () {
    //177
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
