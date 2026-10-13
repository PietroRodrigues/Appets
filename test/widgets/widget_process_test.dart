import 'dart:async';
import 'dart:io';

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

/// Anfitrião com uma tarefa que fica pendente até ser liberada pelo [gate],
/// para exercitar o lock de duplo disparo do [WGProcessMixin].
class _PendingHost extends StatefulWidget {
  const _PendingHost();

  @override
  State<_PendingHost> createState() => _PendingHostState();
}

class _PendingHostState extends State<_PendingHost>
    with WGProcessMixin<_PendingHost> {
  final Completer<WGProcessResult> gate = Completer<WGProcessResult>();

  Future<WGProcessResult?> run() {
    return pushProcess(message: 'Processando...', task: () => gate.future);
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
  tearDown(ConnectivityService.instance.reset);
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

  //513
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

  //514
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

  //515
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

  //516
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

  //517
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

  //518
  testWidgets('pushProcess ignora a segunda chamada enquanto a primeira roda', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _PendingHost()));

    // Dispara o primeiro processo; a tarefa fica presa no gate.
    await tester.tap(find.text('iniciar'));
    await tester.pump();
    await tester.pump();
    expect(find.byType(WGProcessLoadingScreen), findsOneWidget);

    // Lock ativo: a segunda chamada é ignorada (retorna null) sem abrir
    // outra tela de processo.
    final host = tester.state<_PendingHostState>(find.byType(_PendingHost));
    final second = await host.run();
    expect(second, isNull);

    // Libera a primeira e o desfecho chega normalmente.
    host.gate.complete(const WGProcessResult.success());
    await tester.pumpAndSettle();

    expect(find.byType(WGProcessLoadingScreen), findsNothing);
  });

  group('WGProcessResult.userFacingMessage', () {
    //519
    test('sem causa retorna apenas a mensagem', () {
      const result = WGProcessResult.failure('Deu errado.');

      expect(result.userFacingMessage, 'Deu errado.');
    });

    //520
    test('causa desconhecida não vaza detalhe técnico', () {
      final result = WGProcessResult.failure(
        'Deu errado.',
        cause: StateError(
          'Linha um. ${'x' * 500}\nlinha dois que não deve aparecer',
        ),
      );

      expect(result.userFacingMessage, 'Deu errado.');
    });

    //521
    test('causa de rede acrescenta dica amigável', () {
      final result = WGProcessResult.failure(
        'Deu errado.',
        cause: SocketException('Network is unreachable'),
      );

      expect(
        result.userFacingMessage,
        'Deu errado.\n\n${SharedStrings.NO_CONNECTION_DESCRIPTION}',
      );
    });

    //522
    test('causa de permissão acrescenta dica amigável', () {
      final result = WGProcessResult.failure(
        'Deu errado.',
        cause: Exception(
          '[cloud_firestore/permission-denied] sem permissão para escrever',
        ),
      );

      expect(
        result.userFacingMessage,
        'Deu errado.\n\n${SharedStrings.PERMISSION_DENIED_HINT}',
      );
    });
  });
}
