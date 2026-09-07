import 'dart:async';

import 'package:appets/core/backfill/firestore_pet_tokens_backfill_writer.dart';
import 'package:appets/core/backfill/pet_tokens_backfill_runner.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/models/model_pet.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Executa, de forma isolada e silenciosa, a migração dos tokens PT
/// (species, gender, ageUnit, publicationType e specifications) dos pets
/// do dono logado no momento.
///
/// Auto-alimentado: escuta a autenticação, busca os próprios documentos e
/// grava apenas o que divergir (códigos legados em inglês, ausentes ou
/// desatualizados). Nenhum outro módulo do app precisa conhecer a
/// migração — a única ativação é `attach()`, chamada no `main.dart`.
///
/// Para desacoplar depois: apagar a chamada `attach()` do `main.dart` e a
/// pasta `lib/core/backfill/` (e, se desejado, os helpers de migração do
/// [PetService]).
class PetTokensBackfillInitializer {
  PetTokensBackfillInitializer._();

  static final PetTokensBackfillInitializer instance =
      PetTokensBackfillInitializer._();

  final PetTokensBackfillRunner _runner = PetTokensBackfillRunner(
    FirestorePetTokensBackfillWriter(PetService.instance),
  );

  String? _lastUid;
  StreamSubscription<User?>? _subscription;

  /// Passa a escutar a autenticação, disparando a migração uma vez por
  /// login (idempotente; custa só leitura quando nada pendente).
  void attach() {
    _subscription ??= AuthService.instance.authStateChanges.listen(_onAuth);
  }

  void _onAuth(User? user) {
    if (user == null) {
      _lastUid = null;
      return;
    }
    if (user.uid == _lastUid) return;
    _lastUid = user.uid;
    unawaited(_migrate(user.uid));
  }

  Future<void> _migrate(String uid) async {
    try {
      final docs = await PetService.instance.getOwnerPetDocuments(uid);
      final pets = docs.map((doc) => Pet.fromFirestore(doc)).toList();
      final stored = <String, Map<String, dynamic>>{
        for (final doc in docs)
          if (doc.data() is Map<String, dynamic>)
            doc.id: doc.data() as Map<String, dynamic>,
      };
      await _runner.run(pets, stored);
    } catch (_) {
      // Melhor esforço: nunca derruba o app. A migração é idempotente e
      // será retentada no próximo login.
    }
  }
}