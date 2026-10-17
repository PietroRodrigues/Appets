// ignore_for_file: constant_identifier_names

/// Strings da interface de configurações e sobre o app, centralizadas.
class SettingsStrings {
  SettingsStrings._();

  static const SETTINGS_TITLE = 'Configurações';

  static const SHARE_LOCATION_TITLE = 'Compartilhar localização';

  static const SHARE_LOCATION_SUBTITLE = 'Permitir acesso à sua localização';

  static const SHARE_LOCATION_FEATURE = 'Configurações de privacidade';

  static const APP_ABOUT_TITLE = 'Sobre o APPets';

  /// Versão exibida na tela "Sobre". Lida dinamicamente do pubspec.yaml
  /// via [readAppVersion] para evitar divergência com o build number.
  static const APP_ABOUT_SUBTITLE = 'Versão';

  static const APP_ABOUT_FEATURE = 'Sobre o app';

  // ===== Tela "Sobre o APPets" =====

  static const ABOUT_APP_NAME = 'APPets';

  static const ABOUT_ABOUT_SECTION = 'O que é o APPets';

  static const ABOUT_FEATURES_SECTION = 'Funcionalidades';

  static const ABOUT_DESCRIPTION =
      'O APPets centraliza anúncios de adoção e pets perdidos em um só '
      'lugar. Responsáveis publicam pets com fotos e informações '
      'completas, e interessados exploram o feed, buscam e salvam '
      'favoritos.';

  static const ABOUT_FEATURE_PUBLISH =
      'Publique pets para adoção ou desaparecidos com fotos e informações completas.';

  static const ABOUT_FEATURE_SEARCH =
      'Busque por nome ou qualquer termo da descrição, mesmo com acentos ou letras diferentes.';

  static const ABOUT_FEATURE_FAVORITES =
      'Salve pets favoritos e veja a lista atualizar em todas as telas na hora.';

  static const ABOUT_FEATURE_CONTACT =
      'Fale com o responsável direto pelo WhatsApp usando o telefone do anúncio.';

  static const ABOUT_PROJECT_NOTE =
      'Projeto de estudo e portfólio, sem vínculo comercial.';
}
