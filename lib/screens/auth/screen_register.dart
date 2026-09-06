import 'package:appets/core/constants/constants_strings_auth.dart';
import 'package:appets/core/extensions/extension_auth_error.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/models/user_model.dart';
import 'package:appets/widgets/auth/widget_auth_button.dart';
import 'package:appets/widgets/auth/widget_auth_header.dart';
import 'package:appets/widgets/auth/widget_auth_page_layout.dart';
import 'package:appets/widgets/feedback/widget_process.dart';
import 'package:appets/widgets/feedback/widget_snack_bar.dart';
import 'package:appets/widgets/fields/widget_email_field.dart';
import 'package:appets/widgets/fields/widget_password_field.dart';
import 'package:appets/widgets/fields/widget_text_field.dart';
import 'package:flutter/material.dart';

/// Tela de cadastro para criar uma nova conta no app.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with WGProcessMixin {
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
      WGSnackBar.show(context, AuthStrings.PASSWORD_MISMATCH);
      return;
    }

    final result = await pushProcess(
      message: AuthStrings.REGISTER_LOADING,
      task: () async {
        try {
          final authService = AuthService.instance;
          final credential = await authService.register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

          await authService.updateDisplayName(_nameController.text.trim());

          final user = credential.user;
          if (user != null) {
            final userModel = UserModel.fromFirebaseUser(user);
            await FirestoreService.instance.createUser(userModel);
          }
          return const WGProcessResult.success();
        } on Exception catch (e) {
          return WGProcessResult.failure(
            e.authMessage(AuthStrings.REGISTER_ERROR, {
              'email-already-in-use': AuthStrings.EMAIL_ALREADY_IN_USE,
              'weak-password': AuthStrings.WEAK_PASSWORD,
              'invalid-email': AuthStrings.INVALID_EMAIL,
            }),
          );
        }
      },
    );
    if (!mounted) return;

    switch (result?.status) {
      case WGProcessStatus.success:
        WGSnackBar.show(context, AuthStrings.ACCOUNT_CREATED);
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      case WGProcessStatus.failure:
        WGSnackBar.show(context, result!.message!);
      case WGProcessStatus.canceled:
      case null:
        break;
    }
  }

  // Constrói a tela de cadastro com o formulário completo.
  @override
  Widget build(BuildContext context) {
    return WGAuthPageLayout(
      formKey: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),

          // Cabeçalho
          const WGAuthHeader.auth(headline: AuthStrings.CREATE_YOUR_ACCOUNT),

          const SizedBox(height: 8),

          // Nome
          WGTextField(
            controller: _nameController,
            label: AuthStrings.REGISTER_NAME_LABEL,
            labelStyle: ThemeTextStyles.authBody,
            hintText: AuthStrings.REGISTER_NAME_HINT,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.person_outline,
          ),

          const SizedBox(height: 8),

          // E-mail
          WGEmailField(
            controller: _emailController,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 8),

          // Senha
          WGPasswordField(
            controller: _passwordController,
            label: AuthStrings.PASSWORD,
            labelStyle: ThemeTextStyles.authBody,
            hintText: AuthStrings.PASSWORD_HINT,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 8),

          // Confirmar Senha
          WGPasswordField(
            controller: _confirmPasswordController,
            label: AuthStrings.CONFIRM_PASSWORD,
            labelStyle: ThemeTextStyles.authBody,
            hintText: AuthStrings.CONFIRM_PASSWORD_HINT,
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: 12),

          // Botão Criar Conta
          WGAuthButton(text: AuthStrings.CREATE_ACCOUNT, onPressed: _register),

          const SizedBox(height: 12),

          // Voltar para Login
          WGAuthSecondaryButton(
            text: AuthStrings.ALREADY_HAVE_ACCOUNT,
            onPressed: _goBack,
          ),
        ],
      ),
    );
  }
}
