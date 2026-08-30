import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/extensions/extension_auth_error.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/models/user_model.dart';
import 'package:appets/widgets/auth/widget_auth.dart';
import 'package:appets/widgets/common/fields/widget_fields.dart';
import 'package:appets/widgets/common/buttons/widget_buttons.dart';
import 'package:appets/widgets/common/feedback/widget_process_loading.dart';
import 'package:appets/widgets/common/feedback/widget_snack_bar.dart';

/// Tela de autenticação para acesso do usuário ao app.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controla a validação do formulário de login.
  final _formKey = GlobalKey<FormState>();

  // Evita envio duplicado enquanto uma autenticação está em andamento.
  bool _isSubmitting = false;

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
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    _isSubmitting = true;
    FocusManager.instance.primaryFocus?.unfocus();

    final result = await Navigator.push<AppProcessResult>(
      context,
      MaterialPageRoute<AppProcessResult>(
        builder: (_) => AppProcessLoadingScreen(
          message: AppStrings.loginLoading,
          task: () async {
            try {
              final authService = AuthService();
              await authService.login(
                email: _emailController.text.trim(),
                password: _passwordController.text,
              );
              return const AppProcessResult.success();
            } on Exception catch (e) {
              return AppProcessResult.failure(
                e.authMessage(AppStrings.loginError, {
                  'user-not-found': AppStrings.userNotFound,
                  'wrong-password': AppStrings.wrongPasswordMessage,
                  'invalid-email': AppStrings.invalidEmail,
                  'invalid-credential': AppStrings.invalidCredentials,
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
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      case AppProcessStatus.failure:
        AppSnackBar.show(context, result!.message!);
      case AppProcessStatus.canceled:
      case null:
        break;
    }

    _isSubmitting = false;
  }

  /// Autentica o usuário com a conta Google, garante o cadastro no
  /// Firestore e navega para a Home.
  void _loginWithGoogle() async {
    if (_isSubmitting) return;

    _isSubmitting = true;
    FocusManager.instance.primaryFocus?.unfocus();

    final result = await Navigator.push<AppProcessResult>(
      context,
      MaterialPageRoute<AppProcessResult>(
        builder: (_) => AppProcessLoadingScreen(
          message: AppStrings.googleLoginLoading,
          task: () async {
            try {
              final authService = AuthService();
              final googleResult = await authService.loginWithGoogle();
              if (googleResult == null) {
                return const AppProcessResult.canceled();
              }

              final firebaseUser = googleResult.user;
              if (firebaseUser != null) {
                await authService.ensureUserDocument(
                  UserModel.fromFirebaseUser(firebaseUser),
                );
              }
              return const AppProcessResult.success();
            } on Exception catch (e) {
              return AppProcessResult.failure(
                e.authMessage(AppStrings.googleLoginError, {
                  'network_error': AppStrings.connectionError,
                  'sign_in_canceled': AppStrings.loginCanceled,
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
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      case AppProcessStatus.canceled:
        AppSnackBar.show(context, AppStrings.googleLoginCanceled);
      case AppProcessStatus.failure:
        AppSnackBar.show(context, result!.message!);
      case null:
        break;
    }

    _isSubmitting = false;
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
          const SizedBox(height: 8),

          // Cabeçalho da tela
          const AppAuthHeader(
            logoWidth: 240,
            description: '',
            textColor: ThemeColors.white,
          ),

          const SizedBox(height: 8),

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

          const SizedBox(height: 8),

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

          const SizedBox(height: 8),

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

          const SizedBox(height: 12),

          // Botão Entrar
          AppButton(
            text: AppStrings.loginButton,
            onPressed: _login,
            height: 48,
            backgroundColor: ThemeColors.white,
            foregroundColor: ThemeColors.secondary,
            borderColor: ThemeColors.secondary,
          ),

          const SizedBox(height: 12),

          // Botão Criar Conta
          AppOutlinedButton(
            text: AppStrings.createAccount,
            onPressed: _goToRegister,
            height: 48,
            borderColor: ThemeColors.white,
            textColor: ThemeColors.white,
          ),

          const SizedBox(height: 16),

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

          const SizedBox(height: 16),

          // Botão Google
          AppGoogleButton(
            onPressed: _loginWithGoogle,
            height: 48,
          ),
        ],
      ),
    );
  }
}
