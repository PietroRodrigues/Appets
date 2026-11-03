import 'dart:async';

import 'package:appets/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show ValueNotifier, visibleForTesting;

/// Mantém os usuários bloqueados pelo usuário atual.
///
/// A lista fica exposta em [blockedIds] e é observada pelo feed, busca e
/// tela de detalhes. A persistência usa a coleção `blocks`, com um
/// documento determinístico (`blockerId_blockedId`), o que evita duplicatas
/// e simplifica a remoção.
class BlockService {
  BlockService._();

  static final BlockService instance = BlockService._();

  FirebaseFirestore? _debugDb;

  FirebaseFirestore get _db => _debugDb ?? FirebaseFirestore.instance;

  /// Permite injetar um Firestore de teste.
  @visibleForTesting
  set debugDb(FirebaseFirestore? db) => _debugDb = db;

  /// IDs dos usuários bloqueados pelo usuário atual.
  final ValueNotifier<Set<String>> blockedIds = ValueNotifier<Set<String>>({});

  String? _currentUid;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  bool isBlocked(String userId) => blockedIds.value.contains(userId);

  /// Carrega (e escuta em tempo real) a lista de bloqueados de [uid].
  Future<void> init(String? uid) async {
    if (uid == null || uid.isEmpty) {
      reset();
      return;
    }
    if (_currentUid == uid && _sub != null) return;

    reset();
    _currentUid = uid;

    final snapshot = await _db
        .collection('blocks')
        .where('blockerId', isEqualTo: uid)
        .get();
    blockedIds.value = _idsFromSnapshot(snapshot);

    _sub = _db
        .collection('blocks')
        .where('blockerId', isEqualTo: uid)
        .snapshots()
        .listen(
      (snapshot) {
        blockedIds.value = _idsFromSnapshot(snapshot);
      },
      onError: (Object _) {
        // Falha na stream não deve derrubar a UI; a última lista válida
        // permanece até a próxima recarga.
      },
    );
  }

  Set<String> _idsFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return {
      for (final doc in snapshot.docs)
        (doc.data()['blockedId'] as String? ??
            doc.id.split('_').last),
    }..removeWhere((id) => id.isEmpty);
  }

  /// Bloqueia [blockedId] para [blockerId].
  Future<bool> block(String blockerId, String blockedId) async {
    if (blockerId.isEmpty ||
        blockedId.isEmpty ||
        blockerId == blockedId) {
      return false;
    }

    try {
      final docId = '${blockerId}_$blockedId';
      await _db.collection('blocks').doc(docId).set({
        'blockerId': blockerId,
        'blockedId': blockedId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      blockedIds.value = {...blockedIds.value, blockedId};
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Remove o bloqueio de [blockedId] para [blockerId].
  Future<bool> unblock(String blockerId, String blockedId) async {
    if (blockerId.isEmpty || blockedId.isEmpty) return false;

    try {
      final docId = '${blockerId}_$blockedId';
      await _db.collection('blocks').doc(docId).delete();
      final next = {...blockedIds.value}..remove(blockedId);
      blockedIds.value = next;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Resolve os perfis bloqueados, para exibi-los na tela de gestão.
  Future<List<UserModel>> getBlockedUsers(String blockerId) async {
    if (blockerId.isEmpty) return [];

    final snapshot = await _db
        .collection('blocks')
        .where('blockerId', isEqualTo: blockerId)
        .get();

    final ids = <String>[
      for (final doc in snapshot.docs)
        doc.data()['blockedId'] as String? ?? '',
    ]..removeWhere((id) => id.isEmpty);

    final users = <UserModel>[];
    for (final id in ids) {
      final userDoc = await _db.collection('users').doc(id).get();
      if (userDoc.exists) {
        users.add(UserModel.fromFirestore(userDoc));
      }
    }
    users.sort((a, b) => a.name.compareTo(b.name));
    return users;
  }

  /// Zera o estado ao trocar/perder a sessão (evita vazamento entre contas).
  void reset() {
    _sub?.cancel();
    _sub = null;
    _currentUid = null;
    blockedIds.value = <String>{};
  }
}