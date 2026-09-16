/// Utilitários para a busca de pets.
///
/// Todos os textos são normalizados (minúsculas e sem acentos)
/// para que "Rex", "REX" e "rex" encontrem o mesmo pet.
library;

/// Remove acentos e converte para minúsculas.
String normalizeText(String input) {
  var text = input.toLowerCase().trim();
  const replacements = {
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
    'ñ': 'n',
  };
  for (final MapEntry(key: from, value: to) in replacements.entries) {
    text = text.replaceAll(from, to);
  }
  return text;
}

/// Quantidade máxima de tokens de busca persistidos por pet.
const int kMaxSearchTokens = 150;

/// Limite superior do comprimento de prefixo persistido por palavra.
const int kMaxSearchPrefixLength = 12;

/// Menor comprimento de prefixo persistido por palavra ("poo" já cobre,
/// por exemplo, "poodle", "poodlepreto"...).
const int kMinSearchPrefixLength = 3;

/// Gera a lista de palavras pesquisáveis a partir do nome e da
/// descrição ("Sobre o pet") do pet.
///
/// Normaliza, divide em palavras, ignora palavras com menos de 2
/// caracteres, remove duplicados e limita a quantidade de tokens.
///
/// Além da palavra inteira, grava os prefixos a partir de
/// [kMinSearchPrefixLength] até o menor entre o comprimento da palavra e
/// [kMaxSearchPrefixLength]. Isso permite à busca do servidor encontrar
/// digitação parcial: "poo" casa com o token "poo" de "poodle".
List<String> buildSearchTokens({required String name, String? description}) {
  final buffer = <String>[name, ?description];
  final tokens = <String>{};
  for (final part in buffer) {
    if (tokens.length >= kMaxSearchTokens) break;
    final words = normalizeText(part).split(RegExp(r'[^a-z0-9]+'));
    for (final word in words) {
      if (word.length < 2) continue;
      tokens.add(word);
      final last = word.length < kMaxSearchPrefixLength
          ? word.length
          : kMaxSearchPrefixLength;
      for (var i = kMinSearchPrefixLength; i <= last; i++) {
        tokens.add(word.substring(0, i));
      }
      if (tokens.length >= kMaxSearchTokens) break;
    }
  }
  return tokens.take(kMaxSearchTokens).toList();
}

/// Verifica se [text] contém o termo de busca [term] (client-side).
///
/// Diferente do servidor (palavra completa), aqui é usado `contains`,
/// permitindo digitação parcial ("poo" encontra "poodle").
bool containsTokens(String text, String term) {
  final normalizedText = normalizeText(text);
  final normalizedTerm = normalizeText(term);
  if (normalizedTerm.isEmpty) return true;
  return normalizedText.contains(normalizedTerm);
}

/// Divide o termo em palavras pesquisáveis (normalizadas, com 2+
/// caracteres). Palavras isoladas de 1 caractere são ignoradas, assim
/// como em [buildSearchTokens].
List<String> searchWords(String term) {
  return normalizeText(term)
      .split(RegExp(r'[^a-z0-9]+'))
      .where((word) => word.length >= 2)
      .toList();
}

/// Verifica se TODAS as palavras de [term] aparecem em [text]
/// (client-side), permitindo digitação parcial por palavra ("poo"
/// encontra "poodle"). Insensível a maiúsculas e acentos.
///
/// Com [term] vazio (ou contendo só palavras de 1 caractere),
/// retorna true.
bool containsAllSearchWords(String text, String term) {
  final words = searchWords(term);
  final normalizedText = normalizeText(text);
  return words.every(normalizedText.contains);
}
