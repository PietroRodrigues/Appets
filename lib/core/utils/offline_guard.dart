import 'package:flutter/widgets.dart';

import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/services/connectivity_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/widgets/feedback/widget_dialogs.dart';

/// Guarda de rede para operações que mutam dados no back-end.
///
/// Retorna `true` e deixa a operação seguir quando o dispositivo está
/// online. Offline, mostra um diálogo "Sem conexão" e retorna `false`
/// (a operação deve ser abortada antes de tocar no Firebase).
Future<bool> ensureOnline(BuildContext context) async {
  if (ConnectivityService.instance.isOnline) return true;

  await WGDialog.showAction(
    context,
    title: SharedStrings.NO_CONNECTION,
    message: SharedStrings.NO_CONNECTION_DESCRIPTION,
    actionColor: ThemeColors.error,
  );
  return false;
}