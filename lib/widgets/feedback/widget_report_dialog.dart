import 'package:appets/core/constants/constants_strings_report.dart';
import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/widgets/feedback/widget_dialogs.dart';
import 'package:flutter/material.dart';

/// Exibe a janela de denúncia com o dropdown de motivos e devolve o motivo
/// escolhido ao enviar (ou `null` se o usuário cancelar).
///
/// Usa o [WGDialog] padrão do app, com o [WGDropdownField] (widget próprio,
/// responsivo, sem overflow) e botões "Cancelar" + "Enviar" alinhados
/// horizontalmente.
Future<String?> showReportDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => WGDialog(
      title: ReportStrings.REPORT_TITLE,
      message: ReportStrings.REPORT_DESCRIPTION,
      isConfirmation: true,
      confirmLabel: ReportStrings.REPORT_SEND,
      cancelLabel: ReportStrings.REPORT_CANCEL,
      confirmColor: context.appColors.primary,
      dropdownItems: ReportStrings.reasons,
      dropdownLabel: ReportStrings.REPORT_REASON_LABEL,
      dropdownValidator: (reason) =>
          reason == null || reason.isEmpty
              ? ReportStrings.REPORT_REASON_REQUIRED
              : null,
    ),
  );
}
