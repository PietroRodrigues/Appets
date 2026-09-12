import 'package:appets/core/constants/constants_strings_settings.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/widgets/display/widget_option_tile.dart';
import 'package:appets/widgets/feedback/widget_dialogs.dart';
import 'package:appets/widgets/headers/widget_page_header.dart';
import 'package:appets/widgets/layout/widget_layout.dart';
import 'package:flutter/material.dart';

/// Tela de configurações do aplicativo.
///
/// Acessada a partir da tela de perfil, permite ao usuário
/// configurar opções gerais do app.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ACTIONS

  /// Exibe aviso de recurso em desenvolvimento.
  void _showDevelopmentMessage(BuildContext context, String feature) {
    WGDialog.showAction(
      context,
      title: SharedStrings.DEVELOPMENT_TITLE,
      message: SharedStrings.featureInDevelopment(feature),
    );
  }

  // UI

  // Constrói a tela de configurações com as opções disponíveis.
  @override
  Widget build(BuildContext context) {
    return WGScaffold(
      child: Column(
        children: [
          // CABEÇALHO
          WGPageHeader.title(
            title: SettingsStrings.SETTINGS_TITLE,
            showSearchBar: false,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              child: Column(
                children: [
                  WGOptionTile(
                    icon: Icons.location_on_outlined,
                    title: SettingsStrings.SHARE_LOCATION_TITLE,
                    subtitle: SettingsStrings.SHARE_LOCATION_SUBTITLE,
                    onTap: () => _showDevelopmentMessage(
                      context,
                      SettingsStrings.SHARE_LOCATION_FEATURE,
                    ),
                  ),

                  const SizedBox(height: 12),

                  WGOptionTile(
                    icon: Icons.info_outline,
                    title: SettingsStrings.APP_ABOUT_TITLE,
                    subtitle: SettingsStrings.APP_ABOUT_SUBTITLE,
                    onTap: () => _showDevelopmentMessage(
                      context,
                      SettingsStrings.APP_ABOUT_FEATURE,
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
