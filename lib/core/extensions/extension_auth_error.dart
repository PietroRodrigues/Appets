/// Helpers para mapear exceções de autenticação em mensagens de interface.
extension AppAuthErrorX on Exception {
  /// Retorna a mensagem correspondente ao código de erro contido na
  /// exceção, usando [defaultMessage] quando nenhum código é reconhecido.
  ///
  /// O mapa [codes] associa o código interno do Firebase (ex.: 'user-not-found')
  /// à mensagem exibida ao usuário.
  String authMessage(
    String defaultMessage,
    Map<String, String> codes,
  ) {
    final errorStr = toString();
    for (final entry in codes.entries) {
      if (errorStr.contains(entry.key)) {
        return entry.value;
      }
    }
    return defaultMessage;
  }
}
