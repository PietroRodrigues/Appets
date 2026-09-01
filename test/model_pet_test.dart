import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/extensions/extension_pet_display.dart';
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
      expect(pet.name, 'Rex');
      expect(pet.age, 3);
      expect(pet.gender, AppPetGender.male);
      expect(pet.address, 'São Paulo');
      expect(pet.description, isNull);
      expect(pet.ageUnit, AppPetAgeUnit.years);
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
        images: ['assets/images/dog.png'],
      );

      expect(pet.description, 'Luna é muito carinhosa.');
      expect(pet.ageUnit, AppPetAgeUnit.months);
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

    test('fromMap ignora elementos não-string em images (dados corrompidos)',
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
    });

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
}
