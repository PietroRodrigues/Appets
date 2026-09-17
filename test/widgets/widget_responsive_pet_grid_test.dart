import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/services/pet_service.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/widgets/feed/widget_responsive_pet_grid.dart';
import 'package:appets/widgets/filters/widget_pet_filters_sheet.dart';

void main() {
  final service = PetService.instance;
  final now = DateTime(2024, 1, 1);
  late FakeFirebaseFirestore db;

  setUp(() {
    db = FakeFirebaseFirestore();
    service.debugDb = db;
  });

  tearDown(() {
    service.debugDb = null;
  });

  Widget wrap({
    required ValueNotifier<List<PetFilterOption>>? filters,
    required Widget Function(BuildContext, Pet) itemBuilder,
    Widget Function(BuildContext)? emptyBuilder,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: WGResponsivePetGrid(
          filter: AppPetFilter.all,
          filterOptions: filters,
          itemBuilder: itemBuilder,
          emptyBuilder: emptyBuilder,
        ),
      ),
    );
  }

  Map<String, dynamic> petDoc(
    String id, {
    required String species,
    required String gender,
    required DateTime createdAt,
  }) {
    return {
      'id': id,
      'ownerId': 'dono_a',
      'name': id,
      'age': 2,
      'ageUnit': 'anos',
      'gender': gender,
      'address': 'Rua 1',
      'ownerPhone': '',
      'ownerAddress': '',
      'description': '',
      'publicationType': 'adocao',
      'species': species,
      'race': '',
      'searchTokens': const ['token'],
      'specifications': [species, gender, 'adocao', 'jovem'],
      'images': const [],
      'createdAt': createdAt,
    };
  }

  Future<void> insertPet(Map<String, dynamic> data) {
    return db.collection('pets').doc(data['id'] as String).set(data);
  }

  group('WGResponsivePetGrid · filtro ativo com página vazia (1.7)', () {
    testWidgets(
      'auto-avança até achar correspondências nas páginas seguintes',
      (tester) async {
        // Os 22 cachorros macho são os mais novos (1ª página sem match),
        // as fêmeas que casam com o filtro estão nas páginas seguintes.
        for (var i = 0; i < 22; i++) {
          await insertPet(
            petDoc(
              'cachorro_macho_$i',
              species: 'cachorro',
              gender: 'macho',
              createdAt: now.add(Duration(minutes: 8 + i)),
            ),
          );
        }
        for (var i = 0; i < 3; i++) {
          await insertPet(
            petDoc(
              'cachorro_femea_$i',
              species: 'cachorro',
              gender: 'femea',
              createdAt: now.add(Duration(minutes: 5 + i)),
            ),
          );
        }
        for (var i = 0; i < 5; i++) {
          await insertPet(
            petDoc(
              'gato_femea_$i',
              species: 'gato',
              gender: 'femea',
              createdAt: now.add(Duration(minutes: i)),
            ),
          );
        }

        final filters = ValueNotifier<List<PetFilterOption>>(
          const [
            PetFilterOption(
              category: PetFilterCategory.species,
              value: 'cachorro',
              label: 'Cachorro',
            ),
            PetFilterOption(
              category: PetFilterCategory.gender,
              value: 'femea',
              label: 'Fêmea',
            ),
          ],
        );

        await tester.pumpWidget(
          wrap(
            filters: filters,
            itemBuilder: (context, pet) => Text(pet.name),
            emptyBuilder: (_) => const Text('VAZIO'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('cachorro_femea_'), findsNWidgets(3));
        expect(find.text('VAZIO'), findsNothing);
      },
    );

    testWidgets(
      'sem correspondências em nenhuma página termina no vazio sem loop',
      (tester) async {
        for (var i = 0; i < 25; i++) {
          await insertPet(
            petDoc(
              'cachorro_macho_$i',
              species: 'cachorro',
              gender: 'macho',
              createdAt: now.add(Duration(minutes: i)),
            ),
          );
        }

        final filters = ValueNotifier<List<PetFilterOption>>(
          const [
            PetFilterOption(
              category: PetFilterCategory.species,
              value: 'cachorro',
              label: 'Cachorro',
            ),
            PetFilterOption(
              category: PetFilterCategory.gender,
              value: 'femea',
              label: 'Fêmea',
            ),
          ],
        );

        await tester.pumpWidget(
          wrap(
            filters: filters,
            itemBuilder: (context, pet) => Text(pet.name),
            emptyBuilder: (_) => const Text('VAZIO'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('VAZIO'), findsOneWidget);
        expect(find.textContaining('cachorro_macho_'), findsNothing);
      },
    );
  });
}