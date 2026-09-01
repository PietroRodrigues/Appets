import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/validators/validators.dart';

void main() {
  group('AppValidators.validateCellPhone', () {
    test('aceita celular válido com 11 dígitos e máscara', () {
      expect(AppValidators.validateCellPhone('(11) 98765-4321'), isNull);
    });

    test('aceita celular válido sem máscara', () {
      expect(AppValidators.validateCellPhone('11987654321'), isNull);
    });

    test('rejeita vazio', () {
      expect(AppValidators.validateCellPhone(''), isNotNull);
      expect(AppValidators.validateCellPhone(null), isNotNull);
    });

    test('rejeita fixo (10 dígitos)', () {
      expect(AppValidators.validateCellPhone('(11) 8765-4321'), isNotNull);
    });

    test('rejeita 12 dígitos', () {
      expect(AppValidators.validateCellPhone('(11) 98765-43210'), isNotNull);
    });

    test('rejeita número que não começa com 9', () {
      expect(AppValidators.validateCellPhone('(11) 28765-4321'), isNotNull);
    });

    test('rejeita DDD 00', () {
      expect(AppValidators.validateCellPhone('(00) 98765-4321'), isNotNull);
    });

    test('rejeita todos os dígitos iguais', () {
      expect(AppValidators.validateCellPhone('(11) 11111-1111'), isNotNull);
    });
  });
}
