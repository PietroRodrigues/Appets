import 'package:flutter/material.dart';

import 'package:appets/widgets/branding/app_auth_header.dart';
import 'package:appets/widgets/buttons/app_button.dart';
import 'package:appets/widgets/buttons/app_outlined_button.dart';
import 'package:appets/widgets/form/app_text_field.dart';
import 'package:appets/widgets/layout/auth_page_layout.dart';
import 'package:appets/core/theme/app_text_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  //══════════════════════════════════════════════════════════════
  // FORM KEY
  //
  // Controla todo o formulário.
  // Futuramente será utilizado para validar o e-mail antes
  // de solicitar a recuperação da senha.
  //══════════════════════════════════════════════════════════════

  final _formKey = GlobalKey<FormState>();


  //══════════════════════════════════════════════════════════════
  // CONTROLLERS
  //
  // Armazena o e-mail digitado pelo usuário.
  //══════════════════════════════════════════════════════════════

  final _emailController = TextEditingController();


  //══════════════════════════════════════════════════════════════
  // STATE
  //
  // Esta tela não possui estados visuais no momento.
  //══════════════════════════════════════════════════════════════


  //══════════════════════════════════════════════════════════════
  // LIFECYCLE
  //
  // Libera os recursos utilizados pelos Controllers.
  //══════════════════════════════════════════════════════════════

  @override
  void dispose() {

    _emailController.dispose();

    super.dispose();

  }


  //══════════════════════════════════════════════════════════════
  // NAVIGATION
  //
  // Métodos responsáveis apenas pela navegação.
  //══════════════════════════════════════════════════════════════

  void _goBack() {

    Navigator.pop(context);

  }


  //══════════════════════════════════════════════════════════════
  // ACTIONS
  //
  // Responsável por enviar o e-mail de recuperação.
  // Futuramente será integrado ao Firebase Authentication.
  //══════════════════════════════════════════════════════════════

  void _sendRecoveryEmail() {

    // TODO:
    // FirebaseAuth.instance.sendPasswordResetEmail()

  }


  //══════════════════════════════════════════════════════════════
  // UI
  //
  // Toda a interface gráfica da tela.
  //══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {

    return AuthPageLayout(
     
      formKey: _formKey,
      
      child: Column(
        
        children: [

          const SizedBox(height: 24),

          //----------------------------------------------------------
          // Cabeçalho
          //----------------------------------------------------------

          const AppAuthHeader(
            headline: 'Recuperar Senha',
          ),

          const SizedBox(height: 24),

          //----------------------------------------------------------
          // Texto informativo
          //----------------------------------------------------------

          Text(
            'Informe o e-mail cadastrado para receber um link de recuperação da senha.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),

          const SizedBox(height: 40),

          //----------------------------------------------------------
          // Campo de E-mail
          //----------------------------------------------------------

          AppTextField(
            controller: _emailController,
            label: 'E-mail',
            hintText: 'Digite seu e-mail',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.email_outlined,
          ),

          const SizedBox(height: 32),

          //----------------------------------------------------------
          // Botão Enviar
          //----------------------------------------------------------

          AppButton(
            text: 'Enviar Link',
            onPressed: _sendRecoveryEmail,
          ),

          const SizedBox(height: 16),

          //----------------------------------------------------------
          // Botão Voltar
          //----------------------------------------------------------

          AppOutlinedButton(
            text: 'Voltar ao Login',
            onPressed: _goBack,
          ),

          const Spacer(),

        ],

      ),
    );

  }

}