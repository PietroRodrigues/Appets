import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/extensions/extension_auth_error.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/auth/widget_auth_page_layout.dart';
import 'package:appets/widgets/auth/widget_auth_header.dart';
import 'package:appets/widgets/auth/widget_password_field.dart';
import 'package:appets/widgets/common/buttons/widget_button.dart';
import 'package:appets/widgets/common/buttons/widget_outlined_button.dart';
import 'package:appets/widgets/common/feedback/widget_snack_bar.dart';
import 'package:appets/widgets/common/fields/widget_text_field.dart';

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

  // Libera os controladores e focus nodes ao sair da tela.
  @override
  void dispose() {
    _emailController.dispose();

    _passwordController.dispose();

    _emailFocusNode.dispose();

    _passwordFocusNode.dispose();

    super.dispose();
  }

  /// Navega para a tela de cadastro.
  void _goToRegister() {
    Navigator.pushNamed(context, AppRoutes.register);
  }

  /// Navega para a tela de recuperação de senha.
  void _goToForgotPassword() {
    Navigator.pushNamed(context, AppRoutes.forgotPassword);
  }

  /// Autentica o usuário com e-mail e senha e navega para a Home.
  void _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final authService = AuthService();
      await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on Exception catch (e) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        e.authMessage(AppStrings.loginError, {
          'user-not-found': AppStrings.userNotFound,
          'wrong-password': AppStrings.wrongPasswordMessage,
          'invalid-email': AppStrings.invalidEmail,
          'invalid-credential': AppStrings.invalidCredentials,
        }),
      );
    }
  }

  /// Autentica o usuário com a conta Google e navega para a Home.
  void _loginWithGoogle() async {
    try {
      final authService = AuthService();
      final result = await authService.loginWithGoogle();
      if (result == null && mounted) {
        AppSnackBar.show(context, AppStrings.googleLoginCanceled);
      } else if (result != null && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on Exception catch (e) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        e.authMessage(AppStrings.googleLoginError, {
          'network_error': AppStrings.connectionError,
          'sign_in_canceled': AppStrings.loginCanceled,
        }),
      );
    }
  }

  // Constrói a tela de login com formulário e botões de autenticação.
  @override
  Widget build(BuildContext context) {
    return AppAuthPageLayout(
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
            headline: AppStrings.welcomeBack,
            description: '',
            textColor: ThemeColors.white,
          ),

          const SizedBox(height: 32),

          // Campo de E-mail
          AppTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            label: AppStrings.email,
            labelStyle: ThemeTextStyles.authBody,
            hintText: AppStrings.emailHint,
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
                return AppStrings.emailRequired;
              }

              if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)) {
                return AppStrings.emailInvalid;
              }

              return null;
            },
          ),

          const SizedBox(height: 14),

          // Campo de Senha
          AppPasswordField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            label: AppStrings.password,
            labelStyle: ThemeTextStyles.authBody,
            hintText: AppStrings.passwordHint,
            textInputAction: TextInputAction.done,
            errorStyle: _loginErrorStyle,
            onFieldSubmitted: (_) {
              _login();
            },
            validator: (value) {
              final password = value ?? '';

              if (password.isEmpty) {
                return AppStrings.passwordRequired;
              }

              if (password.length < 6) {
                return AppStrings.passwordMinLength;
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
                AppStrings.forgotPassword,
                style: ThemeTextStyles.body.copyWith(color: ThemeColors.white),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Botão Entrar
          AppButton(
            text: AppStrings.loginButton,
            onPressed: _login,
            backgroundColor: ThemeColors.white,
            foregroundColor: ThemeColors.secondary,
            borderColor: ThemeColors.secondary,
          ),

          const SizedBox(height: 16),

          // Botão Criar Conta
          AppOutlinedButton(
            text: AppStrings.createAccount,
            onPressed: _goToRegister,
            borderColor: ThemeColors.white,
            textColor: ThemeColors.white,
          ),

          const SizedBox(height: 24),

          // Divisor
          Row(
            children: [
              const Expanded(
                child: Divider(color: ThemeColors.white, thickness: 0.5),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppStrings.or,
                  style: ThemeTextStyles.body.copyWith(
                    color: ThemeColors.white,
                  ),
                ),
              ),
              const Expanded(
                child: Divider(color: ThemeColors.white, thickness: 0.5),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Botão Google
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _loginWithGoogle,
              style: OutlinedButton.styleFrom(
                backgroundColor: ThemeColors.white,
                side: const BorderSide(color: ThemeColors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              icon: const Icon(
                Icons.g_mobiledata,
                size: 28,
                color: Colors.red,
              ),
              label: Text(
                AppStrings.googleLogin,
                style: ThemeTextStyles.body.copyWith(
                  color: ThemeColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
