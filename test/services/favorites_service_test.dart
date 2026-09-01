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

    test('removeLocal remove o pet e notifica ouvintes', () async {
      service.favoriteIds.value = {'pet_a', 'pet_b'};
      expect(service.isFavorite('pet_a'), isTrue);

      var notified = 0;
      service.favoriteIds.addListener(() => notified++);

      service.removeLocal('pet_a');

      expect(service.isFavorite('pet_a'), isFalse);
      expect(service.isFavorite('pet_b'), isTrue);
      expect(notified, 1);
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

    test('reset limpa todos os favoritos', () {
      service.favoriteIds.value = {'pet_a'};
      service.reset();
      expect(service.current, isEmpty);
    });

    test('alterar favoriteIds.value notifica também via getter isFavorite',
        () {
      service.favoriteIds.value = {'pet_x'};
      expect(service.isFavorite('pet_x'), isTrue);
    });
  });
}
