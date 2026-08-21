import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';

/// Popup de confirmação reutilizável.
///
/// Exibe uma mensagem de confirmação com botões de
/// cancelar e confirmar (destrutivo, vermelho).
///
/// **Uso recomendado:** Utilizar o método estático [show]
/// para exibir o popup e obter o resultado booleano.
///
/// ```dart
/// final confirmed = await AppConfirmDialog.show(
///   context,
///   title: 'Excluir?',
///   message: 'Tem certeza que deseja excluir?',
///   confirmLabel: 'Sim, excluir',
/// );
///
/// if (confirmed) {
///     Executar ação
/// }
/// ```
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Não',
  });

  //══════════════════════════════════════════════════════════════
  // PROPERTIES
  //══════════════════════════════════════════════════════════════

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  //══════════════════════════════════════════════════════════════
  // STATIC HELPER
  //
  // Método estático para exibir o popup e retornar true/false.
  //══════════════════════════════════════════════════════════════

  /// Exibe o popup de confirmação e retorna `true` caso o
  /// usuário confirme, ou `false` caso cancele.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Não',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
      ),
    );

    return result == true;
  }

  //══════════════════════════════════════════════════════════════
  // UI
  //══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        title,
        style: ThemeTextStyles.heading,
      ),
      content: Text(
        message,
        style: ThemeTextStyles.body,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            cancelLabel,
            style: ThemeTextStyles.body.copyWith(
              color: ThemeColors.textSecondary,
            ),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: ThemeColors.error,
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
