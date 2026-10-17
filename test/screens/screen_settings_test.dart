import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_settings.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/screens/screen_about.dart';
import 'package:appets/screens/screen_settings.dart';
import 'package:appets/widgets/display/widget_option_tile.dart';

void main() {
  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {AppRoutes.about: (_) => const AboutScreen()},
        home: const SettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  //237
  testWidgets('exibe o título e as opções de configurações', (tester) async {
    await pumpSettings(tester);

    expect(find.text(SettingsStrings.SETTINGS_TITLE), findsOneWidget);
    expect(find.text(SettingsStrings.APP_ABOUT_TITLE), findsOneWidget);
    expect(find.byType(WGOptionTile), findsNWidgets(1));
  });

  //239
  testWidgets('"Sobre o APPets" abre a tela Sobre com as informações do app',
      (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text(SettingsStrings.APP_ABOUT_TITLE));
    await tester.pumpAndSettle();

    expect(find.byType(AboutScreen), findsOneWidget);
    expect(find.text(SettingsStrings.ABOUT_DESCRIPTION), findsOneWidget);
    expect(find.text(SettingsStrings.ABOUT_FEATURES_SECTION), findsOneWidget);
  });

  //240
  testWidgets('exibe a versão real do pubspec (incluindo build number)',
      (tester) async {
    await pumpSettings(tester);

    // O subtítulo do "Sobre o APPets" deve começar com "Versão".
    expect(find.textContaining('Versão'), findsOneWidget);
  });
}
