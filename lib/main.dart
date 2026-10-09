import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appets/app.dart';
import 'package:appets/core/services/connectivity_service.dart';

/// Ponto de entrada do app: inicializa o Firebase e executa o [App].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
