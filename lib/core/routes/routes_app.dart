import 'package:appets/screens/auth/screen_forgot_password.dart';
import 'package:appets/screens/auth/screen_login.dart';
import 'package:appets/screens/auth/screen_register.dart';
import 'package:appets/screens/screen_about.dart';
import 'package:appets/screens/screen_account_data.dart';
import 'package:appets/screens/screen_home.dart';
import 'package:appets/screens/screen_settings.dart';
import 'package:appets/screens/screen_splash.dart';
import 'package:flutter/material.dart';

/// Rotas nomeadas do aplicativo.
///
/// Registro ÚNICO: as constantes e o mapa de rotas ficam juntos, de modo
/// que adicionar/renomear uma tela acontece em um só lugar. O widget raiz
/// ([MaterialApp]) apenas consome [routes].
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const settings = '/settings';
  static const accountData = '/account-data';
  static const about = '/about';

  /// Mapa de rotas usado pelo `MaterialApp`. Cobre todas as constantes
  /// declaradas acima.
  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        forgotPassword: (_) => const ForgotPasswordScreen(),
        home: (_) => const HomeScreen(),
        settings: (_) => const SettingsScreen(),
        accountData: (_) => const AccountDataScreen(),
        about: (_) => const AboutScreen(),
      };
}
