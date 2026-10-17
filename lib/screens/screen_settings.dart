import 'package:appets/core/constants/constants_strings_settings.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/utils/app_version.dart';
import 'package:appets/widgets/display/widget_option_tile.dart';
import 'package:appets/widgets/headers/widget_page_header.dart';
import 'package:appets/widgets/layout/widget_layout.dart';
import 'package:flutter/material.dart';

/// Tela de configurações do aplicativo.
///
/// Acessada a partir da tela de perfil, permite ao usuário
/// configurar opções gerais do app.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                  // Versão lida dinamicamente do pubspec.yaml.
                  FutureBuilder<String>(
                    future: readAppVersion(),
                    builder: (context, snapshot) {
                      return WGOptionTile(
                        icon: Icons.info_outline,
                        title: SettingsStrings.APP_ABOUT_TITLE,
                        subtitle:
                            '${SettingsStrings.APP_ABOUT_SUBTITLE} ${snapshot.data ?? ''}',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.about),
                      );
                    },
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
