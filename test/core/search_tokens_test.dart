import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/utils/search_tokens.dart';

void main() {
  group('normalizeText', () {
    test('converte para minúsculas', () {
      expect(normalizeText('REX'), 'rex');
      expect(normalizeText('Rex'), 'rex');
      expect(normalizeText('rex'), 'rex');
    });

    test('remove acentos', () {
      expect(normalizeText('Dócil'), 'docil');
      expect(normalizeText('Coração'), 'coracao');
      expect(normalizeText('Ção'), 'cao');
    });

    test('remove espaços nas bordas', () {
      expect(normalizeText('  Rex  '), 'rex');
    });
  });

  group('buildSearchTokens', () {
    test('inclui nome e palavras da descrição', () {
      final tokens = buildSearchTokens(
        name: 'Rex',
        description: 'Cachorro dócil e carinhoso',
      );

      expect(tokens.length, 4);
      expect(tokens, contains('rex'));
      expect(tokens, contains('cachorro'));
      expect(tokens, contains('docil'));
      expect(tokens, contains('carinhoso'));
    });

    test('ignora palavras com menos de 2 caracteres', () {
      final tokens = buildSearchTokens(name: 'A', description: 'e');

      expect(tokens, isEmpty);
    });

    test('remove tokens duplicados', () {
      final tokens = buildSearchTokens(name: 'Rex', description: 'REX');

      final occurrences = tokens.where((t) => t == 'rex').length;
      expect(occurrences, 1);
    });

    test('não gera tokens de descrição quando ela é nula', () {
      final tokens = buildSearchTokens(name: 'Rex');

      expect(tokens, ['rex']);
    });

    test('não gera tokens com raça ou espécie', () {
      final tokens = buildSearchTokens(
        name: 'Rex',
        description: 'Cachorro dócil',
      );

      expect(tokens, isNot(contains('poodle')));
      expect(tokens, isNot(contains('gato')));
    });

    test('limita a quantidade de tokens', () {
      final description = List.generate(50, (i) => 'palavra$i').join(' ');
      final tokens = buildSearchTokens(name: 'Rex', description: description);

      expect(tokens.length, lessThanOrEqualTo(30));
    });
  });

  group('containsTokens', () {
    test('encontra termo no meio da frase (parcial)', () {
      expect(containsTokens('Poodle dócil', 'poo'), isTrue);
      expect(containsTokens('Poodle dócil', 'oodle'), isTrue);
    });

    test('é insensível a maiúsculas e acentos', () {
      expect(containsTokens('Poodle', 'POODLE'), isTrue);
      expect(containsTokens('Dócil', 'docil'), isTrue);
    });

    test('retorna true para termo vazio', () {
      expect(containsTokens('Rex', ''), isTrue);
    });

    test('retorna false quando não encontra', () {
      expect(containsTokens('Rex', 'gato'), isFalse);
    });
  });
}
