import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_auth.dart';
import 'package:appets/widgets/fields/widget_email_field.dart';
import 'package:appets/widgets/fields/widget_field_label.dart';
import 'package:appets/widgets/fields/widget_text_field.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  TextField textField(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField));

  group('WGTextField', () {
    //591
    testWidgets('mostra label, hint e prefixo informados', (tester) async {
      await tester.pumpWidget(
        wrap(
          const WGTextField(
            label: 'Nome',
            hintText: 'Digite o nome',
            prefixIcon: Icons.person_outline,
          ),
        ),
      );

      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Digite o nome'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    //592
    testWidgets('repassa obscureText, enabled e maxLines', (tester) async {
      await tester.pumpWidget(
        wrap(const WGTextField(hintText: 'Senha', obscureText: true)),
      );
      expect(textField(tester).obscureText, isTrue);

      await tester.pumpWidget(
        wrap(const WGTextField(hintText: 'Descrição', maxLines: 3)),
      );
      expect(textField(tester).maxLines, 3);

      await tester.pumpWidget(
        wrap(const WGTextField(hintText: 'Nome', enabled: false)),
      );
      expect(textField(tester).enabled, isFalse);
    });

    //593
    testWidgets('usa o validator e mostra o erro', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        wrap(
          Form(
            key: formKey,
            child: WGTextField(
              hintText: 'Nome',
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'obrigatório' : null,
            ),
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();

      expect(find.text('obrigatório'), findsOneWidget);
    });

    //594
    testWidgets('dispara onChanged ao digitar', (tester) async {
      String? changed;

      await tester.pumpWidget(
        wrap(WGTextField(hintText: 'Nome', onChanged: (v) => changed = v)),
      );

      await tester.enterText(find.byType(TextFormField), 'Rex');
      expect(changed, 'Rex');
    });

    //595
    testWidgets('dispara onFieldSubmitted ao confirmar', (tester) async {
      String? submitted;

      await tester.pumpWidget(
        wrap(
          WGTextField(
            hintText: 'Nome',
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (v) => submitted = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Rex');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submitted, 'Rex');
    });
  });

  group('WGEmailField', () {
    //596
    testWidgets('usa label, hint, teclado e ícone de e-mail', (tester) async {
      await tester.pumpWidget(wrap(const WGEmailField()));

      expect(find.text(AuthStrings.EMAIL), findsOneWidget);
      expect(find.text(AuthStrings.EMAIL_HINT), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(textField(tester).keyboardType, TextInputType.emailAddress);
    });
  });

  group('WGFieldLabel', () {
    //597
    testWidgets('mostra o texto informado', (tester) async {
      await tester.pumpWidget(wrap(const WGFieldLabel(text: 'Raça')));

      expect(find.text('Raça'), findsOneWidget);
    });
  });
}
