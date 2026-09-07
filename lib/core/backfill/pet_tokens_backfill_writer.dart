/// Grava os campos de token PT calculados de um lote de pets.
///
/// A migração depende apenas desta interface: hoje existe um adapter de
/// Firestore client; no futuro pode ser trocado por um de Admin SDK (ou
/// removido) sem tocar no restante do módulo.
abstract class PetTokensBackfillWriter {
  /// Devolve quantos documentos foram atualizados.
  Future<int> write(Map<String, Map<String, dynamic>> updatesByPetId);
}