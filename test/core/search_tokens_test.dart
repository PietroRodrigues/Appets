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
    test('inclui nome, descrição e prefixos a partir de 3 letras', () {
      final tokens = buildSearchTokens(
        name: 'Rex',
        description: 'Cachorro dócil e carinhoso',
      );

      expect(tokens.length, 17);
      expect(tokens, contains('rex'));
      expect(tokens, contains('cachorro'));
      expect(tokens, contains('docil'));
      expect(tokens, contains('carinhoso'));
      expect(tokens, contains('doc'));
      expect(tokens, contains('car'));
    });

    test('gera token de prefixo para buscar digitação parcial', () {
      final tokens = buildSearchTokens(name: 'Poodle');

      expect(tokens, contains('poo'));
      expect(tokens, contains('pood'));
      expect(tokens, contains('poodle'));
    });

    test('não gera prefixo para palavras com menos de 3 letras', () {
      final tokens = buildSearchTokens(name: 'Bo');

      expect(tokens, ['bo']);
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
      final description = List.generate(200, (i) => 'palavra${i.toRadixString(36)}')
          .join(' ');
      final tokens = buildSearchTokens(name: 'Rex', description: description);

      expect(tokens.length, kMaxSearchTokens);
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

  group('searchWords', () {
    test('divide o termo em palavras normalizadas', () {
      expect(searchWords('  Poodle Preto  '), ['poodle', 'preto']);
    });

    test('ignora palavras com menos de 2 caracteres', () {
      expect(searchWords('a e o'), isEmpty);
      expect(searchWords('Rex a'), ['rex']);
    });
  });

  group('containsAllSearchWords', () {
    test('exige todas as palavras do termo', () {
      expect(containsAllSearchWords('Poodle preto', 'poodle preto'), isTrue);
      expect(containsAllSearchWords('Poodle', 'poodle preto'), isFalse);
      expect(containsAllSearchWords('preto', 'poodle preto'), isFalse);
    });

    test('palavras em qualquer ordem', () {
      expect(containsAllSearchWords('preto poodle', 'poodle preto'), isTrue);
    });

    test('permite digitação parcial por palavra', () {
      expect(containsAllSearchWords('Poodle dócil', 'poo doci'), isTrue);
    });

    test('é insensível a maiúsculas e acentos', () {
      expect(containsAllSearchWords('Dócil', 'docil'), isTrue);
      expect(containsAllSearchWords('Poodle', 'POODLE'), isTrue);
    });

    test('retorna true para termo vazio ou sem palavras', () {
      expect(containsAllSearchWords('Rex', ''), isTrue);
      expect(containsAllSearchWords('Rex', 'a e'), isTrue);
    });

    test('retorna false quando falta qualquer palavra', () {
      expect(containsAllSearchWords('Rex', 'rex gato'), isFalse);
    });
  });
}
