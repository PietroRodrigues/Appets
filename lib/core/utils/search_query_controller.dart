import 'package:flutter/foundation.dart';

/// Controlador do termo de busca das telas com feed de pets.
///
/// Centraliza o estado da busca (evita o boilerplate de `_searchQuery` +
/// `setState` repetido em cada tela) e notifica ouvintes a cada mudança.
class SearchQueryController extends ValueNotifier<String> {
  SearchQueryController() : super('');

  /// Limpa o termo de busca, notificando os ouvintes com `''`.
  void clear() => value = '';
}