import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_assets.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
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
  });

  /// Texto exibido sob o logo durante o processo.
  final String message;

  /// Operação assíncrona executada ao abrir a tela.
  final Future<WGProcessResult> Function() task;

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
    final result = await widget.task();
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
