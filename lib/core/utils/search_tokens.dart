/// Utilitários para a busca de pets.
///
/// Todos os textos são normalizados (minúsculas e sem acentos)
/// para que "Rex", "REX" e "rex" encontrem o mesmo pet.
library;

/// Mapeamento ruine (código) → letra sem acento, usado por [normalizeText].
///
/// Índice por ruine para um único lookup O(1) por caractere em 1 passada,
/// sem percorrer a string 24x (um replaceAll por letra acentuada).
const Map<int, String> _accentByRune = {
  0x00E1: 'a', // á
  0x00E0: 'a', // à
  0x00E2: 'a', // â
  0x00E3: 'a', // ã
  0x00E4: 'a', // ä
  0x00E9: 'e', // é
  0x00E8: 'e', // è
  0x00EA: 'e', // ê
  0x00EB: 'e', // ë
  0x00ED: 'i', // í
  0x00EC: 'i', // ì
  0x00EE: 'i', // î
  0x00EF: 'i', // ï
  0x00F3: 'o', // ó
  0x00F2: 'o', // ò
  0x00F4: 'o', // ô
  0x00F5: 'o', // õ
  0x00F6: 'o', // ö
  0x00FA: 'u', // ú
  0x00F9: 'u', // ù
  0x00FB: 'u', // û
  0x00FC: 'u', // ü
  0x00E7: 'c', // ç
  0x00F1: 'n', // ñ
};

/// Remove acentos e converte para minúsculas em uma única passada.
String normalizeText(String input) {
  final text = input.toLowerCase().trim();
  if (text.isEmpty) return text;
  final buffer = StringBuffer();
  for (final rune in text.runes) {
    buffer.write(_accentByRune[rune] ?? String.fromCharCode(rune));
  }
  return buffer.toString();
}

/// Quantidade máxima de tokens de busca persistidos por pet.
const int kMaxSearchTokens = 150;

/// Limite superior do comprimento de prefixo persistido por palavra.
const int kMaxSearchPrefixLength = 12;

/// Menor comprimento de prefixo persistido por palavra ("poo" já cobre,
/// por exemplo, "poodle", "poodlepreto"...).
const int kMinSearchPrefixLength = 3;

/// Número máximo de palavras distintas consideradas por consulta de busca.
///
/// O Firestore aceita no máximo 10 valores em `arrayContainsAny`, então
/// consultas com mais palavras são truncadas para não falharem em silêncio.
const int kMaxSearchWordsPerQuery = 10;

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
  return normalizeText(
    term,
  ).split(RegExp(r'[^a-z0-9]+')).where((word) => word.length >= 2).toList();
}

/// Palavras efetivas de uma consulta de busca: normaliza, remove as
/// duplicadas e mantém apenas as [kMaxSearchWordsPerQuery] primeiras, na
/// ordem digitada.
///
/// É a fonte única do limite de 10 palavras (servidor e cliente), para que
/// a consulta ao Firestore nunca estoure e o resultado exibido seja
/// coerente com a mensagem de aviso ao usuário.
List<String> searchQueryWords(String term) {
  final words = <String>{};
  for (final word in searchWords(term)) {
    words.add(word);
    if (words.length >= kMaxSearchWordsPerQuery) break;
  }
  return words.toList();
}

/// Indica se [term] tem mais palavras distintas do que o limite
/// [kMaxSearchWordsPerQuery] (usado para avisar o usuário).
bool searchWordsExceedLimit(String term) =>
    searchWords(term).toSet().length > kMaxSearchWordsPerQuery;

/// Verifica se TODAS as palavras de [term] aparecem em [text]
/// (client-side), permitindo digitação parcial por palavra ("poo"
/// encontra "poodle"). Insensível a maiúsculas e acentos.
///
/// Considera apenas as [kMaxSearchWordsPerQuery] primeiras palavras
/// distintas (ver [searchQueryWords]), alinhado à consulta do servidor.
///
/// Com [term] vazio (ou contendo só palavras de 1 caractere),
/// retorna true.
bool containsAllSearchWords(String text, String term) {
  final words = searchQueryWords(term);
  final normalizedText = normalizeText(text);
  return words.every(normalizedText.contains);
}
