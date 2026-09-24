import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/services/connectivity_service.dart';
import 'package:appets/widgets/feedback/widget_process.dart';

/// Anfitrião que usa [WGProcessMixin] para expor [pushProcess] em testes.
class _ProcessHost extends StatefulWidget {
  const _ProcessHost();

  @override
  State<_ProcessHost> createState() => _ProcessHostState();
}

class _ProcessHostState extends State<_ProcessHost>
    with WGProcessMixin<_ProcessHost> {
  WGProcessResult? result;

  Future<void> run() async {
    result = await pushProcess(
      message: 'Processando...',
      task: () async => const WGProcessResult.success(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(onPressed: run, child: const Text('iniciar')),
      ),
    );
  }
}

void main() {
  tearDown(() {
    ConnectivityService.instance.reset();
  });
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

  testWidgets('timeout: task que nunca resolve fecha com falha genérica', (
    tester,
  ) async {
    final captured = ValueNotifier<WGProcessResult?>(null);
    final completer = Completer<WGProcessResult>();

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
                        task: () => completer.future,
                        timeout: const Duration(seconds: 1),
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
    // Sobe a rota e monta a tela de load (a task fica pendente).
    await tester.pump();
    await tester.pump();
    expect(find.byType(WGProcessLoadingScreen), findsOneWidget);

    // Avança além do timeout (1 s) e deixa o pop acontecer.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(WGProcessLoadingScreen), findsNothing);
    expect(captured.value?.status, WGProcessStatus.failure);
    expect(captured.value?.message, SharedStrings.PROCESS_GENERIC_ERROR);
  });

  testWidgets('pushProcess offline: não abre o loading, avisa e retorna null', (
    tester,
  ) async {
    ConnectivityService.instance.debugOnline = false;

    await tester.pumpWidget(const MaterialApp(home: _ProcessHost()));
    await tester.tap(find.text('iniciar'));
    await tester.pumpAndSettle();

    expect(find.byType(WGProcessLoadingScreen), findsNothing);
    expect(find.text(SharedStrings.NO_CONNECTION), findsOneWidget);

    await tester.tap(find.text(SharedStrings.OK));
    await tester.pumpAndSettle();

    final host = tester.state<_ProcessHostState>(find.byType(_ProcessHost));
    expect(host.result, isNull);
  });

  testWidgets('pushProcess online: abre o loading e conclui com sucesso', (
    tester,
  ) async {
    ConnectivityService.instance.debugOnline = true;

    await tester.pumpWidget(const MaterialApp(home: _ProcessHost()));
    await tester.tap(find.text('iniciar'));
    await tester.pumpAndSettle();

    expect(find.byType(WGProcessLoadingScreen), findsNothing);
    final host = tester.state<_ProcessHostState>(find.byType(_ProcessHost));
    expect(host.result?.status, WGProcessStatus.success);
  });

  group('WGProcessResult.userFacingMessage', () {
    test('sem causa retorna apenas a mensagem', () {
      const result = WGProcessResult.failure('Deu errado.');

      expect(result.userFacingMessage, 'Deu errado.');
    });

    test('com causa anexa o erro em uma linha truncada', () {
      final result = WGProcessResult.failure(
        'Deu errado.',
        cause: StateError(
          'Linha um. ${'x' * 500}\nlinha dois que não deve aparecer',
        ),
      );

      final text = result.userFacingMessage;
      expect(text, startsWith('Deu errado.\n\nErro: '));
      expect(text, contains('Linha um.'));
      expect(text, endsWith('…'));
      expect(text, isNot(contains('linha dois')));
    });
  });
}
