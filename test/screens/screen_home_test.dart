import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/connectivity_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/my_publications_service.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/screens/screen_home.dart';

void main() {
  final connectivity = ConnectivityService.instance;
  late FakeFirebaseFirestore db;

  setUp(() {
    db = FakeFirebaseFirestore();
    FirestoreService.instance.debugDb = db;
    FirestoreService.instance.debugGetUserError = null;
    PetService.instance.debugDb = db;
    PetService.instance.debugFirstPageError = null;
    FavoritesService.instance.reset();
    MyPublicationsService.instance.reset();
    connectivity.debugOnline = true;
  });

  tearDown(() {
    FirestoreService.instance.debugDb = null;
    FirestoreService.instance.debugGetUserError = null;
    PetService.instance.debugDb = null;
    PetService.instance.debugFirstPageError = null;
    connectivity.reset();
  });

  Future<void> pumpHome(WidgetTester tester) async {
    AuthService.instance.debugAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'uid_1'),
    );

    await db.collection('users').doc('uid_1').set({
      'name': 'Ana',
      'email': 'ana@test.com',
      'phone': '(11) 99999-9999',
      'address': 'São Paulo',
      'photoUrl': '',
      'favoritePetIds': <String>[],
      'myPublishedPetIds': <String>[],
    });

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
  }

  testWidgets('falha na carga inicial mostra estado de erro com retry', (
    tester,
  ) async {
    FirestoreService.instance.debugGetUserError = StateError('falha');

    await pumpHome(tester);

    expect(find.text(SharedStrings.LOAD_DATA_ERROR_TITLE), findsOneWidget);
  });

  testWidgets('retry após a falha recarrega e sai do estado de erro', (
    tester,
  ) async {
    FirestoreService.instance.debugGetUserError = StateError('falha');
    await pumpHome(tester);
    expect(find.text(SharedStrings.LOAD_DATA_ERROR_TITLE), findsOneWidget);

    FirestoreService.instance.debugGetUserError = null;
    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();

    expect(find.text(SharedStrings.LOAD_DATA_ERROR_TITLE), findsNothing);
  });
}
