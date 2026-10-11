import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/widgets/auth/widget_auth_button.dart';
import 'package:appets/widgets/auth/widget_auth_header.dart';
import 'package:appets/widgets/auth/widget_auth_page_layout.dart';
import 'package:appets/widgets/display/widget_logo.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('WGAuthButton', () {
    //397
    testWidgets('renderiza o texto e dispara onPressed', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        wrap(WGAuthButton(text: 'Entrar', onPressed: () => pressed = true)),
      );

      expect(find.text('Entrar'), findsOneWidget);

      await tester.tap(find.text('Entrar'));
      expect(pressed, isTrue);
    });
  });

  group('WGAuthSecondaryButton', () {
    //398
    testWidgets('renderiza o texto e dispara onPressed', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        wrap(
          WGAuthSecondaryButton(
            text: 'Criar conta',
            onPressed: () => pressed = true,
          ),
        ),
      );

      expect(find.text('Criar conta'), findsOneWidget);

      await tester.tap(find.text('Criar conta'));
      expect(pressed, isTrue);
    });
  });

  group('WGAuthHeader', () {
    //399
    testWidgets('padrão mostra o logo e o slogan', (tester) async {
      await tester.pumpWidget(wrap(const WGAuthHeader()));

      expect(find.byType(WGLogo), findsOneWidget);
      expect(find.text(SharedStrings.SLOGAN), findsOneWidget);
    });

    //400
    testWidgets('.auth mostra a headline e não o slogan', (tester) async {
      await tester.pumpWidget(
        wrap(const WGAuthHeader.auth(headline: 'Bem-vindo')),
      );

      expect(find.byType(WGLogo), findsOneWidget);
      expect(find.text('Bem-vindo'), findsOneWidget);
      expect(find.text(SharedStrings.SLOGAN), findsNothing);
    });

    //401
    testWidgets('.auth sem headline não renderiza nenhum texto', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const WGAuthHeader.auth()));

      expect(find.byType(WGLogo), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });
  });

  group('WGAuthPageLayout', () {
    //402
    testWidgets('renderiza o child dentro do Form associado ao formKey', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: WGAuthPageLayout(
            formKey: formKey,
            child: const SizedBox(height: 40, child: Text('conteúdo')),
          ),
        ),
      );

      expect(find.text('conteúdo'), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
      expect(formKey.currentState, isNotNull);
    });
  });
}
