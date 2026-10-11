import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_auth.dart';
import 'package:appets/widgets/buttons/widget_buttons.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('WGButton', () {
    //412
    testWidgets('renderiza o texto e dispara onPressed', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        wrap(WGButton(text: 'Salvar', onPressed: () => pressed = true)),
      );

      expect(find.text('Salvar'), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isTrue);
    });

    //413
    testWidgets('isLoading mostra o indicador e bloqueia o toque', (
      tester,
    ) async {
      var pressed = false;

      await tester.pumpWidget(
        wrap(
          WGButton(
            text: 'Salvar',
            isLoading: true,
            onPressed: () => pressed = true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Salvar'), findsNothing);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isFalse);
    });

    //414
    testWidgets('respeita width e height informados', (tester) async {
      await tester.pumpWidget(
        wrap(
          WGButton(
            text: 'Ok',
            width: 180,
            height: 40,
            onPressed: () {},
          ),
        ),
      );

      expect(tester.getSize(find.byType(WGButton)), const Size(180, 40));
    });
  });

  group('WGOutlinedButton', () {
    //415
    testWidgets('renderiza texto e ícone e dispara onPressed', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        wrap(
          WGOutlinedButton(
            text: 'Voltar',
            icon: Icons.arrow_back,
            onPressed: () => pressed = true,
          ),
        ),
      );

      expect(find.text('Voltar'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      await tester.tap(find.byType(OutlinedButton));
      expect(pressed, isTrue);
    });

    //416
    testWidgets('sem ícone não renderiza nenhum Icon', (tester) async {
      await tester.pumpWidget(
        wrap(WGOutlinedButton(text: 'Voltar', onPressed: () {})),
      );

      expect(find.byType(Icon), findsNothing);
      expect(find.text('Voltar'), findsOneWidget);
    });
  });

  group('WGGoogleButton', () {
    //417
    testWidgets('usa o texto padrão e renderiza o logo', (tester) async {
      await tester.pumpWidget(wrap(WGGoogleButton(onPressed: () {})));

      expect(find.text(AuthStrings.GOOGLE_LOGIN), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    //418
    testWidgets('aceita texto customizado e dispara onPressed', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        wrap(WGGoogleButton(text: 'Continuar', onPressed: () => pressed = true)),
      );

      expect(find.text('Continuar'), findsOneWidget);

      await tester.tap(find.byType(OutlinedButton));
      expect(pressed, isTrue);
    });
  });
}
