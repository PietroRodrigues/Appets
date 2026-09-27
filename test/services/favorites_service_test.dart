import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/models/user_model.dart';

void main() {
  final service = FavoritesService.instance;

  FakeFirebaseFirestore();

  setUp(() {
    service.reset();
  });

  tearDown(() {
    service.reset();
  });

  group('FavoritesService', () {
    test('começa vazio e isFavorite retorna false', () {
      expect(service.current, isEmpty);
      expect(service.isFavorite('pet_a'), isFalse);
    });

    test('cria novos favoritos sem notificar a categoria', () {
      service.favoriteIds.value = {'pet_x'};
      expect(service.isFavorite('pet_x'), isTrue);
    });

    test('removeLocal remove o pet e notifica ouvintes', () {
      service.favoriteIds.value = {'pet_a', 'pet_b'};
      expect(service.isFavorite('pet_a'), isTrue);

      var notified = 0;
      service.favoriteIds.addListener(() => notified++);

      service.removeLocal('pet_a');

      expect(service.isFavorite('pet_a'), isFalse);
      expect(service.isFavorite('pet_b'), isTrue);
      expect(notified, 1);
    });

    test('removeLocal não notifica quando o pet não é favorito', () {
      service.favoriteIds.value = {'pet_a'};

      var notified = 0;
      service.favoriteIds.addListener(() => notified++);

      service.removeLocal('inexistente');

      expect(notified, 0);
      expect(service.favoriteIds.value, {'pet_a'});
    });

    test('removeLocalMany remove vários pets com uma única notificação', () {
      service.favoriteIds.value = {'pet_a', 'pet_b', 'pet_c', 'pet_d'};

      var notified = 0;
      service.favoriteIds.addListener(() => notified++);

      service.removeLocalMany(['pet_a', 'pet_c', 'inexistente']);

      expect(service.isFavorite('pet_a'), isFalse);
      expect(service.isFavorite('pet_b'), isTrue);
      expect(service.isFavorite('pet_c'), isFalse);
      expect(service.isFavorite('pet_d'), isTrue);
      expect(notified, 1);
    });

    test('removeLocalMany não notifica quando nada é removido', () {
      service.favoriteIds.value = {'pet_a'};

      var notified = 0;
      service.favoriteIds.addListener(() => notified++);

      service.removeLocalMany(['pet_b', 'pet_c']);

      expect(notified, 0);
      expect(service.isFavorite('pet_a'), isTrue);
    });

    test('removeLocalMany não notifica quando a lista é vazia', () {
      service.favoriteIds.value = {'pet_a'};

      var notified = 0;
      service.favoriteIds.addListener(() => notified++);

      service.removeLocalMany([]);

      expect(notified, 0);
      expect(service.favoriteIds.value, {'pet_a'});
    });

    test('reset limpa todos os favoritos', () {
      service.favoriteIds.value = {'pet_a'};
      service.reset();
      expect(service.current, isEmpty);
    });

    group('add/remove com persistência', () {
      // Sem Firebase inicializado, a persistência falha e o serviço deve
      // reverter o estado otimista e devolver `false`.
      test(
        'add devolve false e reverte o estado quando o Firestore falha',
        () async {
          service.favoriteIds.value = {'pet_a'};

          final ok = await service.add('user_test', 'pet_b');

          expect(ok, isFalse);
          expect(service.isFavorite('pet_b'), isFalse);
          expect(service.isFavorite('pet_a'), isTrue);
        },
      );

      test('remove devolve false e restaura o favorito quando o Firestore '
          'falha', () async {
        service.favoriteIds.value = {'pet_a'};

        final ok = await service.remove('user_test', 'pet_a');

        expect(ok, isFalse);
        expect(service.isFavorite('pet_a'), isTrue);
      });

      test('add falha: rollback restaura o snapshot pré-escrita em vez de '
          'recalcular do estado atual', () async {
        service.favoriteIds.value = {'pet_a'};

        final future = service.add('user_test', 'pet_b');
        // Escrita de outra operação em voo muda o estado antes da falha.
        service.favoriteIds.value = {'pet_x'};

        final ok = await future;

        expect(ok, isFalse);
        expect(service.favoriteIds.value, {'pet_a'});
      });

      test('remove falha: rollback restaura o snapshot pré-escrita em vez de '
          'recalcular do estado atual', () async {
        service.favoriteIds.value = {'pet_a', 'pet_b'};

        final future = service.remove('user_test', 'pet_a');
        // Escrita de outra operação em voo muda o estado antes da falha.
        service.favoriteIds.value = {'pet_a'};

        final ok = await future;

        expect(ok, isFalse);
        expect(service.favoriteIds.value, {'pet_a', 'pet_b'});
      });
    });

    group('cleanOrphans', () {
      test('remove localmente os favoritos que não existem mais', () async {
        service.favoriteIds.value = {'pet_a', 'pet_b', 'pet_c'};

        await service.cleanOrphans('user_test', ['pet_a', 'pet_c']);

        expect(service.isFavorite('pet_a'), isTrue);
        expect(service.isFavorite('pet_c'), isTrue);
        expect(service.isFavorite('pet_b'), isFalse);
      });

      test('não altera nada quando não há órfãos', () async {
        service.favoriteIds.value = {'pet_a', 'pet_b'};

        await service.cleanOrphans('user_test', ['pet_a', 'pet_b', 'pet_c']);

        expect(service.favoriteIds.value, {'pet_a', 'pet_b'});
      });

      test('não altera nada quando não há favoritos', () async {
        var notified = 0;
        service.favoriteIds.addListener(() => notified++);

        await service.cleanOrphans('user_test', ['pet_a']);

        expect(service.favoriteIds.value, isEmpty);
        expect(notified, 0);
      });

      test('notifica uma única vez ao remover vários órfãos', () async {
        service.favoriteIds.value = {'pet_a', 'pet_b', 'pet_c', 'pet_d'};

        var notified = 0;
        service.favoriteIds.addListener(() => notified++);

        await service.cleanOrphans('user_test', ['pet_a', 'pet_b']);

        expect(notified, 1);
        expect(service.favoriteIds.value, {'pet_a', 'pet_b'});
      });
    });

    test('notifica ouvintes ao alterar favoriteIds.value', () {
      var notified = 0;
      void listener() => notified++;
      service.favoriteIds.addListener(listener);
      addTearDown(() => service.favoriteIds.removeListener(listener));

      service.favoriteIds.value = {'pet_x'};

      expect(notified, 1);
      expect(service.isFavorite('pet_x'), isTrue);
    });

    test('current é uma visão mutável mas começa vazia', () {
      expect(service.current, isEmpty);
      expect(service.favoriteIds, isA<ValueNotifier<Set<String>>>());
    });

    group('applyUser', () {
      test('preenche os favoritos a partir do UserModel', () {
        final user = UserModel(
          id: 'uid_1',
          name: 'Ana',
          email: 'ana@test.com',
          favoritePetIds: const ['pet_a', 'pet_b'],
        );

        service.applyUser(user);

        expect(service.favoriteIds.value, {'pet_a', 'pet_b'});
      });

      test('user null zera o estado (lista vazia)', () {
        service.favoriteIds.value = {'pet_x'};

        service.applyUser(null);

        expect(service.current, isEmpty);
      });

      test('não lê do Firestore (usa só o model recebido)', () {
        FirestoreService.instance.debugGetUserError =
            StateError('não deve ler');
        addTearDown(() => FirestoreService.instance.debugGetUserError = null);
        final user = UserModel(
          id: 'uid_1',
          name: 'Ana',
          email: 'ana@test.com',
          favoritePetIds: const ['pet_a'],
        );

        service.applyUser(user);

        expect(service.favoriteIds.value, {'pet_a'});
      });
    });

    group('isFavoriteListenable', () {
      late FakeFirebaseFirestore db;

      setUp(() async {
        db = FakeFirebaseFirestore();
        FirestoreService.instance.debugDb = db;
        await db.collection('users').doc('uid_1').set({
          'name': 'Ana',
          'favoritePetIds': <String>[],
          'myPublishedPetIds': <String>[],
        });
      });

      tearDown(() {
        FirestoreService.instance.debugDb = null;
      });

      test('começa com o estado atual do pet', () {
        service.favoriteIds.value = {'pet_a'};

        expect(service.isFavoriteListenable('pet_a').value, isTrue);
        expect(service.isFavoriteListenable('pet_b').value, isFalse);
      });

      test('add notifica o ouvinte do notifier do pet', () async {
        final notifier =
            service.isFavoriteListenable('pet_a') as ValueNotifier<bool>;
        var notified = 0;
        notifier.addListener(() => notified++);

        expect(await service.add('uid_1', 'pet_a'), isTrue);

        expect(notified, 1);
        expect(notifier.value, isTrue);
      });

      test('remove notifica o ouvinte do notifier do pet', () async {
        expect(await service.add('uid_1', 'pet_a'), isTrue);
        final notifier =
            service.isFavoriteListenable('pet_a') as ValueNotifier<bool>;
        var notified = 0;
        notifier.addListener(() => notified++);

        expect(await service.remove('uid_1', 'pet_a'), isTrue);

        expect(notified, 1);
        expect(notifier.value, isFalse);
      });

      test('favoritar A não notifica o notifier de B', () async {
        final notifierB =
            service.isFavoriteListenable('pet_b') as ValueNotifier<bool>;
        var notifiedB = 0;
        notifierB.addListener(() => notifiedB++);

        expect(await service.add('uid_1', 'pet_a'), isTrue);
        expect(await service.remove('uid_1', 'pet_a'), isTrue);

        expect(notifiedB, 0);
        expect(notifierB.value, isFalse);
      });

      test('add falho reverte o notifier do pet para false', () async {
        FirestoreService.instance.debugDb = null;
        final notifier =
            service.isFavoriteListenable('pet_a') as ValueNotifier<bool>;
        var notified = 0;
        notifier.addListener(() => notified++);

        expect(await service.add('uid_1', 'pet_a'), isFalse);

        expect(notified, 2);
        expect(notifier.value, isFalse);
      });

      test('remove falho restaura o notifier do pet para true', () async {
        service.favoriteIds.value = {'pet_a'};
        final notifier =
            service.isFavoriteListenable('pet_a') as ValueNotifier<bool>;
        expect(notifier.value, isTrue);
        var notified = 0;
        notifier.addListener(() => notified++);

        FirestoreService.instance.debugDb = null;
        expect(await service.remove('uid_1', 'pet_a'), isFalse);

        expect(notified, 2);
        expect(notifier.value, isTrue);
      });

      test('removeLocal sincroniza o notifier do pet', () {
        service.favoriteIds.value = {'pet_a', 'pet_b'};
        final notifier =
            service.isFavoriteListenable('pet_a') as ValueNotifier<bool>;
        var notified = 0;
        notifier.addListener(() => notified++);

        service.removeLocal('pet_a');

        expect(notified, 1);
        expect(notifier.value, isFalse);
      });

      test('removeLocalMany sincroniza o notifier de cada pet', () {
        service.favoriteIds.value = {'pet_a', 'pet_b', 'pet_c'};
        final notifier =
            service.isFavoriteListenable('pet_a') as ValueNotifier<bool>;
        final notifierC =
            service.isFavoriteListenable('pet_c') as ValueNotifier<bool>;

        service.removeLocalMany(['pet_a', 'pet_c']);

        expect(notifier.value, isFalse);
        expect(notifierC.value, isFalse);
      });

      test('applyUser sincroniza os notifiers já criados', () {
        service.favoriteIds.value = {'pet_a'};
        final notifierA =
            service.isFavoriteListenable('pet_a') as ValueNotifier<bool>;
        final notifierB =
            service.isFavoriteListenable('pet_b') as ValueNotifier<bool>;

        service.applyUser(
          UserModel(
            id: 'uid_1',
            name: 'Ana',
            email: 'ana@test.com',
            favoritePetIds: const ['pet_b'],
          ),
        );

        expect(notifierA.value, isFalse);
        expect(notifierB.value, isTrue);
      });

      test('reset zera todos os notifiers já criados', () {
        service.favoriteIds.value = {'pet_a', 'pet_b'};
        final notifier =
            service.isFavoriteListenable('pet_a') as ValueNotifier<bool>;
        final notifierB =
            service.isFavoriteListenable('pet_b') as ValueNotifier<bool>;

        service.reset();

        expect(notifier.value, isFalse);
        expect(notifierB.value, isFalse);
      });
    });
  });
}
