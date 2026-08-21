import 'package:flutter/material.dart';

import 'package:appets/widgets/common/display/widget_option_tile.dart';
import 'package:appets/widgets/common/layout/widget_scaffold.dart';
import 'package:appets/widgets/common/layout/widget_section_title.dart';
import 'package:appets/widgets/main/widget_page_header.dart';

/// Tela de configurações do aplicativo.
///
/// Acessada a partir da tela de perfil, permite ao usuário
/// configurar notificações, privacidade e idioma do app.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
  });


  // ACTIONS
  /// Exibe aviso de recurso em desenvolvimento.
  void _showDevelopmentMessage(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature em desenvolvimento'),
      ),
    );
  }


  // UI
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Column(
        children: [

          // CABEÇALHO
          AppPageHeader.title(
            title: 'Configurações',
            showSearchBar: false,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              child: Column(
                children: [

                  // SEÇÃO: NOTIFICAÇÕES
                  const AppSectionTitle(title: 'Notificações'),

                  const SizedBox(height: 12),

                  AppOptionTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notificações push',
                    subtitle: 'Receber alertas de novos pets e mensagens',
                    onTap: () => _showDevelopmentMessage(
                      context,
                      'Configurações de notificações',
                    ),
                  ),

                  const SizedBox(height: 20),


                  // SEÇÃO: PRIVACIDADE
                  const AppSectionTitle(title: 'Privacidade'),

                  const SizedBox(height: 12),

                  AppOptionTile(
                    icon: Icons.visibility_outlined,
                    title: 'Visibilidade do perfil',
                    subtitle: 'Controlar quem pode ver seu perfil',
                    onTap: () => _showDevelopmentMessage(
                      context,
                      'Configurações de privacidade',
                    ),
                  ),

                  const SizedBox(height: 12),

                  AppOptionTile(
                    icon: Icons.location_on_outlined,
                    title: 'Compartilhar localização',
                    subtitle: 'Permitir acesso à sua localização',
                    onTap: () => _showDevelopmentMessage(
                      context,
                      'Configurações de privacidade',
                    ),
                  ),

                  const SizedBox(height: 20),


                  // SEÇÃO: GERAL
                  const AppSectionTitle(title: 'Geral'),

                  const SizedBox(height: 12),

                  AppOptionTile(
                    icon: Icons.language_outlined,
                    title: 'Idioma',
                    subtitle: 'Português (Brasil)',
                    onTap: () => _showDevelopmentMessage(
                      context,
                      'Configurações de idioma',
                    ),
                  ),

                  const SizedBox(height: 12),

                  AppOptionTile(
                    icon: Icons.info_outline,
                    title: 'Sobre o APPets',
                    subtitle: 'Versão 1.0.0',
                    onTap: () => _showDevelopmentMessage(
                      context,
                      'Sobre o app',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
