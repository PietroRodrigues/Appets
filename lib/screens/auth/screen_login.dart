import 'package:appets/core/constants/constants_strings_auth.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/extensions/extension_auth_error.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/core/validators/validators.dart';
import 'package:appets/models/user_model.dart';
import 'package:appets/widgets/auth/widget_auth_button.dart';
import 'package:appets/widgets/auth/widget_auth_header.dart';
import 'package:appets/widgets/auth/widget_auth_page_layout.dart';
import 'package:appets/widgets/buttons/widget_buttons.dart';
import 'package:appets/widgets/feedback/widget_dialogs.dart';
import 'package:appets/widgets/feedback/widget_process.dart';
import 'package:appets/widgets/fields/widget_email_field.dart';
import 'package:appets/widgets/fields/widget_password_field.dart';
import 'package:flutter/material.dart';

/// Tela de autenticação para acesso do usuário ao app.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WGProcessMixin {
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
    color: ThemeColors.errorOnPrimary,
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

    final result = await pushProcess(
      message: AuthStrings.LOGIN_LOADING,
      task: () async {
        try {
          await AuthService.instance.login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          return const WGProcessResult.success();
        } on Exception catch (e) {
          return WGProcessResult.failure(
            e.authMessage(AuthStrings.LOGIN_ERROR, {
              'user-not-found': AuthStrings.USER_NOT_FOUND,
              'wrong-password': AuthStrings.WRONG_PASSWORD_MESSAGE,
              'invalid-email': AuthStrings.INVALID_EMAIL,
              'invalid-credential': AuthStrings.INVALID_CREDENTIALS,
            }),
          );
        }
      },
    );
    if (!mounted) return;

    switch (result?.status) {
      case WGProcessStatus.success:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      case WGProcessStatus.failure:
        if (mounted) {
          await WGDialog.showAction(
            context,
            title: SharedStrings.ERROR_TITLE,
            message: result!.message!,
            actionColor: ThemeColors.error,
          );
        }
      case WGProcessStatus.canceled:
      case null:
        break;
    }
  }

  /// Autentica o usuário com a conta Google, garante o cadastro no
  /// Firestore e navega para a Home.
  void _loginWithGoogle() async {
    final result = await pushProcess(
      message: AuthStrings.GOOGLE_LOGIN_LOADING,
      task: () async {
        try {
          final googleResult = await AuthService.instance.loginWithGoogle();
          if (googleResult == null) {
            return const WGProcessResult.canceled();
          }

          final firebaseUser = googleResult.user;
          if (firebaseUser != null) {
            await AuthService.instance.ensureUserDocument(
              UserModel.fromFirebaseUser(firebaseUser),
            );
          }
          return const WGProcessResult.success();
        } on Exception catch (e) {
          return WGProcessResult.failure(
            e.authMessage(AuthStrings.GOOGLE_LOGIN_ERROR, {
              'network_error': AuthStrings.CONNECTION_ERROR,
              'sign_in_canceled': AuthStrings.LOGIN_CANCELED,
            }),
          );
        }
      },
    );
    if (!mounted) return;

    switch (result?.status) {
      case WGProcessStatus.success:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      case WGProcessStatus.canceled:
        if (mounted) {
          await WGDialog.showAction(
            context,
            title: SharedStrings.NOTICE_TITLE,
            message: AuthStrings.GOOGLE_LOGIN_CANCELED,
          );
        }
      case WGProcessStatus.failure:
        if (mounted) {
          await WGDialog.showAction(
            context,
            title: SharedStrings.ERROR_TITLE,
            message: result!.message!,
            actionColor: ThemeColors.error,
          );
        }
      case null:
        break;
    }
  }

  // Constrói a tela de login com formulário e botões de autenticação.
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

          // Cabeçalho da tela
          const WGAuthHeader.auth(),

          const SizedBox(height: 8),

          // Campo de E-mail
          WGEmailField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            textInputAction: TextInputAction.next,
            errorStyle: _loginErrorStyle,
            onFieldSubmitted: (_) {
              _passwordFocusNode.requestFocus();
            },
            validator: AppValidators.validateEmail,
          ),

          const SizedBox(height: 8),

          // Campo de Senha
          WGPasswordField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            label: AuthStrings.PASSWORD,
            labelStyle: ThemeTextStyles.authBody,
            hintText: AuthStrings.PASSWORD_HINT,
            textInputAction: TextInputAction.done,
            errorStyle: _loginErrorStyle,
            onFieldSubmitted: (_) {
              _login();
            },
            validator: (value) {
              final password = value ?? '';

              if (password.isEmpty) {
                return AuthStrings.PASSWORD_REQUIRED;
              }

              if (password.length < 6) {
                return AuthStrings.PASSWORD_MIN_LENGTH;
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
                AuthStrings.FORGOT_PASSWORD,
                style: ThemeTextStyles.body.copyWith(color: ThemeColors.white),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Botão Entrar
          WGAuthButton(text: AuthStrings.LOGIN_BUTTON, onPressed: _login),

          const SizedBox(height: 12),

          // Botão Criar Conta
          WGAuthSecondaryButton(
            text: AuthStrings.CREATE_ACCOUNT,
            onPressed: _goToRegister,
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
                  AuthStrings.OR,
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
          WGGoogleButton(onPressed: _loginWithGoogle, height: 48),
        ],
      ),
    );
  }
}
