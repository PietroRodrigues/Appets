import 'package:appets/core/constants/constants_strings_auth.dart';
import 'package:appets/core/constants/constants_strings_publish.dart';

/// Validações reutilizáveis de campos do formulário.
class AppValidators {
  AppValidators._();

  /// Remove tudo que não for dígito.
  static String _digitsOnly(String value) =>
      value.replaceAll(RegExp(r'[^0-9]'), '');

  /// Valida um e-mail simples: `algo@algo.algo`.
  ///
  /// Devolve `null` quando válido, ou uma mensagem de erro caso
  /// contrário.
  static String? validateEmail(String? value) {
    final v = value?.trim() ?? '';

    if (v.isEmpty) {
      return AuthStrings.EMAIL_REQUIRED;
    }

    if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(v)) {
      return AuthStrings.EMAIL_INVALID;
    }

    return null;
  }

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
      return PublishStrings.CONTACT_OWNER_REQUIRED;
    }

    final digits = _digitsOnly(v);
    if (digits.length != 11) {
      return PublishStrings.OWNER_PHONE_INVALID;
    }

    final ddd = digits.substring(0, 2);
    final areaCode = digits.substring(2, 3);

    // Todos os dígitos iguais não é um celular real.
    if (digits.split('').every((ch) => ch == digits[0])) {
      return PublishStrings.OWNER_PHONE_INVALID;
    }

    if (ddd == '00' || areaCode != '9') {
      return PublishStrings.OWNER_PHONE_INVALID;
    }

    return null;
  }
}
