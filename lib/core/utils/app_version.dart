import 'package:flutter/services.dart' show rootBundle;

/// Lê a versão do app a partir do pubspec.yaml (ex.: "1.0.0+1").
///
/// Evita divergência entre a versão exibida na tela "Sobre" e a
/// declarada no pubspec, eliminando o valor fixo hardcoded.
Future<String> readAppVersion() async {
  final pubspec = await rootBundle.loadString('pubspec.yaml');
  final line = pubspec.split('\n').firstWhere(
    (line) => line.trimLeft().startsWith('version:'),
    orElse: () => 'version: unknown',
  );
  return line.trim().replaceFirst('version: ', '');
}
