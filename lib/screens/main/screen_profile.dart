import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/navigation/navigation_app.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/user_model.dart';
import 'package:appets/widgets/common/display/widget_display.dart';
import 'package:appets/widgets/common/feedback/widget_confirm_dialog.dart';
import 'package:appets/widgets/common/feedback/widget_snack_bar.dart';
import 'package:appets/widgets/main/widget_page_header.dart';

/// Tela de perfil do usuário.
///
/// Exibe avatar, nome e opções de navegação:
/// - Dados da conta
/// - Configurações
/// - Desconectar (com popup de confirmação)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;

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
      setState(() {});
    }
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
    final shouldLogout = await AppConfirmDialog.show(
      context,
      title: AppStrings.logoutTitle,
      message: AppStrings.logoutMessage,
      confirmLabel: AppStrings.logoutConfirm,
    );

    if (shouldLogout && mounted) {
      await AuthService().logout();
      // Limpa a fonte global de favoritos para não vazar dados
      // da conta anterior para a próxima sessão.
      FavoritesService.instance.reset();
      AppNavigation.selectedPage.value = AppPage.home;
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  /// Exibe aviso de recurso em desenvolvimento (troca de avatar).
  void _showAvatarInDevelopment() {
    AppSnackBar.development(context, AppStrings.changeAvatarFeature);
  }

  /// Exibe aviso de recurso em desenvolvimento (edição de nome).
  void _showEditNameInDevelopment() {
    AppSnackBar.development(context, AppStrings.editNameFeature);
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // CABEÇALHO
        AppPageHeader.title(
          title: AppStrings.profileTitle,
          showSearchBar: false,
        ),

        // CONTEÚDO
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              28,
              20,
              40,
            ),
            child: Column(
              children: [
                // AVATAR
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AppAvatar(
                      radius: 45,
                      imageUrl: _user?.photoUrl,
                      borderColor: ThemeColors.primary,
                      borderWidth: 3,
                      shadowColor: ThemeColors.black.withValues(alpha: 0.25),
                      shadowBlurRadius: 8,
                    ),

                    // BOTÃO FLUTUANTE PARA ALTERAR O AVATAR
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: _ProfileEditBadge(
                        onTap: _showAvatarInDevelopment,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // NOME COM BOTÃO DE EDIÇÃO
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        _user?.name ??
                            AuthService().currentUser?.displayName ??
                            AppStrings.defaultUserName,
                        style: ThemeTextStyles.heading,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _ProfileEditBadge(
                      onTap: _showEditNameInDevelopment,
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // OPÇÕES
                AppOptionTile(
                  icon: Icons.person_outline,
                  title: AppStrings.accountDataTitle,
                  filled: false,
                  onTap: _openAccountData,
                ),

                const SizedBox(height: 12),

                AppOptionTile(
                  icon: Icons.settings_outlined,
                  title: AppStrings.settingsTitle,
                  filled: false,
                  onTap: _openSettings,
                ),

                const SizedBox(height: 12),

                AppOptionTile(
                  icon: Icons.logout,
                  title: AppStrings.logoutOption,
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
  const _ProfileEditBadge({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: ThemeColors.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: ThemeColors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.black.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.edit,
          color: ThemeColors.white,
          size: 16,
        ),
      ),
    );
  }
}