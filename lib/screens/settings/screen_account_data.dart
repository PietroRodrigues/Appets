import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/core/services/storage_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/models/user_model.dart';
import 'package:appets/widgets/common/display/widget_display.dart';
import 'package:appets/widgets/common/feedback/widget_confirm_dialog.dart';
import 'package:appets/widgets/common/feedback/widget_page_loading.dart';
import 'package:appets/widgets/common/feedback/widget_process_loading.dart';
import 'package:appets/widgets/common/feedback/widget_snack_bar.dart';
import 'package:appets/widgets/common/fields/widget_fields.dart';
import 'package:appets/widgets/common/layout/widget_layout.dart';
import 'package:appets/widgets/main/widget_page_header.dart';

/// Tela de dados da conta do usuário.
///
/// Acessada a partir da tela de perfil, permite ao usuário
/// visualizar e editar suas informações pessoais, endereço
/// e configurações de segurança da conta.
class AccountDataScreen extends StatefulWidget {
  const AccountDataScreen({
    super.key,
  });

  @override
  State<AccountDataScreen> createState() => _AccountDataScreenState();
}

class _AccountDataScreenState extends State<AccountDataScreen> {
  UserModel? _user;
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Carrega os dados do usuário logado do Firestore.
  Future<void> _loadUserData() async {
    final authUser = AuthService().currentUser;
    if (authUser != null) {
      _user = await FirestoreService().getUser(authUser.uid);
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // ACTIONS

  /// Exibe aviso de recurso em desenvolvimento.
  void _showDevelopmentMessage(String feature) {
    AppSnackBar.development(context, feature);
  }

  /// Fluxo de confirmação em duas etapas e exclusão com tela de carregamento.
  void _onDeleteAccountPressed() async {
    final firstConfirmed = await AppConfirmDialog.show(
      context,
      title: AppStrings.deleteAccountTitle,
      message: AppStrings.deleteAccountConfirmMessage,
      confirmLabel: AppStrings.deleteAccountContinue,
      cancelLabel: AppStrings.cancel,
    );

    if (!firstConfirmed || !mounted) return;

    final finalConfirmed = await AppConfirmDialog.show(
      context,
      title: AppStrings.deleteAccountFinalTitle,
      message: AppStrings.deleteAccountFinalMessage,
      confirmLabel: AppStrings.deleteAccountConfirm,
      cancelLabel: AppStrings.cancel,
      messageHighlight: AppStrings.deletePermanentlyHighlight,
    );

    if (!finalConfirmed || !mounted) return;

    setState(() => _isDeleting = true);
    FocusManager.instance.primaryFocus?.unfocus();

    final result = await Navigator.push<AppProcessResult>(
      context,
      MaterialPageRoute<AppProcessResult>(
        builder: (_) => AppProcessLoadingScreen(
          message: AppStrings.deleteAccountLoading,
          task: _deleteAccountTask,
        ),
      ),
    );

    if (!mounted) return;
    setState(() => _isDeleting = false);

    switch (result?.status) {
      case AppProcessStatus.success:
        AppSnackBar.show(context, AppStrings.accountDeleted);
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      case AppProcessStatus.failure:
        AppSnackBar.show(
          context,
          result?.message ?? AppStrings.deleteAccountError,
        );
      case AppProcessStatus.canceled:
      case null:
        break;
    }
  }

  /// Executa a exclusão da conta (dados no Firestore/Storage e Auth),
  /// devolvendo o desfecho para a tela de carregamento.
  ///
  /// Os dados do usuário são apagados ANTES da conta no Firebase Auth:
  /// depois de deletar a conta o usuário é deslogado e o client perde
  /// a credencial, então as regras de segurança do Firestore/Storage
  /// rejeitariam as operações de limpeza.
  Future<AppProcessResult> _deleteAccountTask() async {
    final authService = AuthService();
    final user = authService.currentUser;

    if (user == null) {
      return AppProcessResult.failure(AppStrings.deleteAccountError);
    }

    final uid = user.uid;

    try {
      // 0. Sessão antiga exige reautenticação antes de apagar dados.
      //    Antecipar o reauth evita apagar a base e, em seguida, o
      //    usuário cancelar o reauth (conta viva sem dados).
      if (!_isSessionRecent(user)) {
        final reauth = await _reauthenticate();
        if (reauth.status != AppProcessStatus.success) {
          return reauth;
        }
      }

      // 1. Apaga os dados do usuário enquanto a credencial é válida:
      //    pets (imagens no Storage + documentos) e documento do usuário.
      await _deleteUserData(uid);

      // 2. Exclui a conta no Firebase Auth por último.
      final deletion = await _deleteAuthAccount(authService);
      if (deletion.status != AppProcessStatus.success) {
        return deletion;
      }

      // 3. Garante que o aparelho fique deslogado.
      try {
        await authService.logout();
      } catch (_) {
        // Ignora falha no logout; a conta já foi excluída.
      }

      return const AppProcessResult.success();
    } catch (_) {
      return AppProcessResult.failure(AppStrings.deleteAccountError);
    }
  }

  /// Janela em que o login é considerado recente o suficiente para
  /// deletar a conta sem reautenticação (critério aproximado do
  /// `requires-recent-login` do Firebase Auth).
  static const Duration _recentSessionWindow = Duration(minutes: 5);

  /// Indica se a sessão é recente o bastante para uma operação
  /// sensível (deletar a conta). Sem histórico, assume-se antiga.
  bool _isSessionRecent(User user) {
    final lastSignIn = user.metadata.lastSignInTime;
    if (lastSignIn == null) return false;
    return DateTime.now().difference(lastSignIn) <= _recentSessionWindow;
  }

  /// Apaga os dados do usuário no Firestore e no Storage: pets
  /// (imagens e documentos) e o documento do usuário. Continua
  /// mesmo se algum item falhar.
  Future<void> _deleteUserData(String uid) async {
    try {
      final petService = PetService();
      final storageService = StorageService();
      final myPets = await petService.getPetsByOwner(uid);
      for (final pet in myPets) {
        if (pet.images.isNotEmpty) {
          await storageService.deletePetImages(pet.id, pet.images.length);
        }
        await petService.deletePet(pet.id);
      }
    } catch (_) {
      // Continua mesmo se algum pet falhar.
    }

    try {
      await FirestoreService().deleteUser(uid);
    } catch (_) {
      // Continua mesmo se o documento falhar.
    }
  }

  /// Exclui a conta no Firebase Auth, reautenticando o usuário
  /// quando o login não for recente.
  ///
  /// Devolve [AppProcessResult.canceled] se a reautenticação for
  /// cancelada (exclusão abortada) ou [AppProcessResult.success]
  /// quando a conta foi excluída.
  Future<AppProcessResult> _deleteAuthAccount(AuthService authService) async {
    try {
      await authService.deleteAccount();
      return const AppProcessResult.success();
    } on FirebaseAuthException catch (e) {
      if (e.code != 'requires-recent-login') {
        return AppProcessResult.failure(AppStrings.deleteAccountError);
      }

      final reauth = await _reauthenticate();
      if (reauth.status != AppProcessStatus.success) {
        return reauth;
      }

      try {
        await authService.deleteAccount();
        return const AppProcessResult.success();
      } on Exception {
        return AppProcessResult.failure(AppStrings.deleteAccountError);
      }
    }
  }

  /// Reautentica o usuário conforme o provedor da conta:
  /// Google ou e-mail/senha.
  Future<AppProcessResult> _reauthenticate() async {
    final authService = AuthService();

    if (authService.usesGoogleProvider) {
      try {
        final ok = await authService.reauthenticateWithGoogle();
        return ok
            ? const AppProcessResult.success()
            : const AppProcessResult.canceled();
      } on Exception {
        return AppProcessResult.failure(AppStrings.deleteAccountReauthWarning);
      }
    }

    return _reauthenticateWithPassword();
  }

  /// Reautentica por senha, reabrindo o diálogo em caso de senha errada.
  ///
  /// A senha incorreta mantém o diálogo aberto com o erro exibido
  /// inline; fechar o diálogo devolve [AppProcessResult.canceled].
  Future<AppProcessResult> _reauthenticateWithPassword() async {
    final authService = AuthService();

    var wrongPassword = false;

    while (mounted) {
      final password = await _showPasswordDialog(
        errorMessage: wrongPassword ? AppStrings.wrongPassword : null,
      );
      if (password == null) return const AppProcessResult.canceled();

      try {
        await authService.reauthenticateWithPassword(password);
        return const AppProcessResult.success();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password' ||
            e.code == 'invalid-credential' ||
            e.code == 'invalid-login-credentials') {
          wrongPassword = true;
        } else {
          return AppProcessResult.failure(AppStrings.deleteAccountReauthWarning);
        }
      } on Exception {
        return AppProcessResult.failure(AppStrings.deleteAccountReauthWarning);
      }
    }

    return const AppProcessResult.canceled();
  }

  /// Abre o diálogo de senha e devolve o valor digitado (ou `null`
  /// se o usuário cancelar). Com [errorMessage], exibe o erro
  /// inline sob o campo (ex.: senha incorreta).
  Future<String?> _showPasswordDialog({String? errorMessage}) async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: ThemeColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            AppStrings.deleteAccountPasswordTitle,
            style: ThemeTextStyles.subtitle,
          ),
          content: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.deleteAccountPasswordMessage,
                  style: ThemeTextStyles.body,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: passwordController,
                  hintText: AppStrings.deleteAccountPasswordHint,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  autofocus: true,
                  validator: (value) {
                    if ((value?.trim().isEmpty ?? true)) {
                      return AppStrings.deleteAccountPasswordValidation;
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _submitPassword(
                    dialogContext,
                    formKey,
                    passwordController,
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: ThemeTextStyles.caption.copyWith(
                      color: ThemeColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: ThemeColors.textSecondary,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppStrings.cancel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: ThemeTextStyles.button.copyWith(
                        color: ThemeColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _submitPassword(
                      dialogContext,
                      formKey,
                      passwordController,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: ThemeColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppStrings.deleteAccountContinue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: ThemeTextStyles.button.copyWith(
                        color: ThemeColors.secondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    passwordController.dispose();
    return password;
  }

  /// Valida a senha do diálogo e o fecha devolvendo o valor digitado.
  void _submitPassword(
    BuildContext dialogContext,
    GlobalKey<FormState> formKey,
    TextEditingController passwordController,
  ) {
    if (!formKey.currentState!.validate()) return;
    Navigator.pop(dialogContext, passwordController.text);
  }

  // UI

  // Constrói a tela de dados da conta (loading ou conteúdo).
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppPageLoading(
        title: AppStrings.accountDataTitle,
        wrapInScaffold: true,
      );
    }

    return AppScaffold(
      child: Column(
        children: [

          // CABEÇALHO
          AppPageHeader.title(
            title: AppStrings.accountDataTitle,
            showSearchBar: false,
          ),

          // CONTEÚDO
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              child: Column(
                children: [

                  // SEÇÃO: INFORMAÇÕES PESSOAIS
                  const AppSectionTitle(title: AppStrings.personalInfoSection),

                  const SizedBox(height: 12),

                  AppOptionTile(
                    icon: Icons.person_outline,
                    title: AppStrings.nameLabel,
                    subtitle: _user?.name ?? '',
                    onTap: () => _showDevelopmentMessage(AppStrings.editNameFeature),
                  ),

                  const SizedBox(height: 12),

                  AppOptionTile(
                    icon: Icons.email_outlined,
                    title: AppStrings.email,
                    subtitle: _user?.email ?? '',
                    onTap: () => _showDevelopmentMessage(AppStrings.editEmailFeature),
                  ),

                  const SizedBox(height: 12),

                  AppOptionTile(
                    icon: Icons.phone_outlined,
                    title: AppStrings.phoneLabel,
                    subtitle: _user?.phone ?? '',
                    onTap: () => _showDevelopmentMessage(AppStrings.editPhoneFeature),
                  ),

                  const SizedBox(height: 20),

                  // SEÇÃO: ENDEREÇO
                  const AppSectionTitle(title: AppStrings.addressSection),

                  const SizedBox(height: 12),

                  AppOptionTile(
                    icon: Icons.location_on_outlined,
                    title: AppStrings.addressLabel,
                    subtitle: _user?.city ?? '',
                    onTap: () => _showDevelopmentMessage(AppStrings.editAddressFeature),
                  ),

                  const SizedBox(height: 20),

                  // SEÇÃO: SEGURANÇA
                  const AppSectionTitle(title: AppStrings.securitySection),

                  const SizedBox(height: 12),

                  AppOptionTile(
                    icon: Icons.lock_outline,
                    title: AppStrings.changePassword,
                    onTap: () => _showDevelopmentMessage(AppStrings.changePasswordFeature),
                  ),

                  const SizedBox(height: 32),

                  // SEÇÃO: GERENCIAR CONTA
                  const AppSectionTitle(
                    title: AppStrings.dangerZone,
                    titleColor: ThemeColors.error,
                  ),

                  const SizedBox(height: 12),

                  AppOptionTile(
                    icon: Icons.delete_outline,
                    title: AppStrings.deleteAccount,
                    isDestructive: true,
                    onTap: _isDeleting ? () {} : _onDeleteAccountPressed,
                  ),                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}