import 'package:appets/core/utils/storage_tokens.dart';
import 'package:appets/models/model_pet.dart';

/// Campos de token persistidos no documento `pets`.
///
/// São os únicos campos de identificação derivados de enums; todos devem
/// estar em PT normalizado. A migração usa exatamente esta lista.
Map<String, dynamic> petTokenFields(Pet pet) => {
      'species': speciesStorageToken(pet.species),
      'gender': genderStorageToken(pet.gender),
      'ageUnit': ageUnitStorageToken(pet.ageUnit),
      'publicationType': publicationTypeStorageToken(pet.publicationType),
      'specifications': pet.specifications,
    };

/// Lógica pura da migração de tokens dos pets.
///
/// Compara os campos persistidos ([storedFieldsByPetId]) com os valores
/// PT derivados atuais e devolve, por id, apenas o que diverge (ausente,
/// legado em inglês ou desatualizado). Sem dependência de Firestore —
/// testável.
///
/// Idempotente por construção: na segunda execução nada fica pendente.
Map<String, Map<String, dynamic>> petTokensNeedingBackfill(
  Iterable<Pet> pets,
  Map<String, Map<String, dynamic>> storedFieldsByPetId,
) {
  final pending = <String, Map<String, dynamic>>{};
  for (final pet in pets) {
    final update = <String, dynamic>{};
    final stored = storedFieldsByPetId[pet.id] ?? const <String, dynamic>{};
    for (final MapEntry(key: field, value: expected) in petTokenFields(pet).entries) {
      if (!_sameStoredField(stored[field], expected)) {
        update[field] = expected;
      }
    }
    if (update.isNotEmpty) pending[pet.id] = update;
  }
  return pending;
}

/// Compara o valor persistido com o esperado (string ou lista de strings).
bool _sameStoredField(Object? stored, Object expected) {
  if (expected is! List<String>) return stored == expected;
  if (stored is! List) return false;
  final storedStrings = stored.whereType<String>().toList();
  if (storedStrings.length != expected.length) return false;
  for (var i = 0; i < expected.length; i++) {
    if (storedStrings[i] != expected[i]) return false;
  }
  return true;
}