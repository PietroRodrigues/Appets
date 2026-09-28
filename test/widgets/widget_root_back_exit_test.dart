import 'package:appets/core/constants/constants_strings_home.dart';
import 'package:appets/widgets/layout/widget_root_back_exit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, {VoidCallback? onExit}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WGRootBackExit(
          onExit: onExit,
          child: const Scaffold(body: Center(child: Text('raiz'))),
        ),
      ),
    );
  }

  // Simula o gesto de voltar do sistema na raiz.
  Future<void> pressBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  testWidgets('voltar na raiz abre a confirmação e não fecha o app',
      (tester) async {
    await pump(tester);

    await pressBack(tester);

    expect(find.text(HomeStrings.EXIT_CONFIRM_MESSAGE), findsOneWidget);
    expect(find.text('raiz'), findsOneWidget);
  });

  testWidgets('confirmar com "Sim" encerra o app', (tester) async {
    var exited = false;
    await pump(tester, onExit: () => exited = true);

    await pressBack(tester);
    await tester.tap(find.text('Sim'));
    await tester.pumpAndSettle();

    expect(exited, isTrue);
  });

  testWidgets('cancelar com "Não" mantém o app aberto', (tester) async {
    var exited = false;
    await pump(tester, onExit: () => exited = true);

    await pressBack(tester);
    await tester.tap(find.text('Não'));
    await tester.pumpAndSettle();

    expect(exited, isFalse);
    expect(find.text(HomeStrings.EXIT_CONFIRM_MESSAGE), findsNothing);
    expect(find.text('raiz'), findsOneWidget);
  });
}