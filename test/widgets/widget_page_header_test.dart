import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/navigation/navigation_app.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/widgets/headers/widget_page_header.dart';

void main() {
  Widget wrap() {
    return MaterialApp(
      home: Scaffold(
        body: const WGPageHeader.title(title: 'Feed', hintText: 'Buscar...'),
      ),
    );
  }

  tearDown(() {
    AppNavigation.selectedPage.value = AppPage.home;
  });

  // Abre a janela de filtros e aplica uma opção.
  Future<void> applyFilter(
    WidgetTester tester, {
    String option = 'Cachorro',
  }) async {
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, option));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Filtrar'));
    await tester.pumpAndSettle();
  }

  testWidgets('botão de filtro abre a janela de filtros', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    expect(find.text('Filtros'), findsOneWidget);
  });

  testWidgets('aplicar filtro exibe o chip abaixo do cabeçalho',
      (tester) async {
    await tester.pumpWidget(wrap());

    await applyFilter(tester);

    expect(find.text('Filtros'), findsNothing);
    expect(find.text('Cachorro'), findsOneWidget);
  });

  testWidgets('X do chip remove o filtro', (tester) async {
    await tester.pumpWidget(wrap());

    await applyFilter(tester);
    expect(find.text('Cachorro'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Cachorro'), findsNothing);
  });

  testWidgets('trocar de aba limpa os chips', (tester) async {
    await tester.pumpWidget(wrap());

    await applyFilter(tester, option: 'Gato');
    expect(find.text('Gato'), findsOneWidget);

    AppNavigation.selectedPage.value = AppPage.favorites;
    await tester.pumpAndSettle();

    expect(find.text('Gato'), findsNothing);
  });

  testWidgets('cabeçalho sem busca não exibe o botão de filtro',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WGPageHeader.title(title: 'Sem busca', showSearchBar: false),
        ),
      ),
    );

    expect(find.byIcon(Icons.tune), findsNothing);
  });
}