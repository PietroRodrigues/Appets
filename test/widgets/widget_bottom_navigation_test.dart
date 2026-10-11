import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_home.dart';
import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/widgets/navigation/widget_bottom_navigation.dart';

void main() {
  Widget wrap({
    required AppPage currentPage,
    required ValueChanged<AppPage> onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: WGBottomNavigation(
          currentPage: currentPage,
          onTap: onTap,
        ),
      ),
    );
  }

  testWidgets('exibe os quatro rótulos da navegação', (tester) async {
    await tester.pumpWidget(wrap(currentPage: AppPage.home, onTap: (_) {}));

    expect(find.text(HomeStrings.NAV_HOME), findsOneWidget);
    expect(find.text(HomeStrings.NAV_FAVORITES), findsOneWidget);
    expect(find.text(HomeStrings.NAV_PUBLICATIONS), findsOneWidget);
    expect(find.text(HomeStrings.NAV_PROFILE), findsOneWidget);
  });

  testWidgets('tocar em cada item devolve a página correspondente', (
    tester,
  ) async {
    final tapped = <AppPage>[];
    await tester.pumpWidget(
      wrap(currentPage: AppPage.home, onTap: tapped.add),
    );

    await tester.tap(find.text(HomeStrings.NAV_FAVORITES));
    await tester.tap(find.text(HomeStrings.NAV_PUBLICATIONS));
    await tester.tap(find.text(HomeStrings.NAV_PROFILE));

    expect(tapped, [
      AppPage.favorites,
      AppPage.myPublications,
      AppPage.profile,
    ]);
  });

  testWidgets('item ativo usa ícone preenchido; inativos usam contorno', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(currentPage: AppPage.favorites, onTap: (_) {}));

    // Favoritos é a aba ativa: estrela preenchida (e não o contorno).
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byIcon(Icons.star_border), findsNothing);
    // Home está inativa: contorno (e não o ícone preenchido).
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.home), findsNothing);
  });

  testWidgets('rótulos usam as cores de ativo/inativo da paleta', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(currentPage: AppPage.home, onTap: (_) {}));

    final active = tester.widget<Text>(find.text(HomeStrings.NAV_HOME));
    expect(active.style!.color, AppColors.light.navigationActive);

    final inactive = tester.widget<Text>(find.text(HomeStrings.NAV_FAVORITES));
    expect(inactive.style!.color, AppColors.light.navigationInactive);
  });
}
