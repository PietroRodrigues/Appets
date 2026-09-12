import 'package:appets/core/constants/constants_strings_auth.dart';
import 'package:appets/core/constants/constants_strings_delete_account.dart';
import 'package:appets/core/constants/constants_strings_profile.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/services/my_publications_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/core/services/storage_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/validators/validators.dart';
import 'package:appets/models/user_model.dart';
import 'package:appets/widgets/buttons/widget_buttons.dart';
import 'package:appets/widgets/display/widget_option_tile.dart';
import 'package:appets/widgets/feedback/widget_dialogs.dart';
import 'package:appets/widgets/feedback/widget_page_states.dart';
import 'package:appets/widgets/feedback/widget_process.dart';
import 'package:appets/widgets/fields/widget_editable_tile.dart';
import 'package:appets/widgets/headers/widget_page_header.dart';
import 'package:appets/widgets/layout/widget_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Tela de dados da conta do usuário.
///
/// Acessada a partir da tela de perfil, permite ao usuário
/// visualizar e editar suas informações pessoais, endereço
/// e configurações de segurança da conta.
class AccountDataScreen extends StatefulWidget {
  const AccountDataScreen({super.key});

  @override
  State<AccountDataScreen> createState() => _AccountDataScreenState();
}

class _AccountDataScreenState extends State<AccountDataScreen> {
  UserModel? _user;
  bool _isLoading = true;
  bool _isDeleting = false;
  bool _isSaving = false;

  // Rascunhos editáveis (valores ainda não salvos no Firestore).
  String _draftName = '';
  String _draftEmail = '';
  String _draftPhone = '';
  String _draftAddress = '';

