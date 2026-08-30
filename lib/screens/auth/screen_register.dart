import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/extensions/extension_auth_error.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/models/user_model.dart';
import 'package:appets/widgets/auth/widget_auth.dart';
import 'package:appets/widgets/common/fields/widget_fields.dart';
import 'package:appets/widgets/common/buttons/widget_buttons.dart';
import 'package:appets/widgets/common/feedback/widget_process_loading.dart';
import 'package:appets/widgets/common/feedback/widget_snack_bar.dart';

/// Tela de cadastro para criar uma nova conta no app.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controla a validação do formulário de cadastro.
  final _formKey = GlobalKey<FormState>();

  // Evita envio duplicado enquanto o cadastro está em andamento.
  bool _isSubmitting = false;

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
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      if (!mounted) return;
      AppSnackBar.show(context, AppStrings.passwordMismatch);
      return;
    }

    _isSubmitting = true;
    FocusManager.instance.primaryFocus?.unfocus();

    final result = await Navigator.push<AppProcessResult>(
      context,
      MaterialPageRoute<AppProcessResult>(
        builder: (_) => AppProcessLoadingScreen(
          message: AppStrings.registerLoading,
          task: () async {
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
              return const AppProcessResult.success();
            } on Exception catch (e) {
              return AppProcessResult.failure(
                e.authMessage(AppStrings.registerError, {
                  'email-already-in-use': AppStrings.emailAlreadyInUse,
                  'weak-password': AppStrings.weakPassword,
                  'invalid-email': AppStrings.invalidEmail,
                }),
              );
            }
          },
        ),
      ),
    );
    if (!mounted) return;

    switch (result?.status) {
      case AppProcessStatus.success:
        AppSnackBar.show(context, AppStrings.accountCreated);
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      case AppProcessStatus.failure:
        AppSnackBar.show(context, result!.message!);
      case AppProcessStatus.canceled:
      case null:
        break;
    }

    _isSubmitting = false;
  }

  // Constrói a tela de cadastro com o formulário completo.
  @override
  Widget build(BuildContext context) {
    return AppAuthPageLayout(
      formKey: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),

          // Cabeçalho
          const AppAuthHeader(
            logoWidth: 240,
            headline: AppStrings.createYourAccount,
            description: '',
            textColor: ThemeColors.white,
          ),

          const SizedBox(height: 8),

          // Nome
          AppTextField(
            controller: _nameController,
            label: AppStrings.registerNameLabel,
            labelStyle: ThemeTextStyles.authBody,
            hintText: AppStrings.registerNameHint,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.person_outline,
          ),

          const SizedBox(height: 8),

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

          const SizedBox(height: 8),

          // Senha
          AppPasswordField(
            controller: _passwordController,
            label: AppStrings.password,
            labelStyle: ThemeTextStyles.authBody,
            hintText: AppStrings.passwordHint,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 8),

          // Confirmar Senha
          AppPasswordField(
            controller: _confirmPasswordController,
            label: AppStrings.confirmPassword,
            labelStyle: ThemeTextStyles.authBody,
            hintText: AppStrings.confirmPasswordHint,
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: 12),

          // Botão Criar Conta
          AppButton(
            text: AppStrings.createAccount,
            onPressed: _register,
            height: 48,
            backgroundColor: ThemeColors.white,
            foregroundColor: ThemeColors.secondary,
            borderColor: ThemeColors.secondary,
          ),

          const SizedBox(height: 12),

          // Voltar para Login
          AppOutlinedButton(
            text: AppStrings.alreadyHaveAccount,
            onPressed: _goBack,
            height: 48,
            textColor: ThemeColors.white,
            borderColor: ThemeColors.white,
          ),

        ],
      ),
    );
  }
}
