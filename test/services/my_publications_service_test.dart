import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/my_publications_service.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/models/user_model.dart';

void main() {
  final service = MyPublicationsService.instance;

  // Não remover: sem esta instância criada antes dos testes, o backfill que
  // persiste via `FieldValue.arrayUnion` falha (o cloud_firestore cacheia a
  // fábrica de FieldValue na primeira chamada; precisa ser a do fake).
  FakeFirebaseFirestore();

  setUp(service.reset);

  tearDown(service.reset);

  group('MyPublicationsService', () {
    //332
    test('começa vazio e isMine retorna false', () {
      expect(service.current, isEmpty);
      expect(service.isMine('pet_a'), isFalse);
    });

    //333
    test('removeLocal remove o pet e notifica ouvintes', () {
      service.myPetIds.value = {'pet_a', 'pet_b'};
      expect(service.isMine('pet_a'), isTrue);

      var notified = 0;
      service.myPetIds.addListener(() => notified++);

      service.removeLocal('pet_a');

      expect(service.isMine('pet_a'), isFalse);
      expect(service.isMine('pet_b'), isTrue);
      expect(notified, 1);
    });

    //334
    test('removeLocal não notifica quando o pet não é publicação', () {
      service.myPetIds.value = {'pet_a'};

      var notified = 0;
      service.myPetIds.addListener(() => notified++);

      service.removeLocal('inexistente');

      expect(notified, 0);
      expect(service.myPetIds.value, {'pet_a'});
    });

    //335
    test('removeLocalMany remove vários pets com uma única notificação', () {
      service.myPetIds.value = {'pet_a', 'pet_b', 'pet_c', 'pet_d'};

      var notified = 0;
      service.myPetIds.addListener(() => notified++);

      service.removeLocalMany(['pet_a', 'pet_c', 'inexistente']);

      expect(service.isMine('pet_a'), isFalse);
      expect(service.isMine('pet_b'), isTrue);
      expect(service.isMine('pet_c'), isFalse);
      expect(service.isMine('pet_d'), isTrue);
      expect(notified, 1);
    });

    //336
    test('removeLocalMany não notifica quando nada é removido', () {
      service.myPetIds.value = {'pet_a'};

      var notified = 0;
      service.myPetIds.addListener(() => notified++);

      service.removeLocalMany(['pet_b', 'pet_c']);

      expect(notified, 0);
      expect(service.isMine('pet_a'), isTrue);
    });

    //337
    test('removeLocalMany não notifica quando a lista é vazia', () {
      service.myPetIds.value = {'pet_a'};

      var notified = 0;
      service.myPetIds.addListener(() => notified++);

      service.removeLocalMany([]);

      expect(notified, 0);
      expect(service.myPetIds.value, {'pet_a'});
    });

    //338
    test('reset limpa todas as publicações', () {
      service.myPetIds.value = {'pet_a'};
      service.reset();
      expect(service.current, isEmpty);
    });

    group('add/remove com persistência', () {
      // Sem Firebase inicializado, a persistência falha e o serviço deve
      // reverter o estado otimista e devolver `false`.
      //339
      test('add devolve false e reverte o estado quando o Firestore falha',
          () async {
        service.myPetIds.value = {'pet_a'};

        final ok = await service.add('user_test', 'pet_b');

        expect(ok, isFalse);
        expect(service.isMine('pet_b'), isFalse);
        expect(service.isMine('pet_a'), isTrue);
      });

      //340
      test('remove devolve false e restaura a publicação quando o Firestore '
          'falha', () async {
        service.myPetIds.value = {'pet_a'};

        final ok = await service.remove('user_test', 'pet_a');

        expect(ok, isFalse);
        expect(service.isMine('pet_a'), isTrue);
      });

      //341
      test('add falha: rollback restaura o snapshot pré-escrita em vez de '
          'recalcular do estado atual', () async {
        service.myPetIds.value = {'pet_a'};

        final future = service.add('user_test', 'pet_b');
        // Escrita de outra operação em voo muda o estado antes da falha.
        service.myPetIds.value = {'pet_x'};

        final ok = await future;

        expect(ok, isFalse);
        expect(service.myPetIds.value, {'pet_a'});
      });

      //342
      test('remove falha: rollback restaura o snapshot pré-escrita em vez de '
          'recalcular do estado atual', () async {
        service.myPetIds.value = {'pet_a', 'pet_b'};

        final future = service.remove('user_test', 'pet_a');
        // Escrita de outra operação em voo muda o estado antes da falha.
        service.myPetIds.value = {'pet_a'};

        final ok = await future;

        expect(ok, isFalse);
        expect(service.myPetIds.value, {'pet_a', 'pet_b'});
      });
    });

    group('cleanOrphans', () {
      //343
      test('remove localmente as publicações que não existem mais', () async {
        service.myPetIds.value = {'pet_a', 'pet_b', 'pet_c'};

        await service.cleanOrphans('user_test', ['pet_a', 'pet_c']);

        expect(service.isMine('pet_a'), isTrue);
        expect(service.isMine('pet_c'), isTrue);
        expect(service.isMine('pet_b'), isFalse);
      });

      //344
      test('não altera nada quando não há órfãos', () async {
        service.myPetIds.value = {'pet_a', 'pet_b'};

        await service.cleanOrphans('user_test', ['pet_a', 'pet_b', 'pet_c']);

        expect(service.myPetIds.value, {'pet_a', 'pet_b'});
      });

      //345
      test('não altera nada quando não há publicações', () async {
        var notified = 0;
        service.myPetIds.addListener(() => notified++);

        await service.cleanOrphans('user_test', ['pet_a']);

        expect(service.myPetIds.value, isEmpty);
        expect(notified, 0);
      });

      //346
      test('notifica uma única vez ao remover vários órfãos', () async {
        service.myPetIds.value = {'pet_a', 'pet_b', 'pet_c', 'pet_d'};

        var notified = 0;
        service.myPetIds.addListener(() => notified++);

        await service.cleanOrphans('user_test', ['pet_a', 'pet_b']);

        expect(notified, 1);
        expect(service.myPetIds.value, {'pet_a', 'pet_b'});
      });

      //347
      test('persiste a remoção no campo myPublishedPetIds', () async {
        final db = FakeFirebaseFirestore();
        FirestoreService.instance.debugDb = db;
        addTearDown(() => FirestoreService.instance.debugDb = null);
        await db.collection('users').doc('uid_1').set({
          'favoritePetIds': <String>[],
          'myPublishedPetIds': <String>['pet_a', 'pet_b'],
        });
        service.myPetIds.value = {'pet_a', 'pet_b'};

        await service.cleanOrphans('uid_1', ['pet_a']);

        final doc = await db.collection('users').doc('uid_1').get();
        expect(doc.get('myPublishedPetIds'), ['pet_a']);
        expect(doc.get('favoritePetIds'), isEmpty);
      });
    });

    //348
    test('notifica ouvintes ao alterar myPetIds.value', () {
      var notified = 0;
      void listener() => notified++;
      service.myPetIds.addListener(listener);
      addTearDown(() => service.myPetIds.removeListener(listener));

      service.myPetIds.value = {'pet_x'};

      expect(notified, 1);
      expect(service.isMine('pet_x'), isTrue);
    });

    //349
    test('current é uma visão mutável mas começa vazia', () {
      expect(service.current, isEmpty);
      expect(service.myPetIds, isA<ValueNotifier<Set<String>>>());
    });

    group('applyUser', () {
      //350
      test('preenche as publicações a partir do UserModel', () async {
        final user = UserModel(
          id: 'uid_1',
          name: 'Ana',
          email: 'ana@test.com',
          myPublishedPetIds: const ['pet_a'],
        );

        await service.applyUser(user);

        expect(service.myPetIds.value, contains('pet_a'));
      });

      //351
      test('user null zera o estado (lista vazia, sem backfill)', () async {
        service.myPetIds.value = {'pet_x'};

        await service.applyUser(null);

        expect(service.current, isEmpty);
      });

      //352
      test('não chama getUser (falha nele não afeta o applyUser)', () async {
        FirestoreService.instance.debugGetUserError =
            StateError('não deve ler');
        addTearDown(() => FirestoreService.instance.debugGetUserError = null);
        final user = UserModel(
          id: 'uid_1',
          name: 'Ana',
          email: 'ana@test.com',
          myPublishedPetIds: const ['pet_a'],
        );

        await service.applyUser(user);

        expect(service.myPetIds.value, contains('pet_a'));
      });
    });

    group('applyUser · backfill por ownerId', () {
      late FakeFirebaseFirestore db;

      setUp(() {
        db = FakeFirebaseFirestore();
        FirestoreService.instance.debugDb = db;
        PetService.instance.debugDb = db;
      });

      tearDown(() {
        FirestoreService.instance.debugDb = null;
        PetService.instance.debugDb = null;
      });

      Future<void> seedUser(List<String> publishedIds) =>
          db.collection('users').doc('uid_1').set({
            'name': 'Ana',
            'email': 'ana@test.com',
            'favoritePetIds': <String>[],
            'myPublishedPetIds': publishedIds,
          });

      Future<void> seedOwnedPet() =>
          db.collection('pets').doc('pet_owned').set({
            'ownerId': 'uid_1',
            'name': 'Rex',
            'images': <String>[],
          });

      //353
      test('mescla as publicações do dono e persiste as que faltavam',
          () async {
        await seedUser(<String>['pet_old']);
        await seedOwnedPet();
        final user = UserModel(
          id: 'uid_1',
          name: 'Ana',
          email: 'ana@test.com',
          myPublishedPetIds: const ['pet_old'],
        );

        await service.applyUser(user);

        expect(service.myPetIds.value, {'pet_old', 'pet_owned'});
        final doc = await db.collection('users').doc('uid_1').get();
        expect(
          doc.get('myPublishedPetIds'),
          containsAll(<String>['pet_old', 'pet_owned']),
        );
      });

      //354
      test('não grava quando a lista já está sincronizada', () async {
        await seedUser(<String>['pet_owned']);
        await seedOwnedPet();
        final user = UserModel(
          id: 'uid_1',
          name: 'Ana',
          email: 'ana@test.com',
          myPublishedPetIds: const ['pet_owned'],
        );

        await service.applyUser(user);

        expect(service.myPetIds.value, {'pet_owned'});
        final doc = await db.collection('users').doc('uid_1').get();
        expect(doc.get('myPublishedPetIds'), ['pet_owned']);
      });

      //355
      test('falha ao persistir o backfill mantém o estado local mesclado',
          () async {
        await seedUser(<String>[]);
        await seedOwnedPet();
        // PetService segue no fake, mas o FirestoreService perde o fake:
        // updateUser falha e o serviço deve engolir (melhor esforço).
        FirestoreService.instance.debugDb = null;
        final user = UserModel(
          id: 'uid_1',
          name: 'Ana',
          email: 'ana@test.com',
        );

        await service.applyUser(user);

        expect(service.myPetIds.value, {'pet_owned'});
      });
    });
  });
}