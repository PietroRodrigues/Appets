import 'package:flutter/material.dart';


import 'package:appets/core/routes/app_routes.dart';
import 'package:appets/screens/auth/login_screen.dart';
import 'package:appets/screens/auth/register_screen.dart';
import 'package:appets/screens/auth/forgot_password_screen.dart';
import 'package:appets/screens/splash/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: AppRoutes.splash,

      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(), 
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
      },
    );
  }
}