import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_auth.dart';
import 'package:appets/core/constants/constants_strings_publish.dart';
import 'package:appets/core/validators/validators.dart';

void main() {
  group('AppValidators.validateCellPhone', () {
    //115
    test('aceita celular válido com 11 dígitos e máscara', () {
      expect(AppValidators.validateCellPhone('(11) 98765-4321'), isNull);
    });

    //116
    test('aceita celular válido sem máscara', () {
      expect(AppValidators.validateCellPhone('11987654321'), isNull);
    });

    //117
    test('rejeita vazio', () {
      expect(AppValidators.validateCellPhone(''), isNotNull);
      expect(AppValidators.validateCellPhone(null), isNotNull);
    });

    //118
    test('rejeita fixo (10 dígitos)', () {
      expect(AppValidators.validateCellPhone('(11) 8765-4321'), isNotNull);
    });

    //119
    test('rejeita 12 dígitos', () {
      expect(AppValidators.validateCellPhone('(11) 98765-43210'), isNotNull);
    });

    //120
    test('rejeita número que não começa com 9', () {
      expect(AppValidators.validateCellPhone('(11) 28765-4321'), isNotNull);
    });

    //121
    test('rejeita DDD 00', () {
      expect(AppValidators.validateCellPhone('(00) 98765-4321'), isNotNull);
    });

    //122
    test('rejeita todos os dígitos iguais', () {
      expect(AppValidators.validateCellPhone('(11) 11111-1111'), isNotNull);
    });
  });

  group('AppValidators.validatePetName', () {
    //123
    test('aceita nome com 2 ou mais caracteres', () {
      expect(AppValidators.validatePetName('Rex'), isNull);
      expect(AppValidators.validatePetName('  Bo  '), isNull);
    });

    //124
    test('rejeita vazio, nulo ou com menos de 2 caracteres', () {
      expect(
        AppValidators.validatePetName(''),
        PublishStrings.PET_NAME_REQUIRED,
      );
      expect(
        AppValidators.validatePetName(null),
        PublishStrings.PET_NAME_REQUIRED,
      );
      expect(
        AppValidators.validatePetName(' A '),
        PublishStrings.PET_NAME_REQUIRED,
      );
    });
  });

  group('AppValidators.validateAddress', () {
    //125
    test('aceita endereço preenchido', () {
      expect(AppValidators.validateAddress('Rua das Flores, 123'), isNull);
    });

    //126
    test('rejeita vazio, nulo ou só espaços', () {
      expect(
        AppValidators.validateAddress('   '),
        PublishStrings.ADDRESS_REQUIRED,
      );
      expect(
        AppValidators.validateAddress(null),
        PublishStrings.ADDRESS_REQUIRED,
      );
    });
  });

  group('AppValidators.parseWeight', () {
    //127
    test('aceita ponto e vírgula como separador decimal', () {
      expect(AppValidators.parseWeight('12.5'), 12.5);
      expect(AppValidators.parseWeight('12,5'), 12.5);
    });

    //128
    test('vazio ou inválido vira null', () {
      expect(AppValidators.parseWeight(''), isNull);
      expect(AppValidators.parseWeight('abc'), isNull);
    });
  });

  group('AppValidators.validateWeight', () {
    //129
    test('vazio passa (opcional)', () {
      expect(AppValidators.validateWeight(''), isNull);
      expect(AppValidators.validateWeight(null), isNull);
    });

    //130
    test('aceita valor na faixa 0 < x ≤ 200', () {
      expect(AppValidators.validateWeight('12,5'), isNull);
      expect(AppValidators.validateWeight('200'), isNull);
    });

    //131
    test('rejeita zero, negativo, acima do teto e não numérico', () {
      expect(
        AppValidators.validateWeight('0'),
        PublishStrings.WEIGHT_INVALID,
      );
      expect(
        AppValidators.validateWeight('-1'),
        PublishStrings.WEIGHT_INVALID,
      );
      expect(
        AppValidators.validateWeight('201'),
        PublishStrings.WEIGHT_INVALID,
      );
      expect(
        AppValidators.validateWeight('abc'),
        PublishStrings.WEIGHT_INVALID,
      );
    });
  });

  group('AppValidators.validatePetAge', () {
    //132
    test('aceita idade informada', () {
      expect(AppValidators.validatePetAge(1), isNull);
    });

    //133
    test('rejeita idade nula', () {
      expect(
        AppValidators.validatePetAge(null),
        PublishStrings.AGE_REQUIRED,
      );
    });
  });

  group('AppValidators.validatePassword', () {
    //134
    test('aceita senha com 6 ou mais caracteres', () {
      expect(AppValidators.validatePassword('123456'), isNull);
    });

    //135
    test('rejeita vazio e curta', () {
      expect(
        AppValidators.validatePassword(''),
        AuthStrings.PASSWORD_REQUIRED,
      );
      expect(
        AppValidators.validatePassword('12345'),
        AuthStrings.PASSWORD_MIN_LENGTH,
      );
    });
  });

  group('AppValidators.validatePasswordConfirmation', () {
    //136
    test('aceita quando coincide com a original', () {
      expect(
        AppValidators.validatePasswordConfirmation('123456', '123456'),
        isNull,
      );
    });

    //137
    test('vazio reporta senha obrigatória', () {
      expect(
        AppValidators.validatePasswordConfirmation('', '123456'),
        AuthStrings.PASSWORD_REQUIRED,
      );
    });

    //138
    test('diferente reporta divergência', () {
      expect(
        AppValidators.validatePasswordConfirmation('654321', '123456'),
        AuthStrings.PASSWORD_MISMATCH,
      );
    });
  });
}
