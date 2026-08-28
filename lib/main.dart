import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:appets/app.dart';

/// Ponto de entrada do app: inicializa o Firebase e executa o [App].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const App());
}
