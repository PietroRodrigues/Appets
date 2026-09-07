import 'package:appets/core/backfill/pet_tokens_backfill.dart';
import 'package:appets/core/backfill/pet_tokens_backfill_writer.dart';
import 'package:appets/models/model_pet.dart';

/// Orquestra a migração dos tokens PT para um lote de pets.
///
/// Calcula o diff (lógica pura) e delega a gravação ao [writer]. Sem
/// dependência de Firestore — testável injetando um writer fake.
class PetTokensBackfillRunner {
  PetTokensBackfillRunner(this._writer);

  final PetTokensBackfillWriter _writer;

  /// Devolve quantos pets foram atualizados (0 se nada pendente).
  Future<int> run(
    List<Pet> pets,
    Map<String, Map<String, dynamic>> storedFieldsByPetId,
  ) async {
    final pending = petTokensNeedingBackfill(pets, storedFieldsByPetId);
    if (pending.isEmpty) return 0;
    return _writer.write(pending);
  }
}