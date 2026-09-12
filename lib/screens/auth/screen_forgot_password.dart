import 'package:appets/core/constants/constants_strings_auth.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/extensions/extension_auth_error.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/auth/widget_auth_button.dart';
import 'package:appets/widgets/auth/widget_auth_header.dart';
import 'package:appets/widgets/auth/widget_auth_page_layout.dart';
import 'package:appets/widgets/feedback/widget_dialogs.dart';
import 'package:appets/widgets/feedback/widget_process.dart';
import 'package:appets/widgets/fields/widget_email_field.dart';
import 'package:flutter/material.dart';

/// Tela para solicitar recuperação de senha pelo e-mail cadastrado.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with WGProcessMixin {
  // Controla a validação do formulário de recuperação.
  final _formKey = GlobalKey<FormState>();

  // Armazena o e-mail informado pelo usuário.
  final _emailController = TextEditingController();

  // Libera o controlador ao sair da tela.
  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
  }

  /// Volta para a tela anterior (login).
  void _goBack() {
    Navigator.pop(context);
  }

  /// Envia o link de recuperação de senha para o e-mail informado.
  void _sendRecoveryEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = await pushProcess(
      message: AuthStrings.RECOVER_LOADING,
      task: () async {
        try {
          final authService = AuthService.instance;
          await authService.sendPasswordResetEmail(
            _emailController.text.trim(),
          );
          return const WGProcessResult.success();
        } on Exception catch (e) {
          return WGProcessResult.failure(
            e.authMessage(AuthStrings.RECOVER_ERROR, {
              'user-not-found': AuthStrings.EMAIL_NOT_REGISTERED,
              'invalid-email': AuthStrings.INVALID_EMAIL,
            }),
          );
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
            message: AuthStrings.RECOVER_LINK_SENT,
          );
        }
        if (mounted) {
          Navigator.pop(context);
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

  // Constrói a tela de recuperação de senha.
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
          const WGAuthHeader.auth(headline: AuthStrings.RECOVER_TITLE),

          const SizedBox(height: 8),

          // Texto informativo
          Text(
            AuthStrings.RECOVER_DESCRIPTION,
            textAlign: TextAlign.center,
            style: ThemeTextStyles.authBody,
          ),

          const SizedBox(height: 16),

          // Campo de E-mail
          WGEmailField(
            controller: _emailController,
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: 12),

          // Botão Enviar
          WGAuthButton(
            text: AuthStrings.RECOVER_BUTTON,
            onPressed: _sendRecoveryEmail,
          ),

          const SizedBox(height: 12),

          // Botão Voltar
          WGAuthSecondaryButton(
            text: AuthStrings.BACK_TO_LOGIN,
            onPressed: _goBack,
          ),
        ],
      ),
    );
  }
}
