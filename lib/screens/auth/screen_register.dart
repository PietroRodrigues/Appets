import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/extensions/extension_auth_error.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/models/user_model.dart';
import 'package:appets/widgets/auth/widget_auth_page_layout.dart';
import 'package:appets/widgets/auth/widget_auth_header.dart';
import 'package:appets/widgets/auth/widget_password_field.dart';
import 'package:appets/widgets/common/buttons/widget_button.dart';
import 'package:appets/widgets/common/buttons/widget_outlined_button.dart';
import 'package:appets/widgets/common/feedback/widget_snack_bar.dart';
import 'package:appets/widgets/common/fields/widget_text_field.dart';

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

  // Libera os controladores ao sair da tela.
  @override
  void dispose() {
    _nameController.dispose();

    _emailController.dispose();

    _passwordController.dispose();

    _confirmPasswordController.dispose();

    super.dispose();
  }

  /// Volta para a tela anterior (login).
  void _goBack() {
    Navigator.pop(context);
  }

  /// Cadastra o usuário, persiste o documento no Firestore e navega para a Home.
  void _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      if (!mounted) return;
      AppSnackBar.show(context, AppStrings.passwordMismatch);
      return;
    }

    try {
      final authService = AuthService();
      final credential = await authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await authService.updateDisplayName(_nameController.text.trim());

      final user = credential.user;
      if (user != null) {
        final userModel = UserModel.fromFirebaseUser(user);
        await FirestoreService().createUser(userModel);
      }

      if (!mounted) return;
      AppSnackBar.show(context, AppStrings.accountCreated);
      Navigator.pushReplacementNamed(context, '/home');
    } on Exception catch (e) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        e.authMessage(AppStrings.registerError, {
          'email-already-in-use': AppStrings.emailAlreadyInUse,
          'weak-password': AppStrings.weakPassword,
          'invalid-email': AppStrings.invalidEmail,
        }),
      );
    }
  }

  // Constrói a tela de cadastro com o formulário completo.
  @override
  Widget build(BuildContext context) {
    return AppAuthPageLayout(
      formKey: _formKey,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // Cabeçalho
          const AppAuthHeader(
            logoWidth: 250,
            headline: AppStrings.createYourAccount,
            description: '',
            textColor: ThemeColors.white,
          ),

          const SizedBox(height: 28),

          // Nome
          AppTextField(
            controller: _nameController,
            label: AppStrings.registerNameLabel,
            labelStyle: ThemeTextStyles.authBody,
            hintText: AppStrings.registerNameHint,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.person_outline,
          ),

          const SizedBox(height: 14),

          // E-mail
          AppTextField(
            controller: _emailController,
            label: AppStrings.email,
            labelStyle: ThemeTextStyles.authBody,
            hintText: AppStrings.emailHint,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.email_outlined,
          ),

          const SizedBox(height: 14),

          // Senha
          AppPasswordField(
            controller: _passwordController,
            label: AppStrings.password,
            labelStyle: ThemeTextStyles.authBody,
            hintText: AppStrings.passwordHint,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 14),

          // Confirmar Senha
          AppPasswordField(
            controller: _confirmPasswordController,
            label: AppStrings.confirmPassword,
            labelStyle: ThemeTextStyles.authBody,
            hintText: AppStrings.confirmPasswordHint,
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: 24),

          // Botão Criar Conta
          AppButton(
            text: AppStrings.createAccount,
            onPressed: _register,
            backgroundColor: ThemeColors.white,
            foregroundColor: ThemeColors.secondary,
            borderColor: ThemeColors.secondary,
          ),

          const SizedBox(height: 16),

          // Voltar para Login
          AppOutlinedButton(
            text: AppStrings.alreadyHaveAccount,
            onPressed: _goBack,
            textColor: ThemeColors.white,
            borderColor: ThemeColors.white,
          ),

        ],
      ),
    );
  }
}
