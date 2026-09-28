import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appets/app.dart';
import 'package:appets/core/services/connectivity_service.dart';

/// Registra exceções de Dart em um arquivo local para diagnóstico
/// (ex.: fechamento do app ao voltar do detalhe do pet).
void _registerErrorLog() {
  final file = File(
    '${Directory.systemTemp.path}${Platform.pathSeparator}appets_crash.log',
  );

  void append(Object error, StackTrace stackTrace) {
    try {
      file.writeAsStringSync(
        '${DateTime.now().toIso8601String()}\n$error\n$stackTrace\n'
        '---\n',
        mode: FileMode.append,
      );
    } catch (_) {
      // Nunca deixa o log quebrar o app.
    }
  }

  FlutterError.onError = (details) {
    append(details.exception, details.stack ?? StackTrace.current);
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    append(error, stack);
    return true;
  };
}

/// Ponto de entrada do app: inicializa o Firebase e executa o [App].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerErrorLog();
  await Firebase.initializeApp();
  // Garante o cache local (foi adotado o recurso cache-first no feed).
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);
  ConnectivityService.instance.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Barras do sistema escuras: mantém ícones claros para contraste.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
    ),
  );
  runApp(const App());
}
