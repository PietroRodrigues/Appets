import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/services/account_purge_service.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/my_publications_service.dart';
import 'package:appets/core/services/pet_service.dart';
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

void main() {
  late FakeFirebaseFirestore db;
  final service = AccountPurgeService.instance;
  final favorites = FavoritesService.instance;
  final myPublications = MyPublicationsService.instance;

  setUp(() {
    db = FakeFirebaseFirestore();
    FirestoreService.instance.debugDb = db;
    PetService.instance.debugDb = db;
    favorites.reset();
    myPublications.reset();
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
    test('sessão sem histórico é considerada antiga', () {
      final user = _TrackingUser(uid: 'u', email: 'a@test.com');
      expect(service.isSessionRecent(user), isFalse);
    });

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
  });
}