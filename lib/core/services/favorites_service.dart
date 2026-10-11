import 'package:flutter/foundation.dart';

import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/user_pet_ids_service.dart';
import 'package:appets/models/user_model.dart';

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
///
/// Estende [UserPetIdsService]: toda a mecânica otimista e de limpeza de
/// órfãos vem da base; aqui ficam só o campo persistido, as escritas do
/// Firestore e os notifiers reativos por pet.
class FavoritesService extends UserPetIdsService {
  FavoritesService._() : super('favoritePetIds');

  static final FavoritesService instance = FavoritesService._();

  /// Caches reativos por pet (1 por ID já exibido em card). Mantêm a UI
  /// reagindo apenas ao favorito do próprio pet.
  final Map<String, ValueNotifier<bool>> _perPet = {};

  /// Notificador do conjunto de IDs favoritados. Escute para reagir
  /// às mudanças de favorito em qualquer tela.
  ValueNotifier<Set<String>> get favoriteIds => ids;

  /// Indica se o pet é favorito do usuário logado.
  bool isFavorite(String petId) => contains(petId);

  /// Listenable reativo do estado de favorito de [petId], usado pelos
  /// cards para redesenhar apenas o próprio pet quando qualquer favorito
  /// muda (em vez de reconstruir o grid inteiro).
  ValueListenable<bool> isFavoriteListenable(String petId) => _perPet
      .putIfAbsent(petId, () => ValueNotifier<bool>(isFavorite(petId)));

  /// Carrega os favoritos a partir do [user] já buscado (única leitura do
  /// documento do usuário, feita quem chama). Sem leitura do Firestore aqui;
  /// `null` significa lista vazia.
  void applyUser(UserModel? user) {
    applyIds(user?.favoritePetIds);
  }

  @override
  Future<void> persistAdd(String uid, String petId) =>
      FirestoreService.instance.addFavorite(uid, petId);

  @override
  Future<void> persistRemove(String uid, String petId) =>
      FirestoreService.instance.removeFavorite(uid, petId);

  @override
  void onPetChanged(String petId, bool value) {
    _perPet[petId]?.value = value;
  }

  @override
  void onAllChanged() {
    for (final entry in _perPet.entries) {
      entry.value.value = ids.value.contains(entry.key);
    }
  }

  @override
  void onReset() {
    _perPet.clear();
  }
}
