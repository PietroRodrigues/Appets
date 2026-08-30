import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/branding/widget_logo.dart';
import 'package:appets/widgets/common/feedback/widget_loading.dart';

/// Tela inicial que prepara o app e encaminha o usuário para o fluxo correto.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Inicia a preparação do app ao montar a tela.
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // Aguarda um momento e encaminha para o fluxo (Home ou Login).
  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));

    final authService = AuthService();
    // Aguarda o primeiro evento do stream para capturar a sessão
    // restaurada no cold start, evitando mandar usuário logado
    // para o login (forçando reautenticação).
    final user = await authService.authStateChanges.first;

    if (!mounted) return;

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // Constrói a tela de abertura com logo, slogan e carregamento.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                AppLogo(width: 240),

                const SizedBox(height: 24),

                Text(
                  AppStrings.slogan,
                  textAlign: TextAlign.center,
                  style: ThemeTextStyles.slogan,
                ),

                const Spacer(),

                const AppLoading(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
