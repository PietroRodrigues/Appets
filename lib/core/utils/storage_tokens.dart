/// Tokens de armazenamento (Firestore) dos enums de pet, sempre em
/// português e normalizados (minúsculas, sem acento — o mesmo padrão do
/// [buildSearchTokens] da busca).
///
/// Este arquivo é a fonte única para duas operações:
/// - gravação: `*StorageToken(enum)` gera o código persistido;
/// - leitura: `*FromStored(valor)` interpreta o valor persistido, aceitando
///   o token PT atual **ou** o código legado em inglês (`dog`, `male`,
///   `years`, `adoption`, ...) até a migração completar.
library;

import 'package:appets/core/utils/search_tokens.dart';
import 'package:appets/models/enums/enums_app.dart';

/// Faixas de idade persistidas (em meses): Filhote < 12, Jovem 12 a 60
/// (até 5 anos), Adulto > 60.
const String kAgeBracketFilhote = 'filhote';
const String kAgeBracketJovem = 'jovem';
const String kAgeBracketAdulto = 'adulto';

// ── Espécie ─────────────────────────────────────────────

String speciesStorageToken(AppPetSpecies species) =>
    normalizeText(species.label);

AppPetSpecies speciesFromStored(Object? value) => _fromStored(
      value,
      values: AppPetSpecies.values,
      tokenOf: speciesStorageToken,
      fallback: AppPetSpecies.dog,
    );

// ── Gênero ─────────────────────────────────────────────

String genderStorageToken(AppPetGender gender) => normalizeText(gender.label);

AppPetGender genderFromStored(Object? value) => _fromStored(
      value,
      values: AppPetGender.values,
      tokenOf: genderStorageToken,
      fallback: AppPetGender.male,
    );

// ── Unidade de idade ────────────────────────────────────

String ageUnitStorageToken(AppPetAgeUnit ageUnit) =>
    normalizeText(ageUnit.label);

AppPetAgeUnit ageUnitFromStored(Object? value) => _fromStored(
      value,
      values: AppPetAgeUnit.values,
      tokenOf: ageUnitStorageToken,
      fallback: AppPetAgeUnit.years,
    );

// ── Tipo de publicação ──────────────────────────────────

String publicationTypeStorageToken(AppPetPublicationType type) =>
    normalizeText(type.label);

AppPetPublicationType publicationTypeFromStored(Object? value) => _fromStored(
      value,
      values: AppPetPublicationType.values,
      tokenOf: publicationTypeStorageToken,
      fallback: AppPetPublicationType.adoption,
    );

// ── Base compartilhada ──────────────────────────────────

/// Interpreta um valor persistido como um membro do enum [T]:
/// primeiro tenta o token PT normalizado; em seguida o nome legado em
/// inglês (`enum.name`); desconhecido/ausente usa [fallback].
T _fromStored<T extends Enum>(
  Object? value, {
  required List<T> values,
  required String Function(T) tokenOf,
  required T fallback,
}) {
  if (value is! String) return fallback;
  final normalized = normalizeText(value);
  for (final member in values) {
    if (tokenOf(member) == normalized) return member;
  }
  for (final member in values) {
    if (member.name == value) return member;
  }
  return fallback;
}