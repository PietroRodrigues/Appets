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
import 'package:appets/widgets/common/buttons/widget_button.dart';
import 'package:appets/widgets/common/display/widget_option_tile.dart';
import 'package:appets/widgets/common/feedback/widget_confirm_dialog.dart';
import 'package:appets/widgets/common/feedback/widget_page_loading.dart';
import 'package:appets/widgets/common/feedback/widget_snack_bar.dart';
import 'package:appets/widgets/common/fields/widget_text_field.dart';
import 'package:appets/widgets/common/layout/widget_scaffold.dart';
import 'package:appets/widgets/common/layout/widget_section_title.dart';
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

  /// Exibe uma mensagem na tela.
  void _showSnackBar(String message) {
    AppSnackBar.show(context, message);
  }

  /// Exibe aviso de recurso em desenvolvimento.
  void _showDevelopmentMessage(String feature) {
    AppSnackBar.development(context, feature);
  }

  /// Fluxo de confirmação em duas etapas antes da exclusão da conta.
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
      confirmLabel: AppStrings.deletePermanently,
      cancelLabel: AppStrings.cancel,
    );

    if (!finalConfirmed || !mounted) return;

    await _deleteAccount();
  }

  /// Exclui todos os dados da conta: pets publicados (Firestore + Storage),
  /// documento do usuário no Firestore e a conta no Firebase Auth.
  Future<void> _deleteAccount() async {
    setState(() => _isDeleting = true);

    final authService = AuthService();
    final user = authService.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() => _isDeleting = false);
        _showSnackBar(AppStrings.deleteAccountError);
      }
      return;
    }

    try {
      // 1. Apaga pets do usuário (documentos + imagens no Storage).
      try {
        final petService = PetService();
        final storageService = StorageService();
        final myPets = await petService.getPetsByOwner(user.uid);
        for (final pet in myPets) {
          if (pet.images.isNotEmpty) {
            await storageService.deletePetImages(pet.id, pet.images.length);
          }
          await petService.deletePet(pet.id);
        }
      } catch (_) {
        // Continua mesmo se algum pet falhar.
      }

      // 2. Apaga o documento do usuário no Firestore.
      await FirestoreService().deleteUser(user.uid);

      // 3. Apaga a conta no Firebase Auth.
      try {
        await authService.deleteAccount();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          final reauthenticated = await _reauthenticate();
          if (!reauthenticated) return;
          await authService.deleteAccount();
        } else {
          rethrow;
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isDeleting = false);
        _showSnackBar(AppStrings.deleteAccountError);
      }
      return;
    }

    if (!mounted) return;

    setState(() => _isDeleting = false);
    _showSnackBar(AppStrings.accountDeleted);
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  /// Reautentica o usuário pedindo a senha (exigido pelo Firebase
  /// para excluir conta quando o login não é recente).
  Future<bool> _reauthenticate() async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    var reauthenticated = false;

    while (!reauthenticated) {
      if (!mounted) break;

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
                    onFieldSubmitted: (_) => _confirmReauthPassword(
                      dialogContext,
                      formKey,
                      passwordController,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(AppStrings.cancel),
              ),
              TextButton(
                onPressed: () => _confirmReauthPassword(
                  dialogContext,
                  formKey,
                  passwordController,
                ),
                child: const Text(
                  AppStrings.deleteAccountContinue,
                  style: TextStyle(color: ThemeColors.primary),
                ),
              ),
            ],
          );
        },
      );

      if (password == null) {
        break;
      }

      try {
        await AuthService().reauthenticateWithPassword(password);
        reauthenticated = true;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password' ||
            e.code == 'invalid-credential' ||
            e.code == 'invalid-login-credentials') {
          if (mounted) {
            _showSnackBar(AppStrings.wrongPassword);
          }
        } else {
          if (mounted) {
            _showSnackBar(AppStrings.deleteAccountReauthWarning);
          }
          break;
        }
      } catch (_) {
        if (mounted) {
          _showSnackBar(AppStrings.deleteAccountReauthWarning);
        }
        break;
      }
    }

    passwordController.dispose();
    return reauthenticated;
  }

  // Valida a senha do diálogo e o fecha devolvendo o valor informado.
  void _confirmReauthPassword(
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

                  // SEÇÃO: ZONA DE PERIGO
                  const AppSectionTitle(
                    title: AppStrings.dangerZone,
                    titleColor: ThemeColors.error,
                  ),

                  const SizedBox(height: 12),

                  AppButton(
                    text: AppStrings.deleteAccount,
                    onPressed: _isDeleting ? null : _onDeleteAccountPressed,
                    isLoading: _isDeleting,
                    backgroundColor: ThemeColors.error,
                  ),                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}