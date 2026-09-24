import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_home.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/services/app_image_cache.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/connectivity_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/my_publications_service.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/core/services/storage_service.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/models/user_model.dart';
import 'package:appets/screens/screen_my_publications.dart';
import 'package:appets/widgets/feed/widget_pet_card.dart';
import 'package:appets/widgets/feedback/widget_loading.dart';

/// Cache que falha na hora: faz a imagem de rede do card cair no placeholder
/// imediatamente, sem rede e sem animação infinita nos testes.
class _FailingCacheManager implements BaseCacheManager {
  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) {
    return Stream<FileResponse>.error(StateError('rede indisponível em testes'));
  }

  // Métodos não usados pelo CachedNetworkImage nestes testes.
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Storage fake que segura a exclusão das fotos até [gate] completar,
/// permitindo observar a tela de carregamento ainda aberta.
class _GatedStorage implements FirebaseStorage {
  _GatedStorage(this.gate);

  final Completer<void> gate;

  @override
  Reference refFromURL(String url) => _GatedReference(gate);

  @override
  Reference ref([String? path]) => _GatedReference(gate);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _GatedReference implements Reference {
  _GatedReference(this.gate);

  final Completer<void> gate;

  @override
  Future<void> delete() => gate.future;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late FakeFirebaseFirestore db;

  setUp(() {
    ConnectivityService.instance.debugOnline = true;
    AuthService.instance.debugAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'user_test_001'),
    );
    AppImageCache.instance.debugManager = _FailingCacheManager();
  });

  tearDown(() {
    ConnectivityService.instance.reset();
    AuthService.instance.debugAuth = null;
    AppImageCache.instance.debugManager = null;
    FirestoreService.instance.debugDb = null;
    PetService.instance.debugDb = null;
    PetService.instance.debugDeletePetError = null;
    StorageService.instance.debugStorage = null;
    FavoritesService.instance.reset();
    MyPublicationsService.instance.reset();
  });

  Pet publication(String id, {List<String> images = const []}) {
    return Pet(
      id: id,
      ownerId: 'user_test_001',
      name: 'Rex',
      age: 2,
      ageUnit: AppPetAgeUnit.years,
      gender: AppPetGender.male,
      address: 'São Paulo',
      ownerPhone: '(11) 98765-4321',
      ownerAddress: 'São Paulo',
      description: 'Muito dócil.',
      publicationType: AppPetPublicationType.lost,
      species: AppPetSpecies.dog,
      race: 'Poodle',
      images: images,
    );
  }

  Future<void> seed(Pet pet) async {
    FirestoreService.instance.debugDb = db;
    PetService.instance.debugDb = db;

    final user = UserModel(
      id: 'user_test_001',
      name: 'Pietro',
      email: 'pietro@teste.com',
      phone: '(11) 98765-4321',
      address: 'São Paulo',
      myPublishedPetIds: [pet.id],
    );
    await db.collection('users').doc(user.id).set(user.toMap());
    await db
        .collection('pets')
        .doc(pet.id)
        .set(Map<String, dynamic>.of(pet.toMap())
          ..['createdAt'] = DateTime(2024, 1, 1));

    await MyPublicationsService.instance.loadForUser(user.id);
  }

  Finder deleteButton() => find.descendant(
    of: find.byType(WGPetCard),
    matching: find.byIcon(Icons.close),
  );

  Future<void> confirmAndRun(WidgetTester tester) async {
    await tester.tap(deleteButton());
    await tester.pumpAndSettle();
    expect(find.text(HomeStrings.DELETE_PET_CONFIRM_TITLE), findsOneWidget);

    await tester.tap(find.text(SharedStrings.YES));
  }

  testWidgets('excluir publicação mostra o loading e conclui com sucesso', (
    tester,
  ) async {
    db = FakeFirebaseFirestore();
    final pet = publication('pet_001', images: ['https://exemplo.com/foto_0.jpg']);
    await seed(pet);

    final gate = Completer<void>();
    StorageService.instance.debugStorage = _GatedStorage(gate);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MyPublicationsScreen())),
    );

    // O grid carrega e mostra o card da publicação.
    await tester.pumpAndSettle();
    expect(find.byType(WGPetCard), findsOneWidget);

    // Confirma a exclusão.
    await confirmAndRun(tester);
    // A tela de processo abre com a tarefa presa no gate (fotos).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text(HomeStrings.DELETE_PET_LOADING), findsOneWidget);
    expect(find.byType(WGLoading), findsOneWidget);

    // Libera a exclusão e espera o desfecho.
    gate.complete();
    await tester.pumpAndSettle();

    expect(find.text(SharedStrings.SUCCESS_TITLE), findsOneWidget);
    expect(find.text(HomeStrings.DELETE_PET_SUCCESS), findsOneWidget);
    expect((await db.collection('pets').doc(pet.id).get()).data(), isNull);
    expect(MyPublicationsService.instance.current, isNot(contains(pet.id)));

    // O grid reflete o estado vazio após a exclusão.
    expect(find.byType(WGPetCard), findsNothing);
    expect(find.text(HomeStrings.EMPTY_PUBLICATIONS_TITLE), findsOneWidget);
  });

  testWidgets('falha ao excluir mostra erro e nada é removido', (
    tester,
  ) async {
    db = FakeFirebaseFirestore();
    final pet = publication('pet_001');
    await seed(pet);
    PetService.instance.debugDeletePetError = Exception('falha no servidor');

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MyPublicationsScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.byType(WGPetCard), findsOneWidget);

    await confirmAndRun(tester);
    await tester.pumpAndSettle();

    expect(find.text(SharedStrings.ERROR_TITLE), findsOneWidget);
    expect(
      find.textContaining(HomeStrings.DELETE_PET_ERROR),
      findsOneWidget,
    );
    expect(find.textContaining('falha no servidor'), findsOneWidget);
    expect((await db.collection('pets').doc(pet.id).get()).data(), isNotNull);
    expect(MyPublicationsService.instance.current, contains(pet.id));
  });

  testWidgets('cancelar a confirmação não inicia a exclusão', (tester) async {
    db = FakeFirebaseFirestore();
    final pet = publication('pet_001');
    await seed(pet);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MyPublicationsScreen())),
    );
    await tester.pumpAndSettle();

    await tester.tap(deleteButton());
    await tester.pumpAndSettle();
    await tester.tap(find.text(SharedStrings.NO));
    await tester.pumpAndSettle();

    expect(find.byType(WGLoading), findsNothing);
    expect((await db.collection('pets').doc(pet.id).get()).data(), isNotNull);
    expect(MyPublicationsService.instance.current, contains(pet.id));
  });
}