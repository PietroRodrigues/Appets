import 'package:flutter/material.dart';

import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/auth/widget_auth_header.dart';
import 'package:appets/widgets/common/widget_button.dart';
import 'package:appets/widgets/common/widget_outlined_button.dart';
import 'package:appets/widgets/common/widget_text_field.dart';
import 'package:appets/widgets/auth/widget_auth_page_layout.dart';

/// Tela de autenticação para acesso do usuário ao app.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controla a validação do formulário de login.
  final _formKey = GlobalKey<FormState>();

  // Armazena os dados digitados pelo usuário.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Alterna a visibilidade da senha na interface.
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();

    _passwordController.dispose();

    super.dispose();
  }

  void _goToRegister() {
    Navigator.pushNamed(context, AppRoutes.register);
  }

  void _goToForgotPassword() {
    Navigator.pushNamed(context, AppRoutes.forgotPassword);
  }

  void _login() { // Em desenvolvimento.
    // Temporariamente, o login redireciona direto para a home.
    Navigator.pushReplacementNamed(context, AppRoutes.home);

    // TODO: integrar autenticação real no futuro.
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
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
            headline: 'Bem-vindo de volta',
            description: '',
            textColor: AppColors.white,
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
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.email_outlined,
          ),

          const SizedBox(height: 14),

          //----------------------------------------------------------
          // Campo de Senha
          //----------------------------------------------------------
          AppTextField(
            controller: _passwordController,
            label: 'Senha',
            labelStyle: AppTextStyles.authBody,
            hintText: 'Digite sua senha',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              onPressed: _togglePasswordVisibility,
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),

          const SizedBox(height: 14),

          //----------------------------------------------------------
          // Recuperação de senha
          //----------------------------------------------------------
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _goToForgotPassword,
              child: Text(
                'Esqueci minha senha',
                style: AppTextStyles.body.copyWith(color: AppColors.white),
              ),
            ),
          ),

          const SizedBox(height: 24),

          //----------------------------------------------------------
          // Botão Entrar
          //----------------------------------------------------------
          AppButton(
            text: 'Entrar',
            onPressed: _login, // Em desenvolvimento.
            backgroundColor: AppColors.info,
            foregroundColor: AppColors.white,
          ),

          const SizedBox(height: 16),

          //----------------------------------------------------------
          // Botão Criar Conta
          //----------------------------------------------------------
          AppOutlinedButton(
            text: 'Criar Conta',
            onPressed: _goToRegister,
            borderColor: AppColors.white,
            textColor: AppColors.white,
          ),
        ],
      ),
    );
  }
}
