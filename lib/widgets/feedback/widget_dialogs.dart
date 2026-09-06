import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:flutter/material.dart';

/// Popup de confirmação reutilizável.
///
/// Exibe uma mensagem de confirmação com dois botões igualmente
/// visíveis, lado a lado: cancelar (contorno) e confirmar
/// (vermelho, destrutivo).
///
/// **Uso recomendado:** Utilizar o método estático [show]
/// para exibir o popup e obter o resultado booleano.
///
/// ```dart
/// final confirmed = await WGConfirmDialog.show(
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
class WGConfirmDialog extends StatelessWidget {
  const WGConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = SharedStrings.NO,
    this.messageHighlight,
  });

  //══════════════════════════════════════════════════════════════
  // PROPERTIES
  //══════════════════════════════════════════════════════════════

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  /// Trecho de [message] que deve ser destacado em negrito e na
  /// cor de erro (busca sem diferenciar maiúsculas/minúsculas).
  final String? messageHighlight;

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
    String cancelLabel = SharedStrings.NO,
    String? messageHighlight,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => WGConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        messageHighlight: messageHighlight,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: ThemeTextStyles.heading),
      content: _buildMessage(),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: ThemeColors.textSecondary,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  cancelLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: ThemeTextStyles.button.copyWith(
                    color: ThemeColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: ThemeColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  confirmLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: ThemeTextStyles.button.copyWith(
                    color: ThemeColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Constrói o texto da mensagem, destacando [messageHighlight]
  /// quando informado.
  Widget _buildMessage() {
    final highlight = messageHighlight;
    final highlightIndex = highlight == null || highlight.isEmpty
        ? -1
        : message.toLowerCase().indexOf(highlight.toLowerCase());

    if (highlightIndex < 0 || highlight!.isEmpty) {
      return Text(message, style: ThemeTextStyles.body);
    }

    return Text.rich(
      TextSpan(
        style: ThemeTextStyles.body,
        children: [
          TextSpan(text: message.substring(0, highlightIndex)),
          TextSpan(
            text: message.substring(
              highlightIndex,
              highlightIndex + highlight.length,
            ),
            style: ThemeTextStyles.body.copyWith(
              color: ThemeColors.error,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: message.substring(highlightIndex + highlight.length)),
        ],
      ),
    );
  }
}

/// Diálogo informativo reutilizável com um botão de ação colorido.
///
/// Diferente do [WGConfirmDialog] (que tem dois botões, um deles
/// destrutivo em vermelho), este exibe somente um botão de ação,
/// ideal para feedbacks que conduzem o usuário a um próximo passo
/// (ex.: "Completar cadastro").
class WGActionDialog extends StatelessWidget {
  const WGActionDialog({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    this.actionIcon,
    this.actionColor = ThemeColors.success,
  });

  final String title;
  final String message;
  final String actionLabel;
  final IconData? actionIcon;

  /// Cor de fundo do botão de ação.
  final Color actionColor;

  /// Exibe o diálogo e devolve `true` quando o botão de ação é tocado,
  /// ou `false`/`null` quando dispensado.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String actionLabel,
    IconData? actionIcon,
    Color actionColor = ThemeColors.success,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => WGActionDialog(
        title: title,
        message: message,
        actionLabel: actionLabel,
        actionIcon: actionIcon,
        actionColor: actionColor,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: ThemeTextStyles.heading),
      content: Text(message, style: ThemeTextStyles.body),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: actionColor,
            minimumSize: const Size(double.infinity, 48),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (actionIcon != null) ...[
                Icon(actionIcon, color: ThemeColors.white, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  actionLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: ThemeTextStyles.button.copyWith(
                    color: ThemeColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
