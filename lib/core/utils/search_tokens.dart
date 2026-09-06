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

/// Gera a lista de palavras pesquisáveis a partir do nome e da
/// descrição ("Sobre o pet") do pet.
///
/// Normaliza, divide em palavras, ignora palavras com menos de 2
/// caracteres, remove duplicados e limita a quantidade de tokens.
List<String> buildSearchTokens({required String name, String? description}) {
  final buffer = <String>[name, ?description];
  final tokens = <String>{};
  for (final part in buffer) {
    final words = normalizeText(part).split(RegExp(r'[^a-z0-9]+'));
    for (final word in words) {
      if (word.length < 2) continue;
      tokens.add(word);
    }
  }
  return tokens.take(30).toList();
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
