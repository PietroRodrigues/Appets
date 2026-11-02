import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_report.dart';
import 'package:appets/core/theme/theme_app.dart';
import 'package:appets/widgets/fields/widget_dropdown_field.dart';
Widget _buildApp({
  required Size size,
  ValueChanged<String?>? onChanged,
  FormFieldValidator<String>? validator,
}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: MediaQuery(
      data: MediaQueryData(size: size),
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              child: WGDropdownField(
                items: ReportStrings.reasons,
                hintText: 'Motivo da denúncia',
                onChanged: onChanged,
                validator: validator,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  const defaultSize = Size(400, 800);

  testWidgets('mostra o hint e as opções informadas', (tester) async {
    await tester.pumpWidget(
      _buildApp(size: defaultSize, onChanged: (_) {}),
    );

    expect(find.text('Motivo da denúncia'), findsOneWidget);
    expect(find.text(ReportStrings.reasons.first), findsNothing);

    await tester.tap(find.byType(WGDropdownField));
    await tester.pumpAndSettle();

    for (final reason in ReportStrings.reasons) {
      expect(find.text(reason), findsOneWidget);
    }
  });

  testWidgets('seleção dispara onChanged com o valor escolhido',
      (tester) async {
    String? selected;
    await tester.pumpWidget(
      _buildApp(size: defaultSize, onChanged: (v) => selected = v),
    );

    await tester.tap(find.byType(WGDropdownField));
    await tester.pumpAndSettle();
    // .last: o item aparece no menu aberto (o fechado pode não exibir).
    await tester.tap(find.text(ReportStrings.reasons.first).last);
    await tester.pumpAndSettle();

    expect(selected, ReportStrings.reasons.first);
    expect(find.text(ReportStrings.reasons.first), findsOneWidget);
  });

  testWidgets('validação exibe o erro quando não há seleção', (tester) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Form(
            key: formKey,
            child: WGDropdownField(
              items: ReportStrings.reasons,
              hintText: 'Motivo da denúncia',
              validator: (v) => v == null ? 'Selecione um motivo.' : null,
            ),
          ),
        ),
      ),
    );

    formKey.currentState!.validate();
    await tester.pumpAndSettle();

    expect(find.text('Selecione um motivo.'), findsOneWidget);
  });
  
  testWidgets('não gera overflow em tela estreita (aberto e fechado)',
      (tester) async {
    // Tela estreita típica de aparelho pequeno.
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _buildApp(size: const Size(320, 600), onChanged: (_) {}),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(WGDropdownField));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text(ReportStrings.reasons.first), findsOneWidget);

    await tester.tap(find.text(ReportStrings.reasons.first).last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
