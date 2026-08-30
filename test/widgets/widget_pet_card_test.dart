import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/widgets/main/widget_pet_card.dart';

/// Dados de teste para um pet.
Pet _createTestPet({
  String id = 'pet_test_001',
  String name = 'Rex',
  int age = 3,
  AppPetAgeUnit ageUnit = AppPetAgeUnit.years,
  AppPetGender gender = AppPetGender.male,
  String city = 'São Paulo',
  AppPetPublicationType publicationType = AppPetPublicationType.adoption,
}) {
  return Pet(
    id: id,
    ownerId: 'user_test_001',
    name: name,
    age: age,
    ageUnit: ageUnit,
    gender: gender,
    city: city,
    description: 'Pet de teste.',
    publicationType: publicationType,
    images: ['assets/images/dog.png'],
  );
}

void main() {
  group('AppPetCard', () {
    testWidgets('exibe o nome do pet', (tester) async {
      final pet = _createTestPet(name: 'Thor');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPetCard(pet: pet),
          ),
        ),
      );

      expect(find.text('Thor'), findsOneWidget);
    });

    testWidgets('exibe o gênero formatado', (tester) async {
      final pet = _createTestPet(gender: AppPetGender.female);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPetCard(pet: pet),
          ),
        ),
      );

      expect(find.text('Fêmea'), findsOneWidget);
    });

    testWidgets('exibe a cidade', (tester) async {
      final pet = _createTestPet(city: 'Campinas');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPetCard(pet: pet),
          ),
        ),
      );

      expect(find.text('Campinas'), findsOneWidget);
    });

    testWidgets('exibe tipo de publicação "Adoção"', (tester) async {
      final pet = _createTestPet(
        publicationType: AppPetPublicationType.adoption,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPetCard(pet: pet),
          ),
        ),
      );

      expect(find.text('Adoção'), findsOneWidget);
    });

    testWidgets('exibe tipo de publicação "Perdido"', (tester) async {
      final pet = _createTestPet(
        publicationType: AppPetPublicationType.lost,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPetCard(pet: pet),
          ),
        ),
      );

      expect(find.text('Perdido'), findsOneWidget);
    });

    testWidgets('chama onTap ao tocar no card', (tester) async {
      var tapped = false;
      final pet = _createTestPet();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPetCard(
              pet: pet,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Usa o primeiro InkWell (o do card principal, não o da estrela).
      final inkWells = find.byType(InkWell);
      await tester.tap(inkWells.first);
      expect(tapped, isTrue);
    });

    testWidgets('exibe botão de edição quando isMyPublication é true',
        (tester) async {
      final pet = _createTestPet();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPetCard(
              pet: pet,
              isMyPublication: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('não exibe botão de edição quando isMyPublication é false',
        (tester) async {
      final pet = _createTestPet();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPetCard(
              pet: pet,
              isMyPublication: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit_outlined), findsNothing);
    });
  });
}
