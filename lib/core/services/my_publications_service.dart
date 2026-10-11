import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/core/services/user_pet_ids_service.dart';
import 'package:appets/models/user_model.dart';

/// Fonte única e reativa das publicações do usuário logado, mantida em
/// memória.
///
/// Funciona como [FavoritesService]: mantém uma cópia em memória dos IDs
/// dos pets publicados (persistida em `users/{uid}.myPublishedPetIds`) e
/// notifica a interface via [ValueNotifier] quando a lista muda.
///
/// Estende [UserPetIdsService]: toda a mecânica otimista e de limpeza de
/// órfãos vem da base; aqui ficam só o campo persistido, as escritas do
/// Firestore e o *backfill* de [applyUser].
///
/// Durante [applyUser] é feito um *backfill*: busca os pets do dono
/// (pelo `ownerId`) e grava na lista quaisquer IDs que ainda não constem,
/// migrando publicações antigas criadas antes deste campo existir e se
/// auto-reparando caso a lista fique dessincronizada.
class MyPublicationsService extends UserPetIdsService {
  MyPublicationsService._() : super('myPublishedPetIds');

  static final MyPublicationsService instance = MyPublicationsService._();

  /// Notificador do conjunto de IDs de pets publicados. Escute para reagir
  /// às mudanças em qualquer tela.
  ValueNotifier<Set<String>> get myPetIds => ids;

  /// Indica se o pet é uma publicação do usuário logado.
  bool isMine(String petId) => contains(petId);

  /// Carrega as publicações a partir do [user] já buscado (única leitura do
  /// documento do usuário, feita por quem chama — não há getUser aqui).
  /// `user == null` significa lista vazia, sem backfill. Com o user, roda o
  /// *backfill*: busca os pets do dono (pelo `ownerId`) e grava na lista
  /// quaisquer IDs que ainda não constem, migrando publicações antigas e se
  /// auto-reparando caso a lista fique dessincronizada. O uid para armazenar
  /// vem de [UserModel.id].
  Future<void> applyUser(UserModel? user) async {
    final uid = user?.id;
    final stored = (user?.myPublishedPetIds ?? const <String>[]).toSet();
    if (uid == null) {
      applyIds(stored);
      return;
    }
    final known = await _fetchOwnedPetIds(uid);
    final merged = stored.union(known);
    applyIds(merged);

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

  @override
  Future<void> persistAdd(String uid, String petId) =>
      FirestoreService.instance.addMyPet(uid, petId);

  @override
  Future<void> persistRemove(String uid, String petId) =>
      FirestoreService.instance.removeMyPet(uid, petId);

  Future<Set<String>> _fetchOwnedPetIds(String uid) async {
    try {
      final pets = await PetService.instance.getPetsByOwner(uid);
      return pets.map((p) => p.id).toSet();
    } catch (_) {
      return <String>{};
    }
  }
}
