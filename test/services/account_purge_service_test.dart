import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/services/account_purge_service.dart';
import 'package:appets/core/services/app_image_cache.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/my_publications_service.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/core/services/storage_service.dart';
import 'package:appets/widgets/feedback/widget_process.dart';

// Os mocks do firebase_auth_mocks já declaram campos não-finais.
// ignore_for_file: must_be_immutable

/// Metadados com login recente (permite excluir sem reautenticar).
class _RecentUserMetadata extends UserMetadata {
  _RecentUserMetadata()
      : super(
          DateTime.now().millisecondsSinceEpoch,
          DateTime.now().millisecondsSinceEpoch,
        );
}

/// MockUser que conta as chamadas de delete.
class _TrackingUser extends MockUser {
  _TrackingUser({super.uid, super.email, super.metadata});

  int deleteCalls = 0;

  @override
  Future<void> delete() async {
    deleteCalls++;
  }
}

/// MockUser cuja primeira exclusão exige login recente (e a segunda passa).
class _RequiresReauthFirstUser extends MockUser {
  _RequiresReauthFirstUser()
      : super(
          uid: 'uid_test',
          email: 'a@test.com',
          metadata: _RecentUserMetadata(),
        );

  int deleteCalls = 0;

  @override
  Future<void> delete() async {
    deleteCalls++;
    if (deleteCalls == 1) {
      throw FirebaseAuthException(
        code: 'requires-recent-login',
        message: 'Recent login required.',
      );
    }
  }
}

/// Cache de imagens falso: não toca disco/plugin nos testes.
class _FakeImageCache implements BaseCacheManager {
  @override
  Future<void> emptyCache() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Storage fake: registra as exclusões por URL (avatar e fotos dos pets).
class _FakeStorage implements FirebaseStorage {
  /// Quando definido, todo delete lança este erro (prova o best-effort).
  Object? deleteError;

  final List<String> deletedUrls = [];

