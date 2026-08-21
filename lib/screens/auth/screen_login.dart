import 'package:flutter/material.dart';

import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/auth/widget_auth_header.dart';
import 'package:appets/widgets/auth/widget_password_field.dart';
import 'package:appets/widgets/common/buttons/widget_button.dart';
import 'package:appets/widgets/common/buttons/widget_outlined_button.dart';
import 'package:appets/widgets/common/fields/widget_text_field.dart';
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

  // Controla a navegação de foco entre os campos pelo teclado.
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  // Estilo do texto de erro legível sobre o fundo laranja.
  static const _loginErrorStyle = TextStyle(
    color: Color(0xFF5D1212),
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  @override
  void dispose() {
    _emailController.dispose();

    _passwordController.dispose();

    _emailFocusNode.dispose();

    _passwordFocusNode.dispose();

    super.dispose();
  }

  void _goToRegister() {
    Navigator.pushNamed(context, AppRoutes.register);
  }

  void _goToForgotPassword() {
    Navigator.pushNamed(context, AppRoutes.forgotPassword);
  }

  void _login() { // Em desenvolvimento.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Temporariamente, o login redireciona direto para a home.
    Navigator.pushReplacementNamed(context, AppRoutes.home);

    // TODO: integrar autenticação real no futuro.
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageLayout(
      formKey: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // Cabeçalho da tela
          const AppAuthHeader(
            logoWidth: 250,
            headline: 'Bem-vindo de volta',
            description: '',
            textColor: ThemeColors.white,
          ),

          const SizedBox(height: 32),

          // Campo de E-mail
          AppTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            label: 'E-mail',
            labelStyle: ThemeTextStyles.authBody,
            hintText: 'Digite seu e-mail',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.email_outlined,
            errorStyle: _loginErrorStyle,
            onFieldSubmitted: (_) {
              _passwordFocusNode.requestFocus();
            },
            validator: (value) {
              final email = value?.trim() ?? '';

              if (email.isEmpty) {
                return 'Informe seu e-mail';
              }

              if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)) {
                return 'Digite um e-mail válido';
              }

              return null;
            },
          ),

          const SizedBox(height: 14),

          // Campo de Senha
          AppPasswordField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            label: 'Senha',
            labelStyle: ThemeTextStyles.authBody,
            hintText: 'Digite sua senha',
            textInputAction: TextInputAction.done,
            errorStyle: _loginErrorStyle,
            onFieldSubmitted: (_) {
              _login();
            },
            validator: (value) {
              final password = value ?? '';

              if (password.isEmpty) {
                return 'Informe sua senha';
              }

              if (password.length < 6) {
                return 'A senha deve ter no mínimo 6 caracteres';
              }

              return null;
            },
          ),

          const SizedBox(height: 14),

          // Recuperação de senha
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _goToForgotPassword,
              child: Text(
                'Esqueci minha senha',
                style: ThemeTextStyles.body.copyWith(color: ThemeColors.white),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Botão Entrar
          WidgetButton(
            text: 'Entrar',
            onPressed: _login, // Em desenvolvimento.
            backgroundColor: ThemeColors.white,
            foregroundColor: ThemeColors.secondary,
            borderColor: ThemeColors.secondary,
          ),

          const SizedBox(height: 16),

          // Botão Criar Conta
          AppOutlinedButton(
            text: 'Criar Conta',
            onPressed: _goToRegister,
            borderColor: ThemeColors.white,
            textColor: ThemeColors.white,
          ),
        ],
      ),
    );
  }
}
