import 'package:flutter/material.dart';

import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/common/display/widget_avatar.dart';
import 'package:appets/widgets/common/feedback/widget_confirm_dialog.dart';
import 'package:appets/widgets/common/display/widget_option_tile.dart';
import 'package:appets/widgets/main/widget_page_header.dart';

/// Tela de perfil do usuário.
///
/// Exibe avatar, nome e opções de navegação:
/// - Dados da conta
/// - Configurações
/// - Desconectar (com popup de confirmação)
class ProfileScreen extends StatelessWidget {

  const ProfileScreen({
    super.key,
  });


  // ACTIONS
  /// Navega para a tela de configurações.
  void _openSettings(BuildContext context) {

    Navigator.pushNamed(context, AppRoutes.settings);

  }

  /// Navega para a tela de dados da conta.
  void _openAccountData(BuildContext context) {

    Navigator.pushNamed(context, AppRoutes.accountData);

  }

  /// Exibe popup de confirmação e navega para login ao confirmar.
  ///
  /// Usa [Navigator.pushReplacementNamed] para limpar a pilha
  /// de navegação, impedindo que o volte com o botão voltar.
  void _logout(BuildContext context) async {

    final shouldLogout = await AppConfirmDialog.show(
      context,
      title: 'Desconectar?',
      message: 'Deseja realmente sair da sua conta?',
      confirmLabel: 'Sim, sair',
    );

    if (shouldLogout && context.mounted) {
      // TODO:
      // Implementar logout através do Firebase Authentication.

      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }

  }


  // UI
  @override
  Widget build(BuildContext context) {

    return Column(

      children: [


        // CABEÇALHO
        AppPageHeader.title(
          title: 'Meu Perfil',
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
                WidgetAvatar(
                  radius: 70,
                ),

                const SizedBox(height: 14),


                // NOME
                Text(

                  'Pietro',

                  style: ThemeTextStyles.heading,

                ),
                const SizedBox(height: 64),


                // OPÇÕES
                AppOptionTile(

                  icon: Icons.person_outline,

                  title: 'Dados da conta',

                  filled: false,

                  onTap: () => _openAccountData(context),

                ),

                const SizedBox(height: 12),

                AppOptionTile(

                  icon: Icons.settings_outlined,

                  title: 'Configurações',

                  filled: false,

                  onTap: () => _openSettings(context),

                ),

                const SizedBox(height: 12),

                AppOptionTile(

                  icon: Icons.logout,

                  title: 'Desconectar',
                  isDestructive: true,
                  filled: false,

                  onTap: () => _logout(context),

                ),

              ],

            ),

          ),

        ),

      ],

    );

  }

}
