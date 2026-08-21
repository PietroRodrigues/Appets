import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/auth/widget_auth_header.dart';
import 'package:appets/widgets/auth/widget_password_field.dart';
import 'package:appets/widgets/common/buttons/widget_button.dart';
import 'package:appets/widgets/common/buttons/widget_outlined_button.dart';
import 'package:appets/widgets/common/fields/widget_text_field.dart';
import 'package:appets/widgets/auth/widget_auth_page_layout.dart';

/// Tela de cadastro para criar uma nova conta no app.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controla a validação do formulário de cadastro.
  final _formKey = GlobalKey<FormState>();

  // Armazena os dados digitados pelo usuário.
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();

    _emailController.dispose();

    _passwordController.dispose();

    _confirmPasswordController.dispose();

    super.dispose();
  }

  void _goBack() {
    Navigator.pop(context);
  }

  void _register() { // Em desenvolvimento.
    // TODO:
    // Criar conta utilizando Firebase Authentication.
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageLayout(
      formKey: _formKey,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // Cabeçalho
          const AppAuthHeader(
            logoWidth: 250,
            headline: 'Crie sua conta',
            description: '',
            textColor: ThemeColors.white,
          ),

          const SizedBox(height: 28),

          // Nome
          AppTextField(
            controller: _nameController,
            label: 'Nome',
            labelStyle: ThemeTextStyles.authBody,
            hintText: 'Digite seu nome completo',
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.person_outline,
          ),

          const SizedBox(height: 14),

          // E-mail
          AppTextField(
            controller: _emailController,
            label: 'E-mail',
            labelStyle: ThemeTextStyles.authBody,
            hintText: 'Digite seu e-mail',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.email_outlined,
          ),

          const SizedBox(height: 14),

          // Senha
          AppPasswordField(
            controller: _passwordController,
            label: 'Senha',
            labelStyle: ThemeTextStyles.authBody,
            hintText: 'Digite sua senha',
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 14),

          // Confirmar Senha
          AppPasswordField(
            controller: _confirmPasswordController,
            label: 'Confirmar Senha',
            labelStyle: ThemeTextStyles.authBody,
            hintText: 'Digite novamente sua senha',
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: 24),

          // Botão Criar Conta
          WidgetButton(
            text: 'Criar Conta',
            onPressed: _register, // Em desenvolvimento.
            backgroundColor: ThemeColors.white,
            foregroundColor: ThemeColors.secondary,
            borderColor: ThemeColors.secondary,
          ),

          const SizedBox(height: 16),

          // Voltar para Login
          AppOutlinedButton(
            text: 'Já possuo uma conta',
            onPressed: _goBack,
            textColor: ThemeColors.white,
            borderColor: ThemeColors.white,
          ),

        ],
      ),
    );
  }
}
