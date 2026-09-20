import 'dart:async';

import 'package:appets/core/backfill/pet_tokens_backfill_initializer.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/buttons/widget_buttons.dart';
import 'package:appets/widgets/display/widget_logo.dart';
import 'package:appets/widgets/feedback/widget_loading.dart';
import 'package:flutter/material.dart';

/// Tela inicial que prepara o app e encaminha o usuário para o fluxo correto.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Indica que a preparação do app falhou e pede nova tentativa.
  bool _error = false;

  // Inicia a preparação do app ao montar a tela.
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // Prepara o app e encaminha para o fluxo (Home ou Login).
  Future<void> _initializeApp() async {
    // Reinicia o estado de erro em novas tentativas (via "Tentar de novo").
    if (mounted && _error) setState(() => _error = false);

    try {
      await Future.delayed(const Duration(seconds: 1));

      final authService = AuthService.instance;
      // Aguarda o primeiro evento do stream para capturar a sessão
      // restaurada no cold start, evitando mandar usuário logado
      // para o login (forçando reautenticação).
      final user = await authService.waitFirstAuthState();

      if (!mounted) return;

      // Inicia a migração de tokens em background (assíncrona e idempotente),
      // longe do primeiro frame da splash.
      PetTokensBackfillInitializer.instance.attach();

      if (user != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (_) {
      // Falha de auth (ex.: GMS instável) não deixa a splash presa:
      // mostra aviso com "Tentar de novo" que reinicia a preparação.
      if (mounted) setState(() => _error = true);
    }
  }

  // Constrói a área de aviso com nova tentativa quando a preparação falha.
  Widget _buildRetryArea() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          SharedStrings.APP_START_ERROR_TITLE,
          textAlign: TextAlign.center,
          style: ThemeTextStyles.heading.copyWith(color: ThemeColors.white),
        ),
        const SizedBox(height: 8),
        Text(
          SharedStrings.LOAD_DATA_ERROR_DESCRIPTION,
          textAlign: TextAlign.center,
          style: ThemeTextStyles.authBody,
        ),
        const SizedBox(height: 24),
        WGButton(
          text: SharedStrings.RETRY_ACTION,
          onPressed: _initializeApp,
          width: 240,
          backgroundColor: ThemeColors.white,
          foregroundColor: ThemeColors.secondary,
        ),
      ],
    );
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

                WGLogo(width: 240),

                const SizedBox(height: 24),

                Text(
                  SharedStrings.SLOGAN,
                  textAlign: TextAlign.center,
                  style: ThemeTextStyles.slogan,
                ),

                const Spacer(),

                _error ? _buildRetryArea() : const WGLoading(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
