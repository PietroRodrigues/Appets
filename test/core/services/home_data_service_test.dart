import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/home_data_service.dart';
import 'package:appets/core/services/my_publications_service.dart';
import 'package:appets/core/services/pet_service.dart';

/// Carga inicial da Home centralizada num serviço: dedup, cache em memória,
/// force, captura de erro e reset.
void main() {
  final service = HomeDataService.instance;
  late FakeFirebaseFirestore db;

  setUp(() {
    db = FakeFirebaseFirestore();
    FirestoreService.instance.debugDb = db;
    FirestoreService.instance.debugGetUserError = null;
    PetService.instance.debugDb = db;
    FavoritesService.instance.reset();
    MyPublicationsService.instance.reset();
    service.reset();
  });

  tearDown(() {
    FirestoreService.instance.debugDb = null;
    FirestoreService.instance.debugGetUserError = null;
    PetService.instance.debugDb = null;
    AuthService.instance.debugAuth = null;
    FavoritesService.instance.reset();
    MyPublicationsService.instance.reset();
    service.reset();
  });

  void signIn(String uid) {
    AuthService.instance.debugAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: uid),
    );
  }

  Future<void> seedUser(
    String uid, {
    List<String> favorites = const <String>[],
    List<String> publications = const <String>[],
  }) {
    return db.collection('users').doc(uid).set({
      'name': 'Ana',
      'email': 'ana@test.com',
      'phone': '',
      'address': 'São Paulo',
      'photoUrl': '',
      'favoritePetIds': favorites,
      'myPublishedPetIds': publications,
    });
  }

  //89
  test('carrega o usuário e alimenta favoritos/publicações', () async {
    await seedUser('uid_1', favorites: ['pet_a'], publications: ['pet_b']);
    signIn('uid_1');

    await service.load();

    expect(service.loaded, isTrue);
    expect(service.error, isFalse);
    expect(service.user?.name, 'Ana');
    expect(FavoritesService.instance.isFavorite('pet_a'), isTrue);
    expect(MyPublicationsService.instance.isMine('pet_b'), isTrue);
  });

  //90
  test('sem sessão conclui carregado e sem usuário', () async {
    AuthService.instance.debugAuth = MockFirebaseAuth();

    await service.load();

    expect(service.loaded, isTrue);
    expect(service.error, isFalse);
    expect(service.user, isNull);
  });

  //91
  test('falha na leitura registra error sem lançar', () async {
    FirestoreService.instance.debugGetUserError = StateError('falha');
    signIn('uid_1');

    await service.load();

    expect(service.loaded, isTrue);
    expect(service.error, isTrue);
  });

  //92
  test('não relê quando já carregado (a menos que force)', () async {
    await seedUser('uid_1');
    signIn('uid_1');
    await service.load();
    expect(service.user?.name, 'Ana');

    // Muda o documento; sem force o cache em memória permanece.
    await db.collection('users').doc('uid_1').update({'name': 'Bia'});
    await service.load();
    expect(service.user?.name, 'Ana');

    await service.load(force: true);
    expect(service.user?.name, 'Bia');
  });

  //93
  test('chamadas concorrentes compartilham uma única leitura', () async {
    await seedUser('uid_1');
    signIn('uid_1');

    await Future.wait([service.load(), service.load(), service.load()]);

    expect(service.loaded, isTrue);
    expect(service.user?.name, 'Ana');
  });

  //94
  test('reset limpa o estado em memória', () async {
    await seedUser('uid_1');
    signIn('uid_1');
    await service.load();
    expect(service.loaded, isTrue);

    service.reset();

    expect(service.loaded, isFalse);
    expect(service.user, isNull);
    expect(service.error, isFalse);
  });
}
