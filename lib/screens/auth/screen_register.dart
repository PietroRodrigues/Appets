import 'package:appets/core/constants/constants_strings_auth.dart';
import 'package:appets/core/constants/constants_strings_legal.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/theme/app_colors.dart';
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
  bool _hasAcceptedTerms = false;

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
            final userModel = UserModel.fromFirebaseUser(
              user,
              name: name,
              termsVersion: LegalStrings.TERMS_VERSION,
            );
            await AuthService.instance.ensureUserDocument(userModel);
          }

          // Nome do perfil do Auth é cosmético (o app lê o Firestore);
          // falha aqui não pode bloquear o cadastro.
          try {
            await authService.updateDisplayName(name);
          } catch (_) {
            // Nome do perfil do Auth é cosmético; falha não bloqueia o cadastro.
          }
          return const WGProcessResult.success();
        } on FirebaseAuthException catch (e) {
          if (created) {
            await _discardPhantomAccount();
            return WGProcessResult.failure(AuthStrings.REGISTER_SAVE_ERROR);
          }
          return WGProcessResult.failure(_authErrorMessage(e));
        } on Exception catch (_) {
          if (created) {
            await _discardPhantomAccount();
          }
          return WGProcessResult.failure(AuthStrings.REGISTER_SAVE_ERROR);
        } catch (_) {
          // Erros (ex.: TypeError) também não podem travar a tela de loading.
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
            actionColor: context.appColors.error,
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
      // Ignora falha na própria exclusão; a conta já foi criada no Auth.
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
            labelStyle: ThemeTextStyles.authBody(),
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
            labelStyle: ThemeTextStyles.authBody(),
            hintText: AuthStrings.PASSWORD_HINT,
            textInputAction: TextInputAction.next,
            validator: AppValidators.validatePassword,
          ),

          const SizedBox(height: 8),

          // Confirmar Senha
          WGPasswordField(
            controller: _confirmPasswordController,
            label: AuthStrings.CONFIRM_PASSWORD,
            labelStyle: ThemeTextStyles.authBody(),
            hintText: AuthStrings.CONFIRM_PASSWORD_HINT,
            textInputAction: TextInputAction.done,
            validator: (value) => AppValidators.validatePasswordConfirmation(
              value,
              _passwordController.text,
            ),
          ),

          const SizedBox(height: 12),

          FormField<bool>(
            initialValue: _hasAcceptedTerms,
            validator: (accepted) => accepted == true
                ? null
                : LegalStrings.ACCEPT_TERMS_REQUIRED,
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _hasAcceptedTerms,
                      onChanged: (value) {
                        final accepted = value ?? false;
                        setState(() => _hasAcceptedTerms = accepted);
                        field.didChange(accepted);
                      },
                    ),
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            LegalStrings.ACCEPT_TERMS_PREFIX,
                            style: ThemeTextStyles.caption(context.appColors),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.terms,
                            ),
                            child: const Text(LegalStrings.TERMS_TITLE),
                          ),
                          Text(
                            LegalStrings.ACCEPT_TERMS_AND,
                            style: ThemeTextStyles.caption(context.appColors),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.privacyPolicy,
                            ),
                            child: const Text(LegalStrings.PRIVACY_TITLE),
                          ),
                          Text(
                            '.',
                            style: ThemeTextStyles.caption(context.appColors),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (field.errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      field.errorText!,
                      style: TextStyle(
                        color: context.appColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Botão Criar Conta
          WGAuthButton(
            text: AuthStrings.CREATE_ACCOUNT,
            onPressed: _hasAcceptedTerms ? _register : null,
          ),

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
