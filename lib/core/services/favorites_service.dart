import 'package:flutter/foundation.dart';

import 'package:appets/core/services/firestore_service.dart';

/// Fonte única e reativa dos favoritos do usuário logado, mantida em
/// memória.
///
/// Todos os cards, a tela de detalhes e a lista de favoritos escutam
/// o mesmo [ValueNotifier], garantindo que o estado da estrela fique
/// sincronizado entre os lugares imediatamente.
///
/// A persistência continua no Firestore (`users/{uid}.favoritePetIds`),
/// mas este serviço mantém uma cópia em memória que é atualizada de
/// forma otimista. Se a escrita no Firestore falhar, o estado local é
/// revertido e [add]/[remove] devolvem `false` para a UI exibir um erro.
class FavoritesService {
  FavoritesService._();

  static final FavoritesService instance = FavoritesService._();

  final ValueNotifier<Set<String>> _favoriteIds =
      ValueNotifier<Set<String>>(<String>{});

  /// Notificador do conjunto de IDs favoritados. Escute para reagir
  /// às mudanças de favorito em qualquer tela.
  ValueNotifier<Set<String>> get favoriteIds => _favoriteIds;

  /// Conjunto atual de IDs favoritados.
  Set<String> get current => _favoriteIds.value;

  /// Indica se o pet é favorito do usuário logado.
  bool isFavorite(String petId) => _favoriteIds.value.contains(petId);

  /// Carrega os favoritos do usuário a partir do Firestore,
  /// substituindo o estado local.
  Future<void> loadForUser(String uid) async {
    final user = await FirestoreService().getUser(uid);
    _favoriteIds.value = (user?.favoritePetIds ?? const <String>[]).toSet();
  }

  /// Adiciona um pet aos favoritos de forma otimista, persistindo no
  /// Firestore. Devolve `true` em caso de sucesso; `false` (com o
  /// estado local revertido) se a persistência falhar.
  Future<bool> add(String uid, String petId) async {
    final next = Set<String>.from(_favoriteIds.value)..add(petId);
    _favoriteIds.value = next;
    try {
      await FirestoreService().addFavorite(uid, petId);
      return true;
    } catch (_) {
      _favoriteIds.value = _favoriteIds.value.difference({petId});
      return false;
    }
  }

  /// Remove um pet dos favoritos de forma otimista, persistindo no
  /// Firestore. Devolve `true` em caso de sucesso; `false` (com o
  /// estado local revertido) se a persistência falhar.
  Future<bool> remove(String uid, String petId) async {
    final next = Set<String>.from(_favoriteIds.value)..remove(petId);
    _favoriteIds.value = next;
    try {
      await FirestoreService().removeFavorite(uid, petId);
      return true;
    } catch (_) {
      final restored = Set<String>.from(_favoriteIds.value)..add(petId);
      _favoriteIds.value = restored;
      return false;
    }
  }

  /// Remove um pet do estado local, sem persistir. Usado para limpar
  /// órfãos (pets deletados) que ainda constam como favoritos.
  void removeLocal(String petId) {
    if (!_favoriteIds.value.contains(petId)) return;
    final next = Set<String>.from(_favoriteIds.value)..remove(petId);
    _favoriteIds.value = next;
  }

  /// Remove vários pets do estado local de uma só vez (uma única
  /// notificação). Usado pela limpeza de órfãos para evitar uma
  /// notificação por item.
  void removeLocalMany(Iterable<String> petIds) {
    final ids = petIds.toSet();
    if (ids.isEmpty) return;
    final next = Set<String>.from(_favoriteIds.value)..removeAll(ids);
    if (next.length == _favoriteIds.value.length) return;
    _favoriteIds.value = next;
  }

  /// Zera o estado (uso em testes e ao deslogar).
  void reset() {
    _favoriteIds.value = <String>{};
  }
}
