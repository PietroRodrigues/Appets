import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_home.dart';
import 'package:appets/core/navigation/navigation_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/connectivity_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/my_publications_service.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/screens/screen_favorites.dart';
import 'package:appets/screens/screen_pet_details.dart';
import 'package:appets/widgets/feed/widget_pet_card.dart';

void main() {
  final service = PetService.instance;
  final connectivity = ConnectivityService.instance;
  late FakeFirebaseFirestore db;

  setUp(() {
    db = FakeFirebaseFirestore();
    service.debugDb = db;
    FirestoreService.instance.debugDb = db;
    service.debugFirstPageError = null;
    service.debugGetPetsByIdsCalls = 0;
    connectivity.debugOnline = true;
    AuthService.instance.debugAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'uid_1', email: 'ana@test.com'),
    );
    FavoritesService.instance.reset();
    MyPublicationsService.instance.reset();
    // A aba precisa estar ativa para o grid não suspender o stream.
    AppNavigation.selectedPage.value = AppPage.favorites;
  });

  tearDown(() {
    service.debugDb = null;
    FirestoreService.instance.debugDb = null;
    service.debugFirstPageError = null;
    service.debugGetPetsByIdsCalls = 0;
    connectivity.reset();
    AuthService.instance.debugAuth = null;
    FavoritesService.instance.reset();
    MyPublicationsService.instance.reset();
    AppNavigation.selectedPage.value = AppPage.home;
  });

  Map<String, dynamic> petDoc(String id) {
    return {
      'id': id,
      'ownerId': 'dono_a',
      'name': id,
      'age': 2,
      'ageUnit': 'anos',
      'gender': 'macho',
      'address': 'Rua 1',
      'ownerPhone': '',
      'ownerAddress': '',
      'description': '',
      'publicationType': 'adocao',
      'species': 'cachorro',
      'race': '',
      'searchTokens': const ['token'],
      'specifications': const ['cachorro', 'macho', 'adocao', 'jovem'],
      'images': const <String>[],
      'createdAt': DateTime(2024, 1, 1),
    };
  }

  Future<void> pumpFavorites(
    WidgetTester tester, {
    VoidCallback? onExplore,
  }) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: FavoritesScreen(onExplore: onExplore))),
    );
    await tester.pumpAndSettle();
  }

  //196
  testWidgets('estado vazio mostra o CTA de explorar e dispara onExplore',
      (tester) async {
    var explored = false;
    await pumpFavorites(tester, onExplore: () => explored = true);

    expect(find.text(HomeStrings.EMPTY_FAVORITES_TITLE), findsOneWidget);
    expect(find.text(HomeStrings.EMPTY_FAVORITES_DESCRIPTION), findsOneWidget);

    await tester.tap(find.text(HomeStrings.EXPLORE_PETS));
    await tester.pumpAndSettle();

    expect(explored, isTrue);
  });

  //197
  testWidgets('com favorito mostra o card e abre os detalhes ao tocar',
      (tester) async {
    FavoritesService.instance.favoriteIds.value = {'fido'};
    await db.collection('pets').doc('fido').set(petDoc('fido'));

    await pumpFavorites(tester);

    expect(find.byType(WGPetCard), findsOneWidget);

    await tester.tap(find.byType(WGPetCard));
    await tester.pumpAndSettle();

    expect(find.byType(PetDetailsScreen), findsOneWidget);
  });
}