  @override
  Reference refFromURL(String url) => _FakeReference(this, url);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeReference implements Reference {
  _FakeReference(this.storage, this.url);

  @override
  final _FakeStorage storage;
  final String url;

  @override
  Future<void> delete() async {
    final error = storage.deleteError;
    if (error != null) throw error;
    storage.deletedUrls.add(url);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late FakeFirebaseFirestore db;
  late _FakeStorage storage;
  final service = AccountPurgeService.instance;
  final favorites = FavoritesService.instance;
  final myPublications = MyPublicationsService.instance;

  setUp(() {
    db = FakeFirebaseFirestore();
    storage = _FakeStorage();
    FirestoreService.instance.debugDb = db;
    PetService.instance.debugDb = db;
    StorageService.instance.debugStorage = storage;
    favorites.reset();
    myPublications.reset();
    AppImageCache.instance.debugManager = _FakeImageCache();
  });

  tearDown(() {
    AppImageCache.instance.debugManager = null;
    StorageService.instance.debugStorage = null;
  });

  Future<_TrackingUser> seedUser({UserMetadata? metadata}) async {
    final user = _TrackingUser(uid: 'uid_test', email: 'a@test.com', metadata: metadata);
    AuthService.instance.debugAuth = MockFirebaseAuth(signedIn: true, mockUser: user);

    await db.collection('users').doc('uid_test').set({
      'name': 'Ana',
      'email': 'a@test.com',
      'phone': '',
      'address': '',
      'photoUrl': '',
      'favoritePetIds': <String>[],
      'myPublishedPetIds': <String>[],
    });

    await db.collection('pets').doc('pet_1').set({
      'ownerId': 'uid_test',
      'name': 'Rex',
      'images': ['https://firebasestorage/photo.jpg'],
    });
    return user;
  }

  group('AccountPurgeService · isSessionRecent', () {
    //244
    test('sessão sem histórico é considerada antiga', () {
      final user = _TrackingUser(uid: 'u', email: 'a@test.com');
      expect(service.isSessionRecent(user), isFalse);
    });

    //245
    test('sessão recente é reconhecida', () {
      final user = _TrackingUser(
        uid: 'u',
        email: 'a@test.com',
        metadata: _RecentUserMetadata(),
      );
      expect(service.isSessionRecent(user), isTrue);
    });
  });

  group('AccountPurgeService · deleteAccount', () {
    //246
    test('sucesso com reautenticação para sessão antiga', () async {
      final user = await seedUser();
      var reauthCalled = 0;
      favorites.favoriteIds.value = {'pet_1'};
      myPublications.myPetIds.value = {'pet_1'};

      final result = await service.deleteAccount(
        user: user,
        onReauthenticate: () async {
          reauthCalled++;
          return const WGProcessResult.success();
        },
      );

      expect(result.status, WGProcessStatus.success);
      expect(reauthCalled, 1);
      expect(user.deleteCalls, 1);
      expect(favorites.current, isEmpty);
      expect(myPublications.current, isEmpty);
      expect(await db.collection('pets').doc('pet_1').get().then((d) => d.exists),
          isFalse);
      expect(await db.collection('users').doc('uid_test').get().then((d) => d.exists),
          isFalse);
    });

    //247
    test('sucesso sem reautenticação quando a sessão é recente', () async {
      final user = await seedUser(metadata: _RecentUserMetadata());
      var reauthCalled = 0;

      final result = await service.deleteAccount(
        user: user,
        onReauthenticate: () async {
          reauthCalled++;
          return const WGProcessResult.success();
        },
      );

      expect(result.status, WGProcessStatus.success);
      expect(reauthCalled, 0);
      expect(user.deleteCalls, 1);
    });

    //248
    test('exclui também pets legados sem createdAt (sem órfãos)', () async {
      final user = await seedUser(metadata: _RecentUserMetadata());
      // Pet legado: documento sem o campo createdAt. O Firestore real o
      // excluiria de leituras com orderBy('createdAt'); a leitura
      // tolerante (sem orderBy) garante que ele também é apagado.
      await db.collection('pets').doc('pet_legado').set({
        'ownerId': 'uid_test',
        'name': 'Bob',
        'images': <String>[],
      });

      final result = await service.deleteAccount(
        user: user,
        onReauthenticate: () async => const WGProcessResult.success(),
      );

      expect(result.status, WGProcessStatus.success);
      expect(user.deleteCalls, 1);
      for (final id in ['pet_1', 'pet_legado']) {
        final exists =
            await db.collection('pets').doc(id).get().then((d) => d.exists);
        expect(exists, isFalse, reason: 'pet $id deveria ser apagado');
      }
    });

    //249
    test('reauth cancelado aborta a exclusão antes de apagar dados', () async {
      final user = await seedUser();
      favorites.favoriteIds.value = {'pet_1'};

      final result = await service.deleteAccount(
        user: user,
        onReauthenticate: () async => const WGProcessResult.canceled(),
      );

      expect(result.status, WGProcessStatus.canceled);
      expect(user.deleteCalls, 0);
      expect(await db.collection('pets').doc('pet_1').get().then((d) => d.exists),
          isTrue);
      expect(favorites.current, {'pet_1'});
    });

    //250
    test('falha na limpeza dos dados aborta antes de excluir no Auth',
        () async {
      final user = await seedUser();
      // Tira o fake do PetService: sem fake, o getter resolve o Firestore
      // real, que em teste lança `[core/no-app]`, fazendo a limpeza
      // devolver `false`.
      PetService.instance.debugDb = null;
      var reauthCalled = 0;

      final result = await service.deleteAccount(
        user: user,
        onReauthenticate: () async {
          reauthCalled++;
          return const WGProcessResult.success();
        },
      );

      expect(result.status, WGProcessStatus.failure);
      expect(user.deleteCalls, 0);
      expect(reauthCalled, 1);
    });

    //251
    test('requires-recent-login no Auth dispara reauth e tenta de novo',
        () async {
      final user = _RequiresReauthFirstUser();
      AuthService.instance.debugAuth =
          MockFirebaseAuth(signedIn: true, mockUser: user);
      await db.collection('users').doc('uid_test').set({'name': 'Ana'});
      await db.collection('pets').doc('pet_1').set({
        'ownerId': 'uid_test',
        'name': 'Rex',
        'images': <String>[],
      });
      var reauthCalled = 0;

      final result = await service.deleteAccount(
        user: user,
        onReauthenticate: () async {
          reauthCalled++;
          return const WGProcessResult.success();
        },
      );

      expect(result.status, WGProcessStatus.success);
      expect(user.deleteCalls, 2);
      expect(reauthCalled, 1);
    });

    //617
    test('exclui o avatar do Storage junto com os dados da conta', () async {
      final user = await seedUser(metadata: _RecentUserMetadata());
      await db.collection('users').doc('uid_test').update({
        'photoUrl': 'https://cdn.example.com/avatar.webp',
      });

      final result = await service.deleteAccount(
        user: user,
        onReauthenticate: () async => const WGProcessResult.success(),
      );

      expect(result.status, WGProcessStatus.success);
      // Tudo o que era do dono sai do Storage: as fotos dos pets e o
      // avatar lido do documento antes da exclusão.
      expect(
        storage.deletedUrls,
        contains('https://cdn.example.com/avatar.webp'),
      );
      expect(
        storage.deletedUrls,
        contains('https://firebasestorage/photo.jpg'),
      );
      expect(storage.deletedUrls, hasLength(2));
    });

    //618
    test('falha nas exclusões do Storage não aborta a exclusão da conta',
        () async {
      final user = await seedUser(metadata: _RecentUserMetadata());
      await db.collection('users').doc('uid_test').update({
        'photoUrl': 'https://cdn.example.com/avatar.webp',
      });
      storage.deleteError = Exception('storage down');

      final result = await service.deleteAccount(
        user: user,
        onReauthenticate: () async => const WGProcessResult.success(),
      );

      expect(result.status, WGProcessStatus.success);
      expect(user.deleteCalls, 1);
      expect(
        await db
            .collection('users')
            .doc('uid_test')
            .get()
            .then((d) => d.exists),
        isFalse,
      );
    });
  });
}