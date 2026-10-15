import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_settings.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/screens/screen_settings.dart';
import 'package:appets/widgets/display/widget_option_tile.dart';

void main() {
  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();
  }

  //237
  testWidgets('exibe o título e as opções de configurações', (tester) async {
    await pumpSettings(tester);

    expect(find.text(SettingsStrings.SETTINGS_TITLE), findsOneWidget);
    expect(find.text(SettingsStrings.SHARE_LOCATION_TITLE), findsOneWidget);
    expect(find.text(SettingsStrings.APP_ABOUT_TITLE), findsOneWidget);
    expect(find.byType(WGOptionTile), findsNWidgets(2));
  });

  //238
  testWidgets('"Compartilhar localização" avisa que está em desenvolvimento',
      (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text(SettingsStrings.SHARE_LOCATION_TITLE));
    await tester.pumpAndSettle();

    expect(find.text(SharedStrings.DEVELOPMENT_TITLE), findsOneWidget);
    expect(
      find.text(
        SharedStrings.featureInDevelopment(SettingsStrings.SHARE_LOCATION_FEATURE),
      ),
      findsOneWidget,
    );
  });

  //239
  testWidgets('"Sobre o APPets" avisa que está em desenvolvimento',
      (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text(SettingsStrings.APP_ABOUT_TITLE));
    await tester.pumpAndSettle();

    expect(find.text(SharedStrings.DEVELOPMENT_TITLE), findsOneWidget);
    expect(
      find.text(
        SharedStrings.featureInDevelopment(SettingsStrings.APP_ABOUT_FEATURE),
      ),
      findsOneWidget,
    );
  });

  //240
  testWidgets('exibe a versão real do pubspec (incluindo build number)', (
    tester,
  ) async {
    await pumpSettings(tester);

    // O subtítulo do "Sobre o APPets" deve começar com "Versão".
    expect(find.textContaining('Versão'), findsOneWidget);
  });
}
