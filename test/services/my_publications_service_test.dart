import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/services/my_publications_service.dart';

void main() {
  final service = MyPublicationsService.instance;

  setUp(() {
    service.reset();
  });

  tearDown(() {
    service.reset();
  });

  group('MyPublicationsService', () {
    test('começa vazio e isMine retorna false', () {
      expect(service.current, isEmpty);
      expect(service.isMine('pet_a'), isFalse);
    });

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

    test('removeLocal não notifica quando o pet não é publicação', () {
      service.myPetIds.value = {'pet_a'};

      var notified = 0;
      service.myPetIds.addListener(() => notified++);

      service.removeLocal('inexistente');

      expect(notified, 0);
      expect(service.myPetIds.value, {'pet_a'});
    });

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

    test('removeLocalMany não notifica quando nada é removido', () {
      service.myPetIds.value = {'pet_a'};

      var notified = 0;
      service.myPetIds.addListener(() => notified++);

      service.removeLocalMany(['pet_b', 'pet_c']);

      expect(notified, 0);
      expect(service.isMine('pet_a'), isTrue);
    });

    test('removeLocalMany não notifica quando a lista é vazia', () {
      service.myPetIds.value = {'pet_a'};

      var notified = 0;
      service.myPetIds.addListener(() => notified++);

      service.removeLocalMany([]);

      expect(notified, 0);
      expect(service.myPetIds.value, {'pet_a'});
    });

    test('reset limpa todas as publicações', () {
      service.myPetIds.value = {'pet_a'};
      service.reset();
      expect(service.current, isEmpty);
    });

    group('add/remove com persistência', () {
      // Sem Firebase inicializado, a persistência falha e o serviço deve
      // reverter o estado otimista e devolver `false`.
      test('add devolve false e reverte o estado quando o Firestore falha',
          () async {
        service.myPetIds.value = {'pet_a'};

        final ok = await service.add('user_test', 'pet_b');

        expect(ok, isFalse);
        expect(service.isMine('pet_b'), isFalse);
        expect(service.isMine('pet_a'), isTrue);
      });

      test('remove devolve false e restaura a publicação quando o Firestore '
          'falha', () async {
        service.myPetIds.value = {'pet_a'};

        final ok = await service.remove('user_test', 'pet_a');

        expect(ok, isFalse);
        expect(service.isMine('pet_a'), isTrue);
      });
    });

    group('cleanOrphans', () {
      test('remove localmente as publicações que não existem mais', () async {
        service.myPetIds.value = {'pet_a', 'pet_b', 'pet_c'};

        await service.cleanOrphans('user_test', ['pet_a', 'pet_c']);

        expect(service.isMine('pet_a'), isTrue);
        expect(service.isMine('pet_c'), isTrue);
        expect(service.isMine('pet_b'), isFalse);
      });

      test('não altera nada quando não há órfãos', () async {
        service.myPetIds.value = {'pet_a', 'pet_b'};

        await service.cleanOrphans('user_test', ['pet_a', 'pet_b', 'pet_c']);

        expect(service.myPetIds.value, {'pet_a', 'pet_b'});
      });

      test('não altera nada quando não há publicações', () async {
        var notified = 0;
        service.myPetIds.addListener(() => notified++);

        await service.cleanOrphans('user_test', ['pet_a']);

        expect(service.myPetIds.value, isEmpty);
        expect(notified, 0);
      });

      test('notifica uma única vez ao remover vários órfãos', () async {
        service.myPetIds.value = {'pet_a', 'pet_b', 'pet_c', 'pet_d'};

        var notified = 0;
        service.myPetIds.addListener(() => notified++);

        await service.cleanOrphans('user_test', ['pet_a', 'pet_b']);

        expect(notified, 1);
        expect(service.myPetIds.value, {'pet_a', 'pet_b'});
      });
    });

    test('notifica ouvintes ao alterar myPetIds.value', () {
      var notified = 0;
      void listener() => notified++;
      service.myPetIds.addListener(listener);
      addTearDown(() => service.myPetIds.removeListener(listener));

      service.myPetIds.value = {'pet_x'};

      expect(notified, 1);
      expect(service.isMine('pet_x'), isTrue);
    });

    test('current é uma visão mutável mas começa vazia', () {
      expect(service.current, isEmpty);
      expect(service.myPetIds, isA<ValueNotifier<Set<String>>>());
    });
  });
}