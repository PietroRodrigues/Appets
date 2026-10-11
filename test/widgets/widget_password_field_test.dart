import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_auth.dart';
import 'package:appets/widgets/fields/widget_password_field.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  bool obscureText(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).obscureText;

  //469
  testWidgets('começa oculto e alterna a visibilidade no toque', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(WGPasswordField(controller: controller, hintText: 'Senha')),
    );

    expect(obscureText(tester), isTrue);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    expect(obscureText(tester), isFalse);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    expect(obscureText(tester), isTrue);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });

  //470
  testWidgets('olho expõe o tooltip de mostrar/ocultar senha (a11y)',
      (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(WGPasswordField(controller: controller, hintText: 'Senha')),
    );

    // Senha oculta: tooltip incentiva "mostrar".
    expect(find.byTooltip(AuthStrings.SHOW_PASSWORD), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    // Senha visível: tooltip passa a incentivar "ocultar".
    expect(find.byTooltip(AuthStrings.HIDE_PASSWORD), findsOneWidget);
  });

  //471
  testWidgets('exibe label, hint e prefixo informados', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        WGPasswordField(
          controller: controller,
          label: 'Senha',
          hintText: 'Digite a senha',
        ),
      ),
    );

    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Digite a senha'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });

  //472
  testWidgets('usa o validator informado e mostra o erro', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      wrap(
        Form(
          key: formKey,
          child: WGPasswordField(
            controller: controller,
            hintText: 'Senha',
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

  //473
  testWidgets('dispara onFieldSubmitted ao confirmar o campo', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    String? submitted;

    await tester.pumpWidget(
      wrap(
        WGPasswordField(
          controller: controller,
          hintText: 'Senha',
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (value) => submitted = value,
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'segredo');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(submitted, 'segredo');
  });
}
