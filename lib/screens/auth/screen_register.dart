import 'package:appets/core/constants/constants_strings_auth.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/core/validators/validators.dart';
import 'package:appets/models/user_model.dart';
import 'package:appets/widgets/auth/widget_auth_button.dart';
import 'package:appets/widgets/auth/widget_auth_header.dart';
import 'package:appets/widgets/auth/widget_auth_page_layout.dart';
import 'package:appets/widgets/feedback/widget_dialogs.dart';
import 'package:appets/widgets/feedback/widget_process.dart';
import 'package:appets/widgets/fields/widget_email_field.dart';
import 'package:appets/widgets/fields/widget_password_field.dart';
import 'package:appets/widgets/fields/widget_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    final result = await pushProcess(
      message: AuthStrings.REGISTER_LOADING,
      task: () async {
        // Vira `true` assim que o Auth cria a conta; se o Firestore falhar,
        // desfazemos a conta para não deixar e-mail "fantasma".
        var created = false;
        try {
          final authService = AuthService.instance;
          final credential = await authService.register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          created = true;

          final name = _nameController.text.trim();
          final user = credential.user;
          if (user != null) {
            final userModel = UserModel.fromFirebaseUser(user, name: name);
            await AuthService.instance.ensureUserDocument(userModel);
          }

          // Nome do perfil do Auth é cosmético (o app lê o Firestore);
          // falha aqui não pode bloquear o cadastro.
          try {
            await authService.updateDisplayName(name);
          } catch (e) {
            debugPrint('RegisterDisplayNameIgnored: $e');
          }
          return const WGProcessResult.success();
        } on FirebaseAuthException catch (e) {
          debugPrint('RegisterAuthError: ${e.code} — ${e.message}');
          if (created) {
            await _discardPhantomAccount();
            return WGProcessResult.failure(AuthStrings.REGISTER_SAVE_ERROR);
          }
          return WGProcessResult.failure(_authErrorMessage(e));
        } on Exception catch (e) {
          debugPrint('RegisterError: $e');
          if (created) {
            await _discardPhantomAccount();
          }
          return WGProcessResult.failure(AuthStrings.REGISTER_SAVE_ERROR);
        } catch (e, s) {
          // Erros (ex.: TypeError) também não podem travar a tela de loading.
          debugPrint('RegisterUnexpectedError: $e');
          debugPrint('$s');
          if (created) {
            await _discardPhantomAccount();
          }
          return WGProcessResult.failure(AuthStrings.REGISTER_SAVE_ERROR);
        }
      },
    );
    if (!mounted) return;

    switch (result?.status) {
      case WGProcessStatus.success:
        if (mounted) {
          await WGDialog.showAction(
            context,
            title: SharedStrings.SUCCESS_TITLE,
            message: AuthStrings.ACCOUNT_CREATED,
          );
        }
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
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
      case WGProcessStatus.canceled:
      case null:
        break;
    }
  }

  /// Traduz o código de erro do Firebase na mensagem do que o usuário errou.
  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return AuthStrings.EMAIL_ALREADY_IN_USE;
      case 'weak-password':
        return AuthStrings.WEAK_PASSWORD;
      case 'invalid-email':
        return AuthStrings.INVALID_EMAIL;
      case 'operation-not-allowed':
        return AuthStrings.REGISTER_EMAIL_DISABLED;
      case 'network-request-failed':
        return AuthStrings.CONNECTION_ERROR;
      default:
        return AuthStrings.REGISTER_ERROR;
    }
  }

  /// Exclui a conta recém-criada no Auth (sem doc no Firestore),
  /// ignorando falhas da própria exclusão.
  Future<void> _discardPhantomAccount() async {
    try {
      await AuthService.instance.deleteAccount();
    } catch (e) {
      debugPrint('RegisterCleanupError: $e');
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
            validator: (value) => (value?.trim().isEmpty ?? true)
                ? AuthStrings.NAME_REQUIRED
                : null,
          ),

          const SizedBox(height: 8),

          // E-mail
          WGEmailField(
            controller: _emailController,
            textInputAction: TextInputAction.next,
            validator: AppValidators.validateEmail,
          ),

          const SizedBox(height: 8),

          // Senha
          WGPasswordField(
            controller: _passwordController,
            label: AuthStrings.PASSWORD,
            labelStyle: ThemeTextStyles.authBody,
            hintText: AuthStrings.PASSWORD_HINT,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AuthStrings.PASSWORD_REQUIRED;
              }
              if (value.length < 6) {
                return AuthStrings.PASSWORD_MIN_LENGTH;
              }
              return null;
            },
          ),

          const SizedBox(height: 8),

          // Confirmar Senha
          WGPasswordField(
            controller: _confirmPasswordController,
            label: AuthStrings.CONFIRM_PASSWORD,
            labelStyle: ThemeTextStyles.authBody,
            hintText: AuthStrings.CONFIRM_PASSWORD_HINT,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AuthStrings.PASSWORD_REQUIRED;
              }
              if (value != _passwordController.text) {
                return AuthStrings.PASSWORD_MISMATCH;
              }
              return null;
            },
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
