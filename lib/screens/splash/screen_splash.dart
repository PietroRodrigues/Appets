import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/routes/routes_app.dart';
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
  @override
  void initState() {
    super.initState();
    _initializeApp(); // Em desenvolvimento.
  }

  Future<void> _initializeApp() async { // Em desenvolvimento.
    // Simula a inicialização do app e redireciona para a próxima tela.
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // TODO:
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

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
