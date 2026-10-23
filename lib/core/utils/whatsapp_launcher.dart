import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:appets/core/constants/constants_strings_pet_details.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/widgets/feedback/widget_dialogs.dart';
import 'package:url_launcher/url_launcher.dart';

/// Normaliza o telefone para o WhatsApp: mantém apenas dígitos e prefixa
/// `55` somente quando o número não começa já com o DDI do Brasil.
String normalizeWhatsAppPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return '';
  return digits.startsWith('55') ? digits : '55$digits';
}

/// Abre a conversa do WhatsApp com o responsável pelo pet [petName],
/// usando o número [ownerPhone] e a mensagem padrão do app.
///
/// Caminhos:
/// - Telefone ausente → aviso "Telefone do proprietário não disponível.".
/// - Abertura mal-sucedida (`launchUrl` devolve `false` ou lança
///   `PlatformException`) → erro "Não foi possível abrir o WhatsApp.".
///
/// Não usa `canLaunchUrl`: a partir do Android 11 (API 30+) a filtragem
/// de visibilidade de pacotes faz a consulta devolver `false` sem a
/// declaração de `<queries>` no manifest, bloqueando uma abertura que
/// teria sucesso. A recomendação do url_launcher é chamar `launchUrl`
/// direto e tratar a falha.
Future<void> openWhatsAppContact(
  BuildContext context, {
  required String ownerPhone,
  required String petName,
}) async {
  final normalized = normalizeWhatsAppPhone(ownerPhone);
  if (normalized.isEmpty) {
    if (!context.mounted) return;
    await WGDialog.showAction(
      context,
      title: SharedStrings.NOTICE_TITLE,
      message: PetDetailsStrings.OWNER_PHONE_UNAVAILABLE,
    );
    return;
  }

  final message = Uri.encodeComponent(
    PetDetailsStrings.whatsAppMessage(petName),
  );
  final url = Uri.parse('https://wa.me/$normalized?text=$message');

  try {
    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (launched) return;
  } on PlatformException {
    // Falha no canal da plataforma: cai no mesmo diálogo de erro abaixo.
  }

  if (!context.mounted) return;
  await WGDialog.showAction(
    context,
    title: SharedStrings.ERROR_TITLE,
    message: PetDetailsStrings.WHATSAPP_ERROR,
    actionColor: context.appColors.error,
  );
}
