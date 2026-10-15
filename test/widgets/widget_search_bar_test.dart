import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/utils/search_query_controller.dart';
import 'package:appets/widgets/headers/widget_search_bar.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('WGSearchBar', () {
    //576
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

    //577
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

    //578
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

    //579
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

    //580
    testWidgets('botão de filtro invoca onFilterPressed', (tester) async {
      var pressed = 0;

      await tester.pumpWidget(
        wrap(WGSearchBar(onFilterPressed: (ctx) => pressed++)),
      );

      await tester.tap(find.byIcon(Icons.filter_alt));
      await tester.pump();

      expect(pressed, 1);
    });

    //581
    testWidgets('troca de controller interno para externo não duplica listener',
        (tester) async {
      final internal = TextEditingController();
      final external = TextEditingController();

      await tester.pumpWidget(
        wrap(WGSearchBar(controller: internal, showFilterButton: false)),
      );
      await tester.pump();

      // Digita no controller interno.
      await tester.enterText(find.byType(TextField), 'interno');
      await tester.pump();
      expect(internal.text, 'interno');

      // Troca para controller externo.
      await tester.pumpWidget(
        wrap(WGSearchBar(controller: external, showFilterButton: false)),
      );
      await tester.pump();

      // Digita no campo: deve atualizar apenas o controller externo,
      // não o interno (listener do antigo foi removido).
      await tester.enterText(find.byType(TextField), ' anexo');
      await tester.pump();
      expect(external.text, ' anexo');
      expect(internal.text, 'interno');

      internal.dispose();
      external.dispose();
    });

    //582
    testWidgets('troca de searchQuery não duplica listener', (tester) async {
      final a = SearchQueryController();
      final b = SearchQueryController();
      addTearDown(a.dispose);
      addTearDown(b.dispose);

      await tester.pumpWidget(
        wrap(WGSearchBar(searchQuery: a, showFilterButton: false)),
      );
      await tester.pump();

      // Digita e submete via searchQuery A.
      await tester.enterText(find.byType(TextField), 'de A');
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      expect(a.value, 'de A');

      // Troca para searchQuery B: o campo deve refletir o valor de B (vazio).
      await tester.pumpWidget(
        wrap(WGSearchBar(searchQuery: b, showFilterButton: false)),
      );
      await tester.pump();
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '');

      // Digita e submete via searchQuery B: não contamina o anterior.
      await tester.enterText(find.byType(TextField), 'de B');
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      expect(a.value, 'de A');
      expect(b.value, 'de B');
    });

    //583
    testWidgets('mesmo controller reatribuído não acumula listener', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'fixo');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(WGSearchBar(controller: controller, showFilterButton: false)),
      );
      await tester.pump();

      // Reatribui o mesmo controller.
      await tester.pumpWidget(
        wrap(WGSearchBar(controller: controller, showFilterButton: false)),
      );
      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller, controller);
      expect(controller.text, 'fixo');
    });
  });
}