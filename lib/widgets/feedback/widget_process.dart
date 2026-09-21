import 'dart:async';

import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/constants/constants_assets.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/core/utils/offline_guard.dart';
import 'package:appets/widgets/feedback/widget_loading.dart';

/// Desfecho de um processo executado na [WGProcessLoadingScreen].
enum WGProcessStatus { success, canceled, failure }

/// Resultado retornado pela tela de carregamento após concluir a [WGProcessLoadingScreen.task].
class WGProcessResult {
  const WGProcessResult.success()
    : status = WGProcessStatus.success,
      message = null;

  const WGProcessResult.canceled()
    : status = WGProcessStatus.canceled,
      message = null;

  const WGProcessResult.failure(this.message)
    : status = WGProcessStatus.failure;

  final WGProcessStatus status;

  /// Mensagem de erro exibida quando [status] é [WGProcessStatus.failure].
  final String? message;
}

/// Tela full-screen de carregamento no estilo da splash.
///
/// Executa a [task] recebida (verificação do input, autenticação etc.)
/// enquanto exibe o logo, a mensagem e as bolinhas de carregamento.
/// Ao concluir, desfaz a própria rota devolvendo o [WGProcessResult].
class WGProcessLoadingScreen extends StatefulWidget {
  const WGProcessLoadingScreen({
    super.key,
    required this.message,
    required this.task,
    this.timeout = const Duration(seconds: 60),
  });

  /// Texto exibido sob o logo durante o processo.
  final String message;

  /// Operação assíncrona executada ao abrir a tela.
  final Future<WGProcessResult> Function() task;

  /// Limite de duração do processo. Deve caber a operação legítima mais
  /// longa (ex.: upload de fotos), mas garante que a tela nunca fique
  /// presa para sempre caso a rede fique indisponível no meio do caminho.
  final Duration timeout;

  @override
  State<WGProcessLoadingScreen> createState() => _WGProcessLoadingScreenState();
}

class _WGProcessLoadingScreenState extends State<WGProcessLoadingScreen> {
  // Executa o processo assim que a tela é montada.
  @override
  void initState() {
    super.initState();
    _runTask();
  }

  // Aguarda a operação e devolve o resultado ao chamador pela rota.
  Future<void> _runTask() async {
    final WGProcessResult result;
    try {
      // Timeout como rede de segurança: se a rede cair no meio da operação
      // (ex.: WiFi sem internet), a task pode nunca resolver; o loading
      // fecha com falha genérica em vez de ficar preso para sempre.
      //
      // Completer com timer explícito no lugar de Future.timeout/Future.any:
      // o first não repassa o erro de tarefa que já falhou sincronamente
      // (vaza exceção não tratada) e o segundo deixa o timer pendente, o
      // que derruba os widget tests com "pending timers".
      final completer = Completer<WGProcessResult>();
      final timer = Timer(widget.timeout, () {
        if (!completer.isCompleted) {
          completer.complete(
            WGProcessResult.failure(SharedStrings.PROCESS_GENERIC_ERROR),
          );
        }
      });
      widget.task().then(
        (value) {
          if (!completer.isCompleted) {
            timer.cancel();
            completer.complete(value);
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!completer.isCompleted) {
            timer.cancel();
            completer.completeError(error, stackTrace);
          }
        },
      );
      result = await completer.future;
    } catch (_) {
      // Fallback genérico: se a task lançar algo fora de Exception/Error
      // tratado, fecha o loading com falha genérica em vez de prender a
      // tela para sempre com exceção assíncrona não tratada.
      if (!mounted) return;
      Navigator.pop(
        context,
        WGProcessResult.failure(SharedStrings.PROCESS_GENERIC_ERROR),
      );
      return;
    }
    if (!mounted) return;
    Navigator.pop(context, result);
  }

  // Constrói a tela com fundo laranja, logo mini e carregamento.
  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      child: Scaffold(
        backgroundColor: ThemeColors.primary,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AppAssets.LOGO_HEADER,
                  width: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: ThemeTextStyles.authBody,
                ),
                const SizedBox(height: 24),
                const WGLoading(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Encapsula o padrão de execução de um processo assíncrono com tela de
/// carregamento ([WGProcessLoadingScreen]).
///
/// Garante a proteção contra envio duplicado, remove o foco do teclado,
/// empurra a tela de processo e expõe o [WGProcessResult] à tela, que
/// decide o que fazer com o resultado.
mixin WGProcessMixin<T extends StatefulWidget> on State<T> {
  bool _isSubmitting = false;

  /// Executa [task] na [WGProcessLoadingScreen] e devolve o resultado.
  ///
  /// Enquanto um processo está em andamento, chamadas seguintes são
  /// ignoradas (retornam `null`).
  Future<WGProcessResult?> pushProcess({
    required String message,
    required Future<WGProcessResult> Function() task,
  }) async {
    if (_isSubmitting) return null;

    // Mutação offline não pode nem começar: avisa e aborta antes de abrir
    // a tela de carregamento (que ficaria presa tentando a rede).
    if (!await ensureOnline(context)) return null;
    if (!mounted) return null;

    _isSubmitting = true;
    FocusManager.instance.primaryFocus?.unfocus();

    final result = await Navigator.push<WGProcessResult>(
      context,
      MaterialPageRoute<WGProcessResult>(
        builder: (_) => WGProcessLoadingScreen(message: message, task: task),
      ),
    );

    _isSubmitting = false;
    return result;
  }
}
