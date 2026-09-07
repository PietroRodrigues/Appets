import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:appets/app.dart';
import 'package:appets/core/backfill/pet_tokens_backfill_initializer.dart';

/// Ponto de entrada do app: inicializa o Firebase e executa o [App].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const App());
  PetTokensBackfillInitializer.instance.attach();
}
