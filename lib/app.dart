import 'package:flutter/material.dart';

import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/theme/theme_app.dart';
import 'package:appets/screens/auth/screen_login.dart';
import 'package:appets/screens/auth/screen_register.dart';
import 'package:appets/screens/auth/screen_forgot_password.dart';
import 'package:appets/screens/splash/screen_splash.dart';
import 'package:appets/screens/main/screen_home.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      initialRoute: AppRoutes.splash,

      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
      },
    );
  }
}
