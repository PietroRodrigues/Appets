// ignore_for_file: constant_identifier_names

/// Strings da interface dos detalhes do pet, centralizadas.
class PetDetailsStrings {
  PetDetailsStrings._();

  static const ADD_TO_FAVORITES = 'Adicionar aos favoritos';

  static const REMOVE_FROM_FAVORITES = 'Remover dos favoritos';

  static const SHARE_TOOLTIP = 'Compartilhar';

  static const OWNER_PHONE_UNAVAILABLE =
      'Telefone do proprietário não disponível.';

  static String whatsAppMessage(String petName) =>
      'Olá! Vi o pet $petName no APPets e gostaria de saber mais.';

  static const WHATSAPP_ERROR = 'Não foi possível abrir o WhatsApp.';

  static const CONTACT_BUTTON = 'Entrar em contato';

  static const ABOUT_SECTION = 'Sobre';

  static const DESCRIPTION_NOT_INFORMED = 'Descrição não informada.';

  // ── Compartilhamento ──────────────────────────────────

  static const SHARE_ERROR = 'Não foi possível compartilhar. Tente novamente.';

  static const SHARE_FOOTER = '📲 Entre em contato direto no APPets';

  static const SHARE_ADOPTION_HEADING = '💰 Adoção';

  static const SHARE_LOST_HEADING = '⚠️ Perdido';

  static String shareAdoptionTitle(String petName) =>
      '🐾 $petName está procurando um novo lar!';

  static String shareLostTitle(String petName) => '🐾 AJUDA! Encontre o $petName!';

  static String shareLocationLine(String location) => '📍 $location';

  static String shareLostRegionLine(String location) =>
      '📍 Foi visto na região de: $location';

  static String sharePhoneLine(String phone) => '📞 $phone';

  static String shareLostPhoneLine(String phone) =>
      '📞 Se encontrar, entre em contato: $phone';
}
