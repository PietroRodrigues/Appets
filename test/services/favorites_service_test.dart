import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/services/favorites_service.dart';

void main() {
  final service = FavoritesService.instance;

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
  });
}
