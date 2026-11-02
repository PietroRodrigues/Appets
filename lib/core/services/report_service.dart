import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

/// Persiste denúncias de conteúdo enviadas por usuários autenticados.
class ReportService {
  ReportService._();

  static final ReportService instance = ReportService._();

  FirebaseFirestore? _debugDb;

  FirebaseFirestore get _db => _debugDb ?? FirebaseFirestore.instance;

  /// Permite injetar um Firestore de teste.
  @visibleForTesting
  set debugDb(FirebaseFirestore? db) => _debugDb = db;

  /// Salva uma denúncia na coleção `reports` com timestamp do servidor.
  Future<void> createReport({
    required String authorId,
    required String targetId,
    required String reason,
  }) async {
    await _db.collection('reports').add({
      'autorId': authorId,
      'alvoId': targetId,
      'motivo': reason,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
