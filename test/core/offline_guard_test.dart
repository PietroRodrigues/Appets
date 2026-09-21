import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/services/connectivity_service.dart';
import 'package:appets/core/utils/offline_guard.dart';

void main() {
  tearDown(() {
    ConnectivityService.instance.reset();
  });

  testWidgets('offline: devolve false e mostra o aviso "Sem conexão"', (
    tester,
  ) async {
    ConnectivityService.instance.debugOnline = false;
    final captured = ValueNotifier<bool?>(null);

    await _pumpGuard(tester, captured);

    await tester.tap(find.text('iniciar'));
    await tester.pumpAndSettle();

    // O aviso aparece e o resultado segue pendente até o usuário fechar.
    expect(find.text(SharedStrings.NO_CONNECTION), findsOneWidget);
    expect(captured.value, isNull);

    await tester.tap(find.text(SharedStrings.OK));
    await tester.pumpAndSettle();

    expect(captured.value, isFalse);
  });

  testWidgets('online: devolve true sem mostrar o aviso', (tester) async {
    ConnectivityService.instance.debugOnline = true;
    final captured = ValueNotifier<bool?>(null);

    await _pumpGuard(tester, captured);

    await tester.tap(find.text('iniciar'));
    await tester.pumpAndSettle();

    expect(find.text(SharedStrings.NO_CONNECTION), findsNothing);
    expect(captured.value, isTrue);
  });
}

Future<void> _pumpGuard(
  WidgetTester tester,
  ValueNotifier<bool?> captured,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                captured.value = await ensureOnline(context);
              },
              child: const Text('iniciar'),
            ),
          ),
        ),
      ),
    ),
  );
}