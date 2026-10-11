import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/navigation/navigation_app.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/widgets/feed/widget_feed_page.dart';
import 'package:appets/widgets/feedback/widget_page_states.dart';

void main() {
  tearDown(() => AppNavigation.selectedPage.value = AppPage.home);

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  //438
  testWidgets(
    'estado de erro usa título/descrição parametrizados e o retry dispara',
    (tester) async {
      var retried = false;

      await tester.pumpWidget(
        wrap(
          WGFeedPage(
            filter: AppPetFilter.all,
            itemBuilder: (_, _) => const SizedBox.shrink(),
            loadError: true,
            errorTitle: 'Título de erro',
            errorDescription: 'Descrição de erro',
            onRetry: () => retried = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Título de erro'), findsOneWidget);
      expect(find.text('Descrição de erro'), findsOneWidget);

      await tester.tap(find.text('Tentar de novo'));
      expect(retried, isTrue);
    },
  );

  //439
  testWidgets('estado de carregamento mostra o WGPageLoading com o cabeçalho', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        WGFeedPage(
          filter: AppPetFilter.all,
          itemBuilder: (_, _) => const SizedBox.shrink(),
          headerTitle: 'Meus Pets',
          isLoading: true,
        ),
      ),
    );
    // Não usa pumpAndSettle: o WGLoading anima em loop.
    await tester.pump();

    expect(find.byType(WGPageLoading), findsOneWidget);
    expect(find.text('Meus Pets'), findsWidgets);
  });

  //440
  testWidgets('limpa a busca ao trocar de aba (selectedPage)', (tester) async {
    final key = GlobalKey<WGFeedPageState>();

    AppNavigation.selectedPage.value = AppPage.home;
    await tester.pumpWidget(
      wrap(
        WGFeedPage(
          key: key,
          filter: AppPetFilter.all,
          itemBuilder: (_, _) => const SizedBox.shrink(),
          isLoading: true,
        ),
      ),
    );
    await tester.pump();

    key.currentState!.searchNotifier.value = 'rex';
    AppNavigation.selectedPage.value = AppPage.favorites;
    await tester.pump();

    expect(key.currentState!.searchNotifier.value, isEmpty);
  });
}
