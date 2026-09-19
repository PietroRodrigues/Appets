// ignore_for_file: constant_identifier_names

/// Strings genéricas da interface, compartilhadas entre setores.
class SharedStrings {
  SharedStrings._();

  static const SLOGAN = 'Encontre um novo melhor amigo.';

  static String featureInDevelopment(String feature) =>
      '$feature em desenvolvimento';

  static const YES = 'Sim';

  static const NO = 'Não';

  static const OK = 'OK';

  static const SUCCESS_TITLE = 'Sucesso';

  static const ERROR_TITLE = 'Erro';

  static const DEVELOPMENT_TITLE = 'Em desenvolvimento';

  static const NOTICE_TITLE = 'Aviso';

  static const NO_CONNECTION = 'Sem conexão';

  static const NO_CONNECTION_DESCRIPTION =
      'Você está offline. Verifique sua conexão e tente novamente.';

  static const CONNECTION_RESTORED = 'Conexão estabelecida';

  static const LOAD_DATA_ERROR_TITLE = 'Não foi possível carregar os dados';

  static const LOAD_DATA_ERROR_DESCRIPTION =
      'Verifique sua conexão e tente novamente.';
}
