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

  /// Valida o nome do pet: pelo menos 2 caracteres (após `trim`).
  static String? validatePetName(String? value) {
    if ((value?.trim().length ?? 0) < 2) {
      return PublishStrings.PET_NAME_REQUIRED;
    }
    return null;
  }

  /// Valida o endereço: obrigatório (não vazio após `trim`).
  static String? validateAddress(String? value) {
    if (value?.trim().isEmpty ?? true) {
      return PublishStrings.ADDRESS_REQUIRED;
    }
    return null;
  }

  /// Converte o texto do campo de peso em `double`, aceitando vírgula ou
  /// ponto como separador decimal. Texto vazio ou inválido vira `null`.
  static double? parseWeight(String input) {
    final cleaned = input.trim().replaceAll(',', '.');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  /// Valida o peso opcional: vazio passa; presente precisa ser `0 < x ≤ 200`.
  static String? validateWeight(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final weight = parseWeight(text);
    if (weight == null || weight <= 0 || weight > 200) {
      return PublishStrings.WEIGHT_INVALID;
    }
    return null;
  }

  /// Valida a idade do pet: obrigatória.
  static String? validatePetAge(int? value) {
    if (value == null) return PublishStrings.AGE_REQUIRED;
    return null;
  }

  /// Valida a senha: obrigatória e com no mínimo 6 caracteres.
  static String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return AuthStrings.PASSWORD_REQUIRED;
    }
    if (password.length < 6) {
      return AuthStrings.PASSWORD_MIN_LENGTH;
    }
    return null;
  }

  /// Valida a confirmação de senha contra [original].
  ///
  /// Vazio → `PASSWORD_REQUIRED`; diferente de [original] →
  /// `PASSWORD_MISMATCH`.
  static String? validatePasswordConfirmation(
    String? value,
    String? original,
  ) {
    final confirmation = value ?? '';
    if (confirmation.isEmpty) {
      return AuthStrings.PASSWORD_REQUIRED;
    }
    if (confirmation != original) {
      return AuthStrings.PASSWORD_MISMATCH;
    }
    return null;
  }
}
