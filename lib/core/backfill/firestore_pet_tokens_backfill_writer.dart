import 'package:appets/core/backfill/pet_tokens_backfill_writer.dart';
import 'package:appets/core/services/pet_service.dart';

/// Adapta a gravação em lote do Firestore (client) à interface do módulo.
class FirestorePetTokensBackfillWriter implements PetTokensBackfillWriter {
  FirestorePetTokensBackfillWriter(this._petService);

  final PetService _petService;

  @override
  Future<int> write(Map<String, Map<String, dynamic>> updatesByPetId) {
    return _petService.updatePetsBatch(updatesByPetId);
  }
}