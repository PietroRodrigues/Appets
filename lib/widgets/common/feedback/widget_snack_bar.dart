import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';

/// Helpers para exibir mensagens [SnackBar] de forma padronizada.
abstract final class AppSnackBar {
  AppSnackBar._();

  /// Exibe uma [SnackBar] com a [message] informada.
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Exibe um aviso de recurso "em desenvolvimento".
  static void development(BuildContext context, String feature) {
    show(context, AppStrings.featureInDevelopment(feature));
  }
}
