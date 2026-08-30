import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/extensions/extension_auth_error.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/auth/widget_auth.dart';
import 'package:appets/widgets/common/buttons/widget_buttons.dart';
import 'package:appets/widgets/common/feedback/widget_process_loading.dart';
import 'package:appets/widgets/common/feedback/widget_snack_bar.dart';
import 'package:appets/widgets/common/fields/widget_fields.dart';

/// Tela para solicitar recuperação de senha pelo e-mail cadastrado.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Controla a validação do formulário de recuperação.
  final _formKey = GlobalKey<FormState>();

  // Evita envio duplicado enquanto o link é gerado.
  bool _isSubmitting = false;

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
          message: AppStrings.recoverLoading,
          task: () async {
            try {
              final authService = AuthService();
              await authService.sendPasswordResetEmail(
                _emailController.text.trim(),
              );
              return const AppProcessResult.success();
            } on Exception catch (e) {
              return AppProcessResult.failure(
                e.authMessage(AppStrings.recoverError, {
                  'user-not-found': AppStrings.emailNotRegistered,
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
        AppSnackBar.show(context, AppStrings.recoverLinkSent);
        Navigator.pop(context);
      case AppProcessStatus.failure:
        AppSnackBar.show(context, result!.message!);
      case AppProcessStatus.canceled:
      case null:
        break;
    }

    _isSubmitting = false;
  }

  // Constrói a tela de recuperação de senha.
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
            headline: AppStrings.recoverTitle,
            description: '',
            textColor: ThemeColors.white,
          ),

          const SizedBox(height: 8),

          // Texto informativo
          Text(
            AppStrings.recoverDescription,
            textAlign: TextAlign.center,
            style: ThemeTextStyles.authBody,
          ),

          const SizedBox(height: 16),

          // Campo de E-mail
          AppTextField(
            controller: _emailController,
            label: AppStrings.email,
            labelStyle: ThemeTextStyles.authBody,
            hintText: AppStrings.emailHint,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.email_outlined,
          ),

          const SizedBox(height: 12),

          // Botão Enviar
          AppButton(
            text: AppStrings.recoverButton,
            onPressed: _sendRecoveryEmail,
            height: 48,
            backgroundColor: ThemeColors.white,
            foregroundColor: ThemeColors.secondary,
            borderColor: ThemeColors.secondary,
          ),

          const SizedBox(height: 12),

          // Botão Voltar
          AppOutlinedButton(
            text: AppStrings.backToLogin,
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
