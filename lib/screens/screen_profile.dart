import 'dart:io';

import 'package:appets/core/constants/constants_strings_home.dart';
import 'package:appets/core/constants/constants_strings_profile.dart';
import 'package:appets/core/constants/constants_strings_settings.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/navigation/navigation_app.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/image_compressor.dart';
import 'package:appets/core/services/my_publications_service.dart';
import 'package:appets/core/services/storage_service.dart';
import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/user_model.dart';
import 'package:appets/widgets/display/widget_avatar.dart';
import 'package:appets/widgets/display/widget_option_tile.dart';
import 'package:appets/widgets/feedback/widget_dialogs.dart';
import 'package:appets/widgets/feedback/widget_page_states.dart';
import 'package:appets/widgets/feedback/widget_process.dart';
import 'package:appets/widgets/headers/widget_page_header.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Tela de perfil do usuário.
///
/// Exibe avatar, nome e opções de navegação:
/// - Dados da conta
/// - Configurações
/// - Desconectar (com popup de confirmação)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WGProcessMixin<ProfileScreen> {
  UserModel? _user;
  bool _loadError = false;

  // Controlador do image_picker da foto de perfil.
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Carrega os dados do usuário logado do Firestore.
  Future<void> _loadUserData() async {
    try {
      final authUser = AuthService.instance.currentUser;
      if (authUser != null) {
        _user = await FirestoreService.instance.getUser(authUser.uid);
      }
      if (mounted) {
        setState(() => _loadError = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadError = true);
      }
    }
  }

  // Reexecuta a carga após uma falha (botão "Tentar de novo").
  void _retryLoad() {
    setState(() => _loadError = false);
    _loadUserData();
  }

  // ACTIONS

  /// Navega para a tela de configurações.
  void _openSettings() {
    Navigator.pushNamed(context, AppRoutes.settings);
  }

  /// Navega para a tela de dados da conta.
  void _openAccountData() {
    Navigator.pushNamed(context, AppRoutes.accountData);
  }

  /// Exibe popup de confirmação e navega para login ao confirmar.
  ///
  /// Usa [Navigator.pushReplacementNamed] para limpar a pilha
  /// de navegação, impedindo que o volte com o botão voltar.
  void _logout() async {
    final shouldLogout = await WGDialog.showConfirm(
      context,
      title: ProfileStrings.LOGOUT_TITLE,
      message: ProfileStrings.LOGOUT_MESSAGE,
    );

    if (shouldLogout && mounted) {
      try {
        await AuthService.instance.logout();
      } catch (_) {
        // O signOut do Google falhou (ex.: sem rede); o Firebase já saiu
        // no finally do serviço — segue o fluxo de logout normalmente.
      }
      // Limpa a fonte global de favoritos para não vazar dados
      // da conta anterior para a próxima sessão.
      FavoritesService.instance.reset();
      MyPublicationsService.instance.reset();
      AppNavigation.selectedPage.value = AppPage.home;
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  /// Indica se a conta atual pode alterar a foto (e-mail/senha).
  ///
  /// Contas Google usam a foto do provedor e ficam bloqueadas — mesmo
  /// padrão do e-mail em "Dados da conta".
  bool get _canChangeAvatar => AuthService.instance.usesPasswordProvider;

  /// Abre o seletor da foto de perfil (galeria/remover) ou avisa quando a
  /// conta é Google.
  Future<void> _onAvatarTap() async {
    if (!_canChangeAvatar) {
      await WGDialog.showAction(
        context,
        title: ProfileStrings.AVATAR_GOOGLE_TITLE,
        message: ProfileStrings.AVATAR_GOOGLE_MESSAGE,
      );
      return;
    }

    final hasPhoto = (_user?.photoUrl ?? '').isNotEmpty;
    await _showAvatarOptions(hasPhoto: hasPhoto);
  }

  /// Mostra as opções do avatar num painel inferior.
  ///
  /// Cada opção fecha o painel e dispara a ação direto (não depende do
  /// retorno do `showModalBottomSheet`).
  Future<void> _showAvatarOptions({required bool hasPhoto}) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.appColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ProfileStrings.AVATAR_TITLE,
                style: ThemeTextStyles.heading(context.appColors),
              ),
              const SizedBox(height: 20),
              WGOptionTile(
                icon: Icons.photo_library_outlined,
                title: ProfileStrings.AVATAR_GALLERY_OPTION,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _changeAvatarFromGallery();
                },
              ),
              if (hasPhoto) ...[
                const SizedBox(height: 12),
                WGOptionTile(
                  icon: Icons.delete_outline,
                  title: ProfileStrings.AVATAR_REMOVE_OPTION,
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _removeAvatar();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Escolhe uma imagem da galeria e, na tela de processo, comprime, envia e
  /// grava a URL no perfil.
  ///
  /// O picker roda fora do [pushProcess] (é interação do usuário com a
  /// galeria nativa); compressão, upload e gravação rodam na tela de
  /// carregamento, que bloqueia a interface (inclusive as abas) até concluir.
  Future<void> _changeAvatarFromGallery() async {
    final XFile? picked;
    try {
      picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: ImageCompressor.avatarMaxDimension.toDouble(),
        maxHeight: ImageCompressor.avatarMaxDimension.toDouble(),
      );
    } on Exception {
      // Permissão negada ou erro da plataforma: avisa em vez de deixar a
      // exceção escapar sem tratamento.
      if (!mounted) return;
      await _showAvatarMessage(ProfileStrings.AVATAR_PICK_ERROR, isError: true);
      return;
    }

    if (picked == null || !mounted) return;
    // Captura não-nula: a promoção de `picked` não vale dentro do closure
    // da task (o analisador não consegue garantir o nulo lá).
    final image = picked;

    final authUser = AuthService.instance.currentUser;
    if (authUser == null) return;
    final uid = authUser.uid;
    final oldUrl = _user?.photoUrl ?? '';
    String? newUrl;

    final result = await pushProcess(
      message: ProfileStrings.AVATAR_UPLOADING,
      task: () async {
        String? tempPath;
        try {
          // Prefere a versão comprimida; se nada compensar, mantém o original.
          final compressed = await ImageCompressor.compressAvatar(image.path);
          tempPath = compressed?.path;
          newUrl = await StorageService.instance.uploadAvatar(
            uid,
            File(compressed?.path ?? image.path),
          );

          await FirestoreService.instance.updateUser(uid, {'photoUrl': newUrl});

          // Pós-commit e melhor esforço: apaga o avatar antigo sem
          // transformar uma exclusão falha em erro do fluxo.
          if (oldUrl.isNotEmpty && oldUrl != newUrl) {
            try {
              await StorageService.instance.deleteAvatarByUrl(oldUrl);
            } on Exception catch (_) {
              // Melhor esforço: não falha o fluxo se a exclusão antiga der erro.
            }
          }
          return const WGProcessResult.success();
        } on Exception catch (e, s) {
          return WGProcessResult.failure(
            ProfileStrings.AVATAR_UPLOAD_ERROR,
            cause: e,
            stackTrace: s,
          );
        } finally {
          if (tempPath != null) {
            await ImageCompressor.deleteTempWebpFiles([tempPath]);
          }
        }
      },
    );
    if (!mounted) return;

    switch (result?.status) {
      case WGProcessStatus.success:
        if (_user == null) {
          await _loadUserData();
        } else {
          setState(() => _user = _user!.copyWith(photoUrl: newUrl));
        }
        if (!mounted) return;
        await _showAvatarMessage(ProfileStrings.AVATAR_SUCCESS);
      case WGProcessStatus.failure:
        await _showAvatarMessage(result!.userFacingMessage, isError: true);
      case WGProcessStatus.canceled:
      case null:
        break;
    }
  }

  /// Confirma e remove a foto de perfil atual na tela de processo.
  Future<void> _removeAvatar() async {
    final confirmed = await WGDialog.showConfirm(
      context,
      title: ProfileStrings.AVATAR_REMOVE_TITLE,
      message: ProfileStrings.AVATAR_REMOVE_MESSAGE,
    );
    if (!confirmed || !mounted) return;

    final authUser = AuthService.instance.currentUser;
    final user = _user;
    if (authUser == null || user == null) return;
    final uid = authUser.uid;
    final oldUrl = user.photoUrl;

    final result = await pushProcess(
      message: ProfileStrings.AVATAR_REMOVING,
      task: () async {
        try {
          await FirestoreService.instance.updateUser(uid, {'photoUrl': ''});

          // Pós-commit e melhor esforço: apaga o arquivo do avatar.
          if (oldUrl.isNotEmpty) {
            try {
              await StorageService.instance.deleteAvatarByUrl(oldUrl);
            } on Exception catch (_) {
              // Melhor esforço: não falha o fluxo se a exclusão der erro.
            }
          }
          return const WGProcessResult.success();
        } on Exception catch (e, s) {
          return WGProcessResult.failure(
            ProfileStrings.AVATAR_UPLOAD_ERROR,
            cause: e,
            stackTrace: s,
          );
        }
      },
    );
    if (!mounted) return;

    switch (result?.status) {
      case WGProcessStatus.success:
        setState(() => _user = user.copyWith(photoUrl: ''));
        await _showAvatarMessage(ProfileStrings.AVATAR_REMOVE_SUCCESS);
      case WGProcessStatus.failure:
        await _showAvatarMessage(result!.userFacingMessage, isError: true);
      case WGProcessStatus.canceled:
      case null:
        break;
    }
  }

  /// Mostra um aviso (sucesso ou erro) do fluxo do avatar.
  ///
  /// No erro, [isError] pinta a ação com a cor de destaque negativa.
  Future<void> _showAvatarMessage(String message, {bool isError = false}) {
    if (!mounted) return Future.value();
    return WGDialog.showAction(
      context,
      title: isError ? SharedStrings.ERROR_TITLE : SharedStrings.SUCCESS_TITLE,
      message: message,
      actionColor: isError ? context.appColors.error : null,
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // CABEÇALHO
        WGPageHeader.title(
          title: ProfileStrings.PROFILE_TITLE,
          showSearchBar: false,
        ),

        // CONTEÚDO
        Expanded(
          child: _loadError
              ? WGErrorState(
                  title: SharedStrings.LOAD_DATA_ERROR_TITLE,
                  onAction: _retryLoad,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
                  child: Column(
                    children: [
                      // AVATAR
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          WGAvatar(
                            radius: 45,
                            imageUrl: _user?.photoUrl,
                            borderColor: context.appColors.primary,
                            shadowColor: context.appColors.shadowButton,
                          ),

                          // BOTÃO FLUTUANTE PARA ALTERAR O AVATAR
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: _ProfileEditBadge(onTap: _onAvatarTap),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // NOME
                      Text(
                        _user?.name ??
                            AuthService.instance.currentUser?.displayName ??
                            HomeStrings.DEFAULT_USER_NAME,
                        style: ThemeTextStyles.heading(context.appColors),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 40),

                      // OPÇÕES
                      WGOptionTile(
                        icon: Icons.person_outline,
                        title: ProfileStrings.ACCOUNT_DATA_TITLE,
                        filled: false,
                        onTap: _openAccountData,
                      ),

                      const SizedBox(height: 12),

                      WGOptionTile(
                        icon: Icons.settings_outlined,
                        title: SettingsStrings.SETTINGS_TITLE,
                        filled: false,
                        onTap: _openSettings,
                      ),

                      const SizedBox(height: 12),

                      WGOptionTile(
                        icon: Icons.logout,
                        title: ProfileStrings.LOGOUT_OPTION,
                        isDestructive: true,
                        filled: false,
                        onTap: _logout,
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

/// Botão circular de edição (lápis) usado no avatar e ao lado do nome.
///
/// Padronizado com fundo primário, borda branca de destaque e sombra.
class _ProfileEditBadge extends StatelessWidget {
  const _ProfileEditBadge({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: context.appColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: context.appColors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: context.appColors.shadowButton,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          Icons.edit,
          color: context.appColors.onPrimary,
          size: 16,
        ),
      ),
    );
  }
}
