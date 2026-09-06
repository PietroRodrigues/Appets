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

  static String petAddedToFavorites(String petName) =>
      '$petName adicionado aos favoritos';

  static String petRemovedFromFavorites(String petName) =>
      '$petName removido dos favoritos';
}
