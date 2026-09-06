import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/pet_service.dart';

/// Fonte única e reativa das publicações do usuário logado, mantida em
/// memória.
///
/// Funciona como [FavoritesService]: mantém uma cópia em memória dos IDs
/// dos pets publicados (persistida em `users/{uid}.myPublishedPetIds`) e
/// notifica a interface via [ValueNotifier] quando a lista muda.
///
/// Durante [loadForUser] é feito um *backfill*: busca os pets do dono
/// (pelo `ownerId`) e grava na lista quaisquer IDs que ainda não constem,
/// migrando publicações antigas criadas antes deste campo existir e se
/// auto-reparando caso a lista fique dessincronizada.
class MyPublicationsService {
  MyPublicationsService._();

  static final MyPublicationsService instance = MyPublicationsService._();

  final ValueNotifier<Set<String>> _myPetIds = ValueNotifier<Set<String>>(
    <String>{},
  );

  /// Notificador do conjunto de IDs de pets publicados. Escute para reagir
  /// às mudanças em qualquer tela.
  ValueNotifier<Set<String>> get myPetIds => _myPetIds;

  /// Conjunto atual de IDs de pets publicados.
  Set<String> get current => _myPetIds.value;

  /// Indica se o pet é uma publicação do usuário logado.
  bool isMine(String petId) => _myPetIds.value.contains(petId);

  /// Carrega as publicações do usuário a partir do Firestore, preenchendo
  /// com o backfill para migrar pets já publicados.
  Future<void> loadForUser(String uid) async {
    final user = await FirestoreService.instance.getUser(uid);
    final stored = (user?.myPublishedPetIds ?? const <String>[]).toSet();
    final known = await _fetchOwnedPetIds(uid);
    final merged = stored.union(known);
    _myPetIds.value = merged;

    final missing = known.difference(stored);
    if (missing.isEmpty) return;
    try {
      await FirestoreService.instance.updateUser(uid, {
        'myPublishedPetIds': FieldValue.arrayUnion(missing.toList()),
      });
    } catch (_) {
      // Melhor esforço: o estado local já está correto; a persistência
      // será tentada novamente na próxima abertura.
    }
  }

  Future<Set<String>> _fetchOwnedPetIds(String uid) async {
    try {
      final pets = await PetService.instance.getPetsByOwner(uid);
      return pets.map((p) => p.id).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  /// Adiciona um pet às publicações de forma otimista, persistindo no
  /// Firestore. Devolve `true` em caso de sucesso; `false` (com o estado
  /// local revertido) se a persistência falhar.
  Future<bool> add(String uid, String petId) async {
    final next = Set<String>.from(_myPetIds.value)..add(petId);
    _myPetIds.value = next;
    try {
      await FirestoreService.instance.addMyPet(uid, petId);
      return true;
    } catch (_) {
      _myPetIds.value = _myPetIds.value.difference({petId});
      return false;
    }
  }

  /// Remove um pet das publicações de forma otimista, persistindo no
  /// Firestore. Devolve `true` em caso de sucesso; `false` (com o estado
  /// local revertido) se a persistência falhar.
  Future<bool> remove(String uid, String petId) async {
    final next = Set<String>.from(_myPetIds.value)..remove(petId);
    _myPetIds.value = next;
    try {
      await FirestoreService.instance.removeMyPet(uid, petId);
      return true;
    } catch (_) {
      final restored = Set<String>.from(_myPetIds.value)..add(petId);
      _myPetIds.value = restored;
      return false;
    }
  }

  /// Remove um pet do estado local, sem persistir.
  void removeLocal(String petId) {
    if (!_myPetIds.value.contains(petId)) return;
    final next = Set<String>.from(_myPetIds.value)..remove(petId);
    _myPetIds.value = next;
  }

  /// Remove vários pets do estado local de uma só vez (uma única
  /// notificação).
  void removeLocalMany(Iterable<String> petIds) {
    final ids = petIds.toSet();
    if (ids.isEmpty) return;
    final next = Set<String>.from(_myPetIds.value)..removeAll(ids);
    if (next.length == _myPetIds.value.length) return;
    _myPetIds.value = next;
  }

  /// Zera o estado (uso em testes e ao deslogar).
  void reset() {
    _myPetIds.value = <String>{};
  }

  /// Remove das publicações (local + Firestore) os IDs que não constam mais
  /// entre os pets existentes.
  Future<void> cleanOrphans(String uid, Iterable<String> existingIds) async {
    final known = existingIds.toSet();
    final orphans = _myPetIds.value.difference(known).toList();

    if (orphans.isEmpty) return;

    removeLocalMany(orphans);

    try {
      await FirestoreService.instance.updateUser(uid, {
        'myPublishedPetIds': FieldValue.arrayRemove(orphans),
      });
    } catch (_) {
      // Melhor esforço: a remoção local já foi feita; se a escrita no
      // Firestore falhar, a lista voltará ao normal ao recarregar.
    }
  }
}
