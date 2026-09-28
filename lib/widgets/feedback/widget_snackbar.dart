import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';

/// SnackBar padrão do app (feedback leve), no formato tipado do [WGDialog].
///
/// Cada chamada limpa os avisos pendentes (`clearSnackBars`) para que a
/// mensagem mais recente sempre apareça sozinha na tela.
class WGSnackBar {
  WGSnackBar._();

  /// Aviso de erro (fundo vermelho).
  static void showError(BuildContext context, String message) =>
      _show(context, message, ThemeColors.error);

  /// Confirmação de sucesso (fundo verde).
  static void showSuccess(BuildContext context, String message) =>
      _show(context, message, ThemeColors.success);

  /// Informativo neutro (fundo azul).
  static void showInfo(BuildContext context, String message) =>
      _show(context, message, ThemeColors.info);

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            message,
            style: ThemeTextStyles.body.copyWith(
              color: ThemeColors.onColor(color),
            ),
          ),
        ),
      );
  }
}