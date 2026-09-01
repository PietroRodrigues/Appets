import 'package:appets/core/constants/constants_strings.dart';

/// Validações reutilizáveis de campos do formulário.
class AppValidators {
  AppValidators._();

  /// Remove tudo que não for dígito.
  static String _digitsOnly(String value) =>
      value.replaceAll(RegExp(r'[^0-9]'), '');

  /// Valida um celular brasileiro usado para WhatsApp.
  ///
  /// Regras:
  /// - Exatamente 11 dígitos (DDD com 2 + 9 dígitos do número).
  /// - DDD (2 primeiros dígitos) diferente de "00".
  /// - O dígito inicial do número local (3º dígito) deve ser "9".
  /// - Nem todos os dígitos iguais (ex.: 11111111111).
  ///
  /// Devolve `null` quando válido, ou uma mensagem de erro caso
  /// contrário.
  static String? validateCellPhone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return AppStrings.contactOwnerRequired;
    }

    final digits = _digitsOnly(v);
    if (digits.length != 11) {
      return AppStrings.ownerPhoneInvalid;
    }

    final ddd = digits.substring(0, 2);
    final areaCode = digits.substring(2, 3);

    // Todos os dígitos iguais não é um celular real.
    if (digits.split('').every((ch) => ch == digits[0])) {
      return AppStrings.ownerPhoneInvalid;
    }

    if (ddd == '00' || areaCode != '9') {
      return AppStrings.ownerPhoneInvalid;
    }

    return null;
  }
}
