import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_settings.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/screens/screen_about.dart';
import 'package:appets/widgets/display/widget_logo.dart';

void main() {
  Future<void> pumpAbout(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
    await tester.pumpAndSettle();
  }

  //244
  testWidgets('exibe a identidade do app com logo, nome e slogan',
      (tester) async {
    await pumpAbout(tester);

    expect(find.text(SettingsStrings.APP_ABOUT_TITLE), findsOneWidget);
    expect(find.byType(WGLogo), findsOneWidget);
    expect(find.text(SettingsStrings.ABOUT_APP_NAME), findsOneWidget);
    expect(find.text(SharedStrings.SLOGAN), findsOneWidget);
  });

  //245
  testWidgets('exibe a versão real do pubspec (incluindo build number)',
      (tester) async {
    await pumpAbout(tester);

    expect(find.textContaining('Versão'), findsOneWidget);
  });

  //246
  testWidgets('exibe a descrição, as funcionalidades e a nota de rodapé',
      (tester) async {
    await pumpAbout(tester);

    expect(find.text(SettingsStrings.ABOUT_ABOUT_SECTION), findsOneWidget);
    expect(find.text(SettingsStrings.ABOUT_DESCRIPTION), findsOneWidget);
    expect(find.text(SettingsStrings.ABOUT_FEATURES_SECTION), findsOneWidget);
    expect(find.text(SettingsStrings.ABOUT_FEATURE_PUBLISH), findsOneWidget);
    expect(find.text(SettingsStrings.ABOUT_FEATURE_SEARCH), findsOneWidget);
    expect(find.text(SettingsStrings.ABOUT_FEATURE_FAVORITES), findsOneWidget);
    expect(find.text(SettingsStrings.ABOUT_FEATURE_CONTACT), findsOneWidget);
    expect(find.text(SettingsStrings.ABOUT_PROJECT_NOTE), findsOneWidget);
  });
}