  // Campo atualmente em edição (apenas um por vez).
  String? _editingField;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Carrega os dados do usuário logado do Firestore.
  Future<void> _loadUserData() async {
    final authUser = AuthService.instance.currentUser;
    if (authUser != null) {
      _user = await FirestoreService.instance.getUser(authUser.uid);
      if (_user != null) {
        _syncDraftsFromUser();
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _syncDraftsFromUser() {
    _draftName = _user?.name ?? '';
    _draftEmail = _user?.email ?? '';
    _draftPhone = _user?.phone ?? '';
    _draftAddress = _user?.address ?? '';
  }

  // Indica se há alterações não salvas em relação ao Firestore.
  bool get _hasUnsavedChanges {
    if (_user == null) return false;
    return _draftName != _user!.name ||
        _draftEmail != _user!.email ||
        _draftPhone != _user!.phone ||
        _draftAddress != _user!.address;
  }

  // ACTIONS

  /// Exibe aviso de recurso em desenvolvimento.
  void _showDevelopmentMessage(String feature) {
    WGDialog.showAction(
      context,
      title: SharedStrings.DEVELOPMENT_TITLE,
      message: SharedStrings.featureInDevelopment(feature),
    );
  }

  // Superfície para edição inline do tile indicado.
  void _startEditing(String field) {
    setState(() {
      _editingField = field;
    });
  }

  // Grava o valor localmente ao confirmar a edição do campo.
  void _commitField(String field, String value) {
    setState(() {
      _editingField = null;
      switch (field) {
        case 'name':
          _draftName = value;
          break;
        case 'email':
          _draftEmail = value;
          break;
        case 'phone':
          _draftPhone = value;
          break;
        case 'address':
          _draftAddress = value;
          break;
      }
    });
  }

  /// Salva os rascunhos no Firestore e atualiza o estado.
  Future<void> _saveChanges() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    FocusManager.instance.primaryFocus?.unfocus();
    _editingField = null;

    final authUser = AuthService.instance.currentUser;
    final uid = authUser?.uid ?? _user?.id;
    if (uid == null) {
      setState(() => _isSaving = false);
      WGDialog.showAction(
        context,
        title: SharedStrings.ERROR_TITLE,
        message: ProfileStrings.CONTACT_SAVE_ERROR,
        actionColor: ThemeColors.error,
      );
      return;
    }

    // Valida o celular antes de salvar (regra "só celular/WhatsApp").
    final phoneError = AppValidators.validateCellPhone(_draftPhone);
    if (phoneError != null) {
      setState(() {
        _isSaving = false;
        _editingField = 'phone';
      });
      WGDialog.showAction(
        context,
        title: SharedStrings.ERROR_TITLE,
        message: phoneError,
        actionColor: ThemeColors.error,
      );
      return;
    }

    try {
      // Captura antes da atualização local: a base para detectar se o
      // telefone mudou é o valor antigo do Firestore.
      final phoneChanged = _draftPhone.trim() != _user!.phone;

      await FirestoreService.instance.updateUser(uid, {
        'name': _draftName.trim(),
        'email': _draftEmail.trim(),
        'phone': _draftPhone.trim(),
        'address': _draftAddress.trim(),
      });

      // Atualiza o modelo local (evita nova busca) e redefine rascunhos.
      setState(() {
        _user = UserModel(
          id: _user!.id,
          name: _draftName.trim(),
          email: _draftEmail.trim(),
          phone: _draftPhone.trim(),
          address: _draftAddress.trim(),
          photoUrl: _user!.photoUrl,
          favoritePetIds: _user!.favoritePetIds,
        );
        _isSaving = false;
      });

      if (mounted) {
        WGDialog.showAction(
          context,
          title: SharedStrings.SUCCESS_TITLE,
          message: ProfileStrings.CONTACT_SAVED,
        );
      }

      // Telefone alterado -> pergunta se propaga para todas as publicações.
      if (phoneChanged && mounted) {
        final newPhone = _draftPhone.trim();
        final shouldUpdate = await WGDialog.showConfirm(
          context,
          title: ProfileStrings.UPDATE_CONTACT_TITLE,
          message: ProfileStrings.updatePublicationsMessage(newPhone),
          messageHighlight: newPhone,
        );

        if (shouldUpdate && mounted) {
          try {
            await PetService.instance.updateOwnerPhone(uid, newPhone);
            if (mounted) {
              WGDialog.showAction(
                context,
                title: SharedStrings.SUCCESS_TITLE,
                message: ProfileStrings.UPDATE_CONTACT_UPDATED,
              );
            }
          } catch (_) {
            if (mounted) {
              WGDialog.showAction(
                context,
                title: SharedStrings.ERROR_TITLE,
                message: ProfileStrings.CONTACT_SAVE_ERROR,
                actionColor: ThemeColors.error,
              );
            }
          }
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        WGDialog.showAction(
          context,
          title: SharedStrings.ERROR_TITLE,
          message: ProfileStrings.CONTACT_SAVE_ERROR,
          actionColor: ThemeColors.error,
        );
      }
    }
  }

  // Intercepta o botão voltar: com alterações não salvas, pergunta antes.
  Future<void> _onPopInvokedWithResult(bool didPop, Object? result) async {
    if (didPop) return;

    if (!_hasUnsavedChanges) {
      Navigator.pop(context);
      return;
    }

    final shouldDiscard = await WGDialog.showConfirm(
      context,
      title: ProfileStrings.DISCARD_CHANGES_TITLE,
      message: ProfileStrings.DISCARD_CHANGES_MESSAGE,
    );

    if (shouldDiscard && mounted) {
      // Restaura os valores originais e volta.
      _syncDraftsFromUser();
      Navigator.pop(context);
    }
  }

  /// Fluxo de confirmação em duas etapas e exclusão com tela de carregamento.
  void _onDeleteAccountPressed() async {
    final firstConfirmed = await WGDialog.showConfirm(
      context,
      title: DeleteAccountStrings.DELETE_ACCOUNT_TITLE,
      message: DeleteAccountStrings.DELETE_ACCOUNT_CONFIRM_MESSAGE,
    );

    if (!firstConfirmed || !mounted) return;

    final finalConfirmed = await WGDialog.showConfirm(
      context,
      title: DeleteAccountStrings.DELETE_ACCOUNT_FINAL_TITLE,
      message: DeleteAccountStrings.DELETE_ACCOUNT_FINAL_MESSAGE,
      messageHighlight: DeleteAccountStrings.DELETE_PERMANENTLY_HIGHLIGHT,
    );

    if (!finalConfirmed || !mounted) return;

    setState(() => _isDeleting = true);
    FocusManager.instance.primaryFocus?.unfocus();

    final result = await Navigator.push<WGProcessResult>(
      context,
      MaterialPageRoute<WGProcessResult>(
        builder: (_) => WGProcessLoadingScreen(
          message: DeleteAccountStrings.DELETE_ACCOUNT_LOADING,
          task: _deleteAccountTask,
        ),
      ),
    );

    if (!mounted) return;
    setState(() => _isDeleting = false);

    switch (result?.status) {
      case WGProcessStatus.success:
        if (mounted) {
          await WGDialog.showAction(
            context,
            title: SharedStrings.SUCCESS_TITLE,
            message: DeleteAccountStrings.ACCOUNT_DELETED,
          );
        }
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      case WGProcessStatus.failure:
        if (mounted) {
          await WGDialog.showAction(
            context,
            title: SharedStrings.ERROR_TITLE,
            message:
                result?.message ?? DeleteAccountStrings.DELETE_ACCOUNT_ERROR,
            actionColor: ThemeColors.error,
          );
        }
      case WGProcessStatus.canceled:
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
  Future<WGProcessResult> _deleteAccountTask() async {
    final authService = AuthService.instance;
    final user = authService.currentUser;

    if (user == null) {
      return WGProcessResult.failure(DeleteAccountStrings.DELETE_ACCOUNT_ERROR);
    }

    final uid = user.uid;

    try {
      // 0. Sessão antiga exige reautenticação antes de apagar dados.
      //    Antecipar o reauth evita apagar a base e, em seguida, o
      //    usuário cancelar o reauth (conta viva sem dados).
      if (!_isSessionRecent(user)) {
        final reauth = await _reauthenticate();
        if (reauth.status != WGProcessStatus.success) {
          return reauth;
        }
      }

      // 1. Apaga os dados do usuário enquanto a credencial é válida:
      //    pets (imagens no Storage + documentos) e documento do usuário.
      //    Se a limpeza falhar, aborta ANTES de excluir a conta no Auth
      //    para nunca deixar pets órfãos.
      final dataDeleted = await _deleteUserData(uid);
      if (!dataDeleted) {
        return WGProcessResult.failure(
          DeleteAccountStrings.DELETE_ACCOUNT_DATA_ERROR,
        );
      }

      // 2. Exclui a conta no Firebase Auth por último.
      final deletion = await _deleteAuthAccount(authService);
      if (deletion.status != WGProcessStatus.success) {
        return deletion;
      }

      // 3. Garante que o aparelho fique deslogado.
      try {
        await authService.logout();
      } catch (_) {
        // Ignora falha no logout; a conta já foi excluída.
      }

      // Limpa a fonte global de favoritos da conta excluída.
      FavoritesService.instance.reset();
      MyPublicationsService.instance.reset();

      return const WGProcessResult.success();
    } catch (_) {
      return WGProcessResult.failure(DeleteAccountStrings.DELETE_ACCOUNT_ERROR);
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
  /// (imagens e documentos) e o documento do usuário.
  ///
  /// Imagens no Storage são apagadas em modo "melhor esforço": se o
  /// Storage não estiver configurado ou uma imagem falhar, o fluxo
  /// continua (cada falha é ignorada internamente). Já os documentos
  /// (pets e usuário) são obrigatórios — se algum não puder ser
  /// removido, devolve `false` para que a exclusão da conta seja
  /// abortada e nenhum pet fique órfão.
  Future<bool> _deleteUserData(String uid) async {
    try {
      final petService = PetService.instance;
      final storageService = StorageService.instance;
      final myPets = await petService.getPetsByOwner(uid);
      for (final pet in myPets) {
        if (pet.images.isNotEmpty) {
          await storageService.deletePetImages(pet.id, pet.images.length);
        }
        await petService.deletePet(pet.id);
      }
    } catch (_) {
      return false;
    }

    try {
      await FirestoreService.instance.deleteUser(uid);
    } catch (_) {
      return false;
    }
    return true;
  }

  /// Exclui a conta no Firebase Auth, reautenticando o usuário
  /// quando o login não for recente.
  ///
  /// Devolve [WGProcessResult.canceled] se a reautenticação for
  /// cancelada (exclusão abortada) ou [WGProcessResult.success]
  /// quando a conta foi excluída.
  Future<WGProcessResult> _deleteAuthAccount(AuthService authService) async {
    try {
      await authService.deleteAccount();
      return const WGProcessResult.success();
    } on FirebaseAuthException catch (e) {
      if (e.code != 'requires-recent-login') {
        return WGProcessResult.failure(
          DeleteAccountStrings.DELETE_ACCOUNT_ERROR,
        );
      }

      final reauth = await _reauthenticate();
      if (reauth.status != WGProcessStatus.success) {
        return reauth;
      }

      try {
        await authService.deleteAccount();
        return const WGProcessResult.success();
      } on Exception {
        return WGProcessResult.failure(
          DeleteAccountStrings.DELETE_ACCOUNT_ERROR,
        );
      }
    }
  }

  /// Reautentica o usuário conforme o provedor da conta:
  /// Google ou e-mail/senha.
  Future<WGProcessResult> _reauthenticate() async {
    final authService = AuthService.instance;

    if (authService.usesGoogleProvider) {
      try {
        final ok = await authService.reauthenticateWithGoogle();
        return ok
            ? const WGProcessResult.success()
            : const WGProcessResult.canceled();
      } on Exception {
        return WGProcessResult.failure(
          DeleteAccountStrings.DELETE_ACCOUNT_REAUTH_WARNING,
        );
      }
    }

    return _reauthenticateWithPassword();
  }

  /// Reautentica por senha, reabrindo o diálogo em caso de senha errada.
  ///
  /// A senha incorreta mantém o diálogo aberto com o erro exibido
  /// inline; fechar o diálogo devolve [WGProcessResult.canceled].
  Future<WGProcessResult> _reauthenticateWithPassword() async {
    final authService = AuthService.instance;

    var wrongPassword = false;

    while (mounted) {
      final password = await _showPasswordDialog(
        errorMessage: wrongPassword
            ? DeleteAccountStrings.WRONG_PASSWORD
            : null,
      );
      if (password == null) return const WGProcessResult.canceled();

      try {
        await authService.reauthenticateWithPassword(password);
        return const WGProcessResult.success();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password' ||
            e.code == 'invalid-credential' ||
            e.code == 'invalid-login-credentials') {
          wrongPassword = true;
        } else {
          return WGProcessResult.failure(
            DeleteAccountStrings.DELETE_ACCOUNT_REAUTH_WARNING,
          );
        }
      } on Exception {
        return WGProcessResult.failure(
          DeleteAccountStrings.DELETE_ACCOUNT_REAUTH_WARNING,
        );
      }
    }

    return const WGProcessResult.canceled();
  }

  /// Abre o diálogo de senha e devolve o valor digitado (ou `null`
  /// se o usuário cancelar). Com [errorMessage], exibe o erro
  /// inline sob o campo (ex.: senha incorreta).
  Future<String?> _showPasswordDialog({String? errorMessage}) async {
    return WGDialog.showInput(
      context,
      title: DeleteAccountStrings.DELETE_ACCOUNT_PASSWORD_TITLE,
      message: DeleteAccountStrings.DELETE_ACCOUNT_PASSWORD_MESSAGE,
      hintText: DeleteAccountStrings.DELETE_ACCOUNT_PASSWORD_HINT,
      prefixIcon: Icons.lock_outline,
      obscureText: true,
      validator: (value) {
        if ((value?.trim().isEmpty ?? true)) {
          return DeleteAccountStrings.DELETE_ACCOUNT_PASSWORD_VALIDATION;
        }
        return null;
      },
      errorMessage: errorMessage,
    );
  }

  // UI

  // Constrói a tela de dados da conta (loading ou conteúdo).
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const WGPageLoading(
        title: ProfileStrings.ACCOUNT_DATA_TITLE,
        wrapInScaffold: true,
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      child: WGScaffold(
        child: Column(
          children: [
            // CABEÇALHO
            WGPageHeader.title(
              title: ProfileStrings.ACCOUNT_DATA_TITLE,
              showSearchBar: false,
            ),

            // CONTEÚDO
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
                child: Column(
                  children: [
                    // SEÇÃO: INFORMAÇÕES PESSOAIS
                    const WGSectionTitle(
                      title: ProfileStrings.PERSONAL_INFO_SECTION,
                    ),

                    const SizedBox(height: 12),

                    WGEditableTile(
                      icon: Icons.person_outline,
                      title: ProfileStrings.NAME_LABEL,
                      initialValue: _user?.name ?? '',
                      committedValue: _draftName,
                      isEditing: _editingField == 'name',
                      onStartEditing: () => _startEditing('name'),
                      onCommit: (v) => _commitField('name', v),
                    ),

                    const SizedBox(height: 12),

                    WGEditableTile(
                      icon: Icons.email_outlined,
                      title: AuthStrings.EMAIL,
                      initialValue: _user?.email ?? '',
                      committedValue: _draftEmail,
                      isEditing: _editingField == 'email',
                      onStartEditing: () => _startEditing('email'),
                      onCommit: (v) => _commitField('email', v),
                      keyboardType: TextInputType.emailAddress,
                      validator: AppValidators.validateEmail,
                    ),

                    const SizedBox(height: 12),

                    WGEditableTile(
                      icon: Icons.phone_outlined,
                      title: ProfileStrings.PHONE_LABEL,
                      initialValue: _user?.phone ?? '',
                      committedValue: _draftPhone,
                      isEditing: _editingField == 'phone',
                      onStartEditing: () => _startEditing('phone'),
                      onCommit: (v) => _commitField('phone', v),
                      phone: true,
                      validator: AppValidators.validateCellPhone,
                    ),

                    const SizedBox(height: 20),

                    // SEÇÃO: ENDEREÇO
                    const WGSectionTitle(title: ProfileStrings.ADDRESS_SECTION),

                    const SizedBox(height: 12),

                    WGEditableTile(
                      icon: Icons.location_on_outlined,
                      title: ProfileStrings.ADDRESS_LABEL,
                      initialValue: _user?.address ?? '',
                      committedValue: _draftAddress,
                      isEditing: _editingField == 'address',
                      onStartEditing: () => _startEditing('address'),
                      onCommit: (v) => _commitField('address', v),
                    ),

                    const SizedBox(height: 20),

                    // SEÇÃO: SEGURANÇA
                    const WGSectionTitle(
                      title: ProfileStrings.SECURITY_SECTION,
                    ),

                    const SizedBox(height: 12),

                    WGOptionTile(
                      icon: Icons.lock_outline,
                      title: ProfileStrings.CHANGE_PASSWORD,
                      onTap: () => _showDevelopmentMessage(
                        ProfileStrings.CHANGE_PASSWORD_FEATURE,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // BOTÃO DE SALVAR (verde) — envia as alterações ao Firebase
                    WGButton(
                      text: ProfileStrings.SAVE_CONTACT,
                      onPressed: _isSaving ? () {} : _saveChanges,
                      height: 50,
                      backgroundColor: ThemeColors.success,
                      foregroundColor: ThemeColors.white,
                    ),

                    const SizedBox(height: 24),

                    // SEÇÃO: GERENCIAR CONTA
                    const WGSectionTitle(
                      title: ProfileStrings.DANGER_ZONE,
                      titleColor: ThemeColors.error,
                    ),

                    const SizedBox(height: 12),

                    WGOptionTile(
                      icon: Icons.delete_outline,
                      title: DeleteAccountStrings.DELETE_ACCOUNT,
                      isDestructive: true,
                      onTap: _isDeleting ? () {} : _onDeleteAccountPressed,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
