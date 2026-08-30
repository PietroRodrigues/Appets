import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_assets.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/common/feedback/widget_loading.dart';

/// Desfecho de um processo executado na [AppProcessLoadingScreen].
enum AppProcessStatus { success, canceled, failure }

/// Resultado retornado pela tela de carregamento após concluir a [AppProcessLoadingScreen.task].
class AppProcessResult {
  const AppProcessResult.success()
      : status = AppProcessStatus.success,
        message = null;

  const AppProcessResult.canceled()
      : status = AppProcessStatus.canceled,
        message = null;

  const AppProcessResult.failure(this.message)
      : status = AppProcessStatus.failure;

  final AppProcessStatus status;

  /// Mensagem de erro exibida quando [status] é [AppProcessStatus.failure].
  final String? message;
}

/// Tela full-screen de carregamento no estilo da splash.
///
/// Executa a [task] recebida (verificação do input, autenticação etc.)
/// enquanto exibe o logo, a mensagem e as bolinhas de carregamento.
/// Ao concluir, desfaz a própria rota devolvendo o [AppProcessResult].
class AppProcessLoadingScreen extends StatefulWidget {
  const AppProcessLoadingScreen({
    super.key,
    required this.message,
    required this.task,
  });

  /// Texto exibido sob o logo durante o processo.
  final String message;

  /// Operação assíncrona executada ao abrir a tela.
  final Future<AppProcessResult> Function() task;

  @override
  State<AppProcessLoadingScreen> createState() =>
      _AppProcessLoadingScreenState();
}

class _AppProcessLoadingScreenState extends State<AppProcessLoadingScreen> {
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
                  AppAssets.logoHeader,
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
                const AppLoading(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}