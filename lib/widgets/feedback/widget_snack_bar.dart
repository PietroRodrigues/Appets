import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:flutter/material.dart';

/// Helpers para exibir mensagens [SnackBar] de forma padronizada.
abstract final class WGSnackBar {
  WGSnackBar._();

  /// Exibe uma [SnackBar] com a [message] informada.
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Exibe um aviso de recurso "em desenvolvimento".
  static void development(BuildContext context, String feature) {
    show(context, SharedStrings.featureInDevelopment(feature));
  }
}
