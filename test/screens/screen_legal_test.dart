import 'package:appets/core/constants/constants_strings_legal.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/screens/screen_privacy_policy.dart';
import 'package:appets/screens/screen_settings.dart';
import 'package:appets/screens/screen_terms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildApp(Widget home) {
    return MaterialApp(
      home: home,
      routes: {
        AppRoutes.privacyPolicy: (_) => const PrivacyPolicyScreen(),
        AppRoutes.terms: (_) => const TermsScreen(),
      },
    );
  }

  testWidgets('política exibe dados tratados e canal de contato', (tester) async {
    await tester.pumpWidget(buildApp(const PrivacyPolicyScreen()));

    expect(find.text(LegalStrings.PRIVACY_TITLE), findsOneWidget);
    expect(find.text(LegalStrings.PRIVACY_DATA_TITLE), findsOneWidget);
    expect(find.textContaining('Firebase Authentication'), findsOneWidget);
    expect(find.textContaining('privacidade@appets.app'), findsOneWidget);
  });

  testWidgets('termos explicam uso aceitável e adoção responsável', (tester) async {
    await tester.pumpWidget(buildApp(const TermsScreen()));

    expect(find.text(LegalStrings.TERMS_TITLE), findsOneWidget);
    expect(find.text(LegalStrings.TERMS_USE_TITLE), findsOneWidget);
    expect(find.text(LegalStrings.TERMS_ADOPTION_TITLE), findsOneWidget);
  });

  testWidgets('configurações abrem os documentos legais', (tester) async {
    await tester.pumpWidget(buildApp(const SettingsScreen()));

    await tester.tap(find.text(LegalStrings.PRIVACY_TITLE));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyPolicyScreen), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text(LegalStrings.TERMS_TITLE));
    await tester.pumpAndSettle();
    expect(find.byType(TermsScreen), findsOneWidget);
  });
}
