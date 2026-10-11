import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:appets/core/services/firestore_service.dart';

/// Base dos serviços que mantêm, em memória, um conjunto de IDs de pets do
/// usuário logado, com escrita otimista no Firestore.
///
/// Concentra a lógica comum a [FavoritesService] e [MyPublicationsService]:
/// o notifier do conjunto, a inclusão/remoção otimistas (com rollback por
/// snapshot) e a limpeza de órfãos. A subclasse define o campo persistido no
/// documento `users/{uid}` e as operações de escrita, podendo ainda derivar
/// estado extra pelos ganchos ([onPetChanged], [onAllChanged], [onReset]).
abstract class UserPetIdsService {
  UserPetIdsService(this._field);

  /// Campo do documento `users/{uid}` onde o conjunto de IDs é persistido.
  final String _field;

  final ValueNotifier<Set<String>> _ids = ValueNotifier<Set<String>>(<String>{});

  /// Notificador do conjunto de IDs. Escute para reagir às mudanças.
  ValueNotifier<Set<String>> get ids => _ids;

  /// Conjunto atual de IDs.
  Set<String> get current => _ids.value;

  /// Indica se [petId] consta no conjunto.
  bool contains(String petId) => _ids.value.contains(petId);

  /// Substitui o conjunto inteiro a partir de uma fonte já lida (sem leitura
  /// do Firestore aqui). `null`/vazio limpa o conjunto.
  @protected
  void applyIds(Iterable<String>? petIds) {
    _ids.value = (petIds ?? const <String>[]).toSet();
    onAllChanged();
  }

  // ── Ganchos das subclasses ──────────────────────────────

  /// Persiste a inclusão de [petId] em `users/{uid}`.
  Future<void> persistAdd(String uid, String petId);

  /// Persiste a remoção de [petId] de `users/{uid}`.
  Future<void> persistRemove(String uid, String petId);

  /// Chamado quando o estado de um pet muda (inclusão/remoção). No-op aqui.
  void onPetChanged(String petId, bool value) {}

  /// Chamado após o conjunto inteiro ser substituído. No-op aqui.
  void onAllChanged() {}

  /// Chamado após [reset]. No-op aqui.
  void onReset() {}

  // ── Otimista ────────────────────────────────────────────

  /// Adiciona um pet de forma otimista, persistindo no Firestore. Devolve
  /// `true` em caso de sucesso; `false` (com o estado local revertido ao
  /// snapshot capturado antes da escrita) se a persistência falhar.
  Future<bool> add(String uid, String petId) async {
    final snapshot = Set<String>.from(_ids.value);
    final next = Set<String>.from(snapshot)..add(petId);
    _ids.value = next;
    onPetChanged(petId, true);
    try {
      await persistAdd(uid, petId);
      return true;
    } catch (_) {
      _ids.value = snapshot;
      onPetChanged(petId, false);
      return false;
    }
  }

  /// Remove um pet de forma otimista, persistindo no Firestore. Devolve
  /// `true` em caso de sucesso; `false` (com o estado local revertido ao
  /// snapshot capturado antes da escrita) se a persistência falhar.
  Future<bool> remove(String uid, String petId) async {
    final snapshot = Set<String>.from(_ids.value);
    final next = Set<String>.from(snapshot)..remove(petId);
    _ids.value = next;
    onPetChanged(petId, false);
    try {
      await persistRemove(uid, petId);
      return true;
    } catch (_) {
      _ids.value = snapshot;
      onPetChanged(petId, true);
      return false;
    }
  }

  /// Remove um pet do estado local, sem persistir. Usado para limpar órfãos
  /// (pets deletados) que ainda constam no conjunto.
  void removeLocal(String petId) {
    if (!_ids.value.contains(petId)) return;
    final next = Set<String>.from(_ids.value)..remove(petId);
    _ids.value = next;
    onPetChanged(petId, false);
  }

  /// Remove vários pets do estado local de uma só vez (uma única
  /// notificação).
  void removeLocalMany(Iterable<String> petIds) {
    final ids = petIds.toSet();
    if (ids.isEmpty) return;
    final next = Set<String>.from(_ids.value)..removeAll(ids);
    if (next.length == _ids.value.length) return;
    _ids.value = next;
    for (final id in ids) {
      onPetChanged(id, false);
    }
  }

  /// Zera o estado (uso em testes e ao deslogar).
  void reset() {
    _ids.value = <String>{};
    onAllChanged();
    onReset();
  }

  /// Remove (local + Firestore) os IDs que não constam mais entre os pets
  /// existentes. Usado ao carregar para limpar "órfãos" (pets deletados que
  /// ainda estavam marcados).
  Future<void> cleanOrphans(String uid, Iterable<String> existingIds) async {
    final known = existingIds.toSet();
    final orphans = _ids.value.difference(known).toList();

    if (orphans.isEmpty) return;

    removeLocalMany(orphans);

    try {
      await FirestoreService.instance.updateUser(uid, {
        _field: FieldValue.arrayRemove(orphans),
      });
    } catch (_) {
      // Melhor esforço: a remoção local já foi feita; se a escrita no
      // Firestore falhar, os IDs voltarão ao normal ao recarregar.
    }
  }
}
