import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/utils/search_query_controller.dart';

void main() {
  group('SearchQueryController', () {
    //58
    test('começa com termo vazio', () {
      final controller = SearchQueryController();
      expect(controller.value, '');
      controller.dispose();
    });

    //59
    test('notifica ao mudar o valor', () {
      final controller = SearchQueryController();
      addTearDown(controller.dispose);

      var notified = 0;
      controller.addListener(() => notified++);

      controller.value = 'poodle';

      expect(notified, 1);
      expect(controller.value, 'poodle');
    });

    //60
    test('clear zera o termo e notifica', () {
      final controller = SearchQueryController();
      addTearDown(controller.dispose);

      var notified = 0;
      controller.addListener(() => notified++);

      controller.value = 'rex';
      controller.clear();

      expect(controller.value, '');
      expect(notified, 2);
    });
  });
}