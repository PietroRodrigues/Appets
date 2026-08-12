import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/auth/widget_auth_header.dart';
import 'package:appets/widgets/common/widget_button.dart';
import 'package:appets/widgets/common/widget_outlined_button.dart';
import 'package:appets/widgets/common/widget_text_field.dart';
import 'package:appets/widgets/auth/widget_auth_page_layout.dart';

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

  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
  }

  void _goBack() {
    Navigator.pop(context);
  }

  void _sendRecoveryEmail() { // Em desenvolvimento.
    // TODO:
    // FirebaseAuth.instance.sendPasswordResetEmail()
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageLayout(
      formKey: _formKey,
      scrollPhysics: const NeverScrollableScrollPhysics(),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          //----------------------------------------------------------
          // Cabeçalho da tela
          //----------------------------------------------------------
          const AppAuthHeader(
            logoWidth: 250,
            headline: 'Recuperar Senha',
            description: '',
            textColor: AppColors.white,
          ),

          const SizedBox(height: 28),

          //----------------------------------------------------------
          // Texto informativo
          //----------------------------------------------------------
          Text(
            'Informe o e-mail cadastrado para receber um link de recuperação da senha.',
            textAlign: TextAlign.center,
            style: AppTextStyles.authBody,
          ),

          const SizedBox(height: 32),

          //----------------------------------------------------------
          // Campo de E-mail
          //----------------------------------------------------------
          AppTextField(
            controller: _emailController,
            label: 'E-mail',
            labelStyle: AppTextStyles.authBody,
            hintText: 'Digite seu e-mail',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.email_outlined,
          ),

          const SizedBox(height: 20),

          //----------------------------------------------------------
          // Botão Enviar
          //----------------------------------------------------------
          AppButton(
            text: 'Enviar Link',
            onPressed: _sendRecoveryEmail, // Em desenvolvimento.
            backgroundColor: AppColors.info,
            foregroundColor: AppColors.white,
          ),

          const SizedBox(height: 16),

          //----------------------------------------------------------
          // Botão Voltar
          //----------------------------------------------------------
          AppOutlinedButton(
            text: 'Voltar ao Login',
            onPressed: _goBack,
            textColor: AppColors.white,
            borderColor: AppColors.white,
          ),
        ],
      ),
    );
  }
}
