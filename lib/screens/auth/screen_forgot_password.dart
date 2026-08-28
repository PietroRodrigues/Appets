import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/extensions/extension_auth_error.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/auth/widget_auth_page_layout.dart';
import 'package:appets/widgets/auth/widget_auth_header.dart';
import 'package:appets/widgets/common/buttons/widget_button.dart';
import 'package:appets/widgets/common/buttons/widget_outlined_button.dart';
import 'package:appets/widgets/common/feedback/widget_snack_bar.dart';
import 'package:appets/widgets/common/fields/widget_text_field.dart';

/// Tela para solicitar recuperação de senha pelo e-mail cadastrado.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Controla a validação do formulário de recuperação.
  final _formKey = GlobalKey<FormState>();

  // Armazena o e-mail informado pelo usuário.
  final _emailController = TextEditingController();

  // Libera o controlador ao sair da tela.
  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
  }

  /// Volta para a tela anterior (login).
  void _goBack() {
    Navigator.pop(context);
  }

  /// Envia o link de recuperação de senha para o e-mail informado.
  void _sendRecoveryEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final authService = AuthService();
      await authService.sendPasswordResetEmail(
        _emailController.text.trim(),
      );
      if (!mounted) return;
      AppSnackBar.show(context, AppStrings.recoverLinkSent);
      Navigator.pop(context);
    } on Exception catch (e) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        e.authMessage(AppStrings.recoverError, {
          'user-not-found': AppStrings.emailNotRegistered,
          'invalid-email': AppStrings.invalidEmail,
        }),
      );
    }
  }

  // Constrói a tela de recuperação de senha.
  @override
  Widget build(BuildContext context) {
    return AppAuthPageLayout(
      formKey: _formKey,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // Cabeçalho da tela
          const AppAuthHeader(
            logoWidth: 250,
            headline: AppStrings.recoverTitle,
            description: '',
            textColor: ThemeColors.white,
          ),

          const SizedBox(height: 28),

          // Texto informativo
          Text(
            AppStrings.recoverDescription,
            textAlign: TextAlign.center,
            style: ThemeTextStyles.authBody,
          ),

          const SizedBox(height: 32),

          // Campo de E-mail
          AppTextField(
            controller: _emailController,
            label: AppStrings.email,
            labelStyle: ThemeTextStyles.authBody,
            hintText: AppStrings.emailHint,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.email_outlined,
          ),

          const SizedBox(height: 20),

          // Botão Enviar
          AppButton(
            text: AppStrings.recoverButton,
            onPressed: _sendRecoveryEmail,
            backgroundColor: ThemeColors.white,
            foregroundColor: ThemeColors.secondary,
            borderColor: ThemeColors.secondary,
          ),

          const SizedBox(height: 16),

          // Botão Voltar
          AppOutlinedButton(
            text: AppStrings.backToLogin,
            onPressed: _goBack,
            textColor: ThemeColors.white,
            borderColor: ThemeColors.white,
          ),
        ],
      ),
    );
  }
}
