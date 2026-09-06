import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/utils/search_query_controller.dart';
import 'package:appets/widgets/headers/widget_search_bar.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('WGSearchBar', () {
    testWidgets('submit grava o termo no searchQuery', (tester) async {
      final controller = SearchQueryController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(WGSearchBar(searchQuery: controller, showFilterButton: false)),
      );

      await tester.enterText(find.byType(TextField), ' Poodle ');
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(controller.value, 'Poodle');
    });

    testWidgets('botão de limpar zera o searchQuery', (tester) async {
      final controller = SearchQueryController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(WGSearchBar(searchQuery: controller, showFilterButton: false)),
      );

      await tester.enterText(find.byType(TextField), 'poodle');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(controller.value, '');
    });

    testWidgets('limpeza externa do searchQuery limpa o campo do texto',
        (tester) async {
      final controller = SearchQueryController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(WGSearchBar(searchQuery: controller, showFilterButton: false)),
      );

      await tester.enterText(find.byType(TextField), 'poodle');
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      expect(controller.value, 'poodle');

      controller.value = '';
      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, '');
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('sem searchQuery, usa onSearch no submit', (tester) async {
      String? submitted;
      await tester.pumpWidget(
        wrap(
          WGSearchBar(
            onSearch: (value) => submitted = value,
            showFilterButton: false,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'rex');
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(submitted, 'rex');
    });

    testWidgets('botão de filtro invoca onFilterPressed', (tester) async {
      var pressed = 0;

      await tester.pumpWidget(
        wrap(WGSearchBar(onFilterPressed: () => pressed++)),
      );

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pump();

      expect(pressed, 1);
    });
  });
}