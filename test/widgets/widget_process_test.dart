import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/widgets/feedback/widget_process.dart';

void main() {
  // Empurra a tela de processo e captura o WGProcessResult devolvido.
  Future<void> pushLoading(
    WidgetTester tester,
    Future<WGProcessResult> Function() task,
    ValueNotifier<WGProcessResult?> captured,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push<WGProcessResult>(
                    context,
                    MaterialPageRoute<WGProcessResult>(
                      builder: (_) => WGProcessLoadingScreen(
                        message: 'Processando...',
                        task: task,
                      ),
                    ),
                  );
                  captured.value = result;
                },
                child: const Text('iniciar'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('iniciar'));
    await tester.pumpAndSettle();
  }

  testWidgets('task concluída devolve o WGProcessResult e fecha a tela', (
    tester,
  ) async {
    final captured = ValueNotifier<WGProcessResult?>(null);

    await pushLoading(
      tester,
      () async => const WGProcessResult.success(),
      captured,
    );

    expect(find.byType(WGProcessLoadingScreen), findsNothing);
    expect(captured.value?.status, WGProcessStatus.success);
  });

  testWidgets('task que lança devolve falha genérica e não trava o loading', (
    tester,
  ) async {
    final captured = ValueNotifier<WGProcessResult?>(null);

    await pushLoading(
      tester,
      () async => throw StateError('boom fora de Exception'),
      captured,
    );

    expect(find.byType(WGProcessLoadingScreen), findsNothing);
    expect(captured.value?.status, WGProcessStatus.failure);
    expect(captured.value?.message, SharedStrings.PROCESS_GENERIC_ERROR);
  });
}
