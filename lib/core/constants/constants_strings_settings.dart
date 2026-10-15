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
}
