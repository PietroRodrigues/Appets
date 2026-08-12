import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/auth/widget_auth_header.dart';
import 'package:appets/widgets/common/widget_button.dart';
import 'package:appets/widgets/common/widget_outlined_button.dart';
import 'package:appets/widgets/common/widget_text_field.dart';
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

  // Controla se as senhas aparecem ou ficam ocultas.
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageLayout(
      formKey: _formKey,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          //----------------------------------------------------------
          // Cabeçalho
          //----------------------------------------------------------
          const AppAuthHeader(
            logoWidth: 250,
            headline: 'Crie sua conta',
            description: '',
            textColor: AppColors.white,
          ),

          const SizedBox(height: 28),

          //----------------------------------------------------------
          // Nome
          //----------------------------------------------------------
          AppTextField(
            controller: _nameController,
            label: 'Nome',
            labelStyle: AppTextStyles.authBody,
            hintText: 'Digite seu nome completo',
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.person_outline,
          ),

          const SizedBox(height: 14),

          //----------------------------------------------------------
          // E-mail
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
          // Senha
          //----------------------------------------------------------
          AppTextField(
            controller: _passwordController,
            label: 'Senha',
            labelStyle: AppTextStyles.authBody,
            hintText: 'Digite sua senha',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
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
          // Confirmar Senha
          //----------------------------------------------------------
          AppTextField(
            controller: _confirmPasswordController,
            label: 'Confirmar Senha',
            labelStyle: AppTextStyles.authBody,
            hintText: 'Digite novamente sua senha',
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              onPressed: _toggleConfirmPasswordVisibility,
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),

          const SizedBox(height: 24),

          //----------------------------------------------------------
          // Botão Criar Conta
          //----------------------------------------------------------
          AppButton(
            text: 'Criar Conta',
            onPressed: _register, // Em desenvolvimento.
            backgroundColor: AppColors.info,
            foregroundColor: AppColors.white,
          ),

          const SizedBox(height: 16),

          //----------------------------------------------------------
          // Voltar para Login
          //----------------------------------------------------------
          AppOutlinedButton(
            text: 'Já possuo uma conta',
            onPressed: _goBack,
            textColor: AppColors.white,
            borderColor: AppColors.white,
          ),

        ],
      ),
    );
  }
}
