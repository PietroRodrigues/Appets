import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_report.dart';
import 'package:appets/widgets/feedback/widget_report_dialog.dart';

void main() {
  /// Monta o harness, abre o dialog e notifica [onResult] quando fechar.
  Future<void> openDialog(
    WidgetTester tester,
    void Function(String? value) onResult,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => onResult(await showReportDialog(context)),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('exige motivo e devolve a seleção ao enviar', (tester) async {
    String? result;
    await openDialog(tester, (value) => result = value);

    // Enviar sem selecionar: aviso de motivo obrigatório e dialog permanece.
    await tester.tap(find.text(ReportStrings.REPORT_SEND));
    await tester.pumpAndSettle();
    expect(find.text(ReportStrings.REPORT_REASON_REQUIRED), findsOneWidget);

    // Seleciona o primeiro motivo no menu aberto e envia.
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ReportStrings.reasons.first).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(ReportStrings.REPORT_SEND));
    await tester.pumpAndSettle();

    expect(result, ReportStrings.reasons.first);
  });

  testWidgets('devolve null ao cancelar', (tester) async {
    String? result;
    await openDialog(tester, (value) => result = value);

    await tester.tap(find.text(ReportStrings.REPORT_CANCEL));
    await tester.pumpAndSettle();

    expect(result, null);
  });

  testWidgets('botões ficam 10% mais largos que o padrão', (tester) async {
    // Em 400px de largura, a margem lateral de 27 do diálogo deixa os botões
    // com 143px (ante 130px do padrão Material), ou seja, +10%.
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await openDialog(tester, (_) {});

    expect(tester.getSize(find.byType(OutlinedButton)), const Size(143, 52));
    expect(tester.getSize(find.byType(ElevatedButton)), const Size(143, 52));
  });

  testWidgets('não gera overflow em tela estreita', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await openDialog(tester, (_) {});

    expect(tester.takeException(), isNull);
  });
}
