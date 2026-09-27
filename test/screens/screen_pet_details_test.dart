import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_pet_details.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/screens/screen_pet_details.dart';

/// Dados de teste para um pet (sem fotos, para a galeria usar o placeholder).
Pet _createTestPet() {
  return Pet(
    id: 'pet_test_001',
    ownerId: 'user_test_001',
    name: 'Rex',
    age: 2,
    ageUnit: AppPetAgeUnit.years,
    gender: AppPetGender.male,
    address: 'São Paulo',
    description: 'Pet de teste.',
    publicationType: AppPetPublicationType.adoption,
    images: const [],
  );
}

void main() {
  group('PetDetailsScreen → favorito', () {
    late FakeFirebaseFirestore db;

    setUp(() async {
      db = FakeFirebaseFirestore();
      FirestoreService.instance.debugDb = db;
      await db
          .collection('users')
          .doc('user_test_001')
          .set({'name': 'Ana'});
      AuthService.instance.debugAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user_test_001'),
      );
      FavoritesService.instance.reset();
    });

    tearDown(() {
      FirestoreService.instance.debugDb = null;
      FirestoreService.instance.debugAddFavoriteError = null;
      FirestoreService.instance.debugRemoveFavoriteError = null;
      AuthService.instance.debugAuth = null;
      FavoritesService.instance.reset();
    });

    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: PetDetailsScreen(pet: _createTestPet())),
      );
    }

    testWidgets('favoritar com sucesso não mostra aviso', (tester) async {
      await pumpScreen(tester);

      expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.star_border_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      expect(find.text(PetDetailsStrings.FAVORITE_ERROR), findsNothing);
      expect(
        FavoritesService.instance.favoriteIds.value,
        contains('pet_test_001'),
      );
    });

    testWidgets('falha ao favoritar mostra aviso (e não o "salvar")', (
      tester,
    ) async {
      FirestoreService.instance.debugAddFavoriteError = StateError('falha');
      await pumpScreen(tester);

      await tester.tap(find.byIcon(Icons.star_border_rounded));
      await tester.pumpAndSettle();

      expect(find.text(PetDetailsStrings.FAVORITE_ERROR), findsOneWidget);
      // O texto errado "salvar" não aparece mais no favorito.
      expect(
        find.text('Não foi possível salvar. Tente novamente.'),
        findsNothing,
      );
      // O otimista foi revertido: estrela continua vazia.
      expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);

      // Drena o timer do SnackBar para não deixar pendente.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });
  });
}