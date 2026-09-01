import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';

/// Diálogo informativo reutilizável com um botão de ação colorido.
///
/// Diferente do [AppConfirmDialog] (que tem dois botões, um deles
/// destrutivo em vermelho), este exibe somente um botão de ação,
/// ideal para feedbacks que conduzem o usuário a um próximo passo
/// (ex.: "Completar cadastro").
class AppActionDialog extends StatelessWidget {
  const AppActionDialog({
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
      builder: (context) => AppActionDialog(
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        title,
        style: ThemeTextStyles.heading,
      ),
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
