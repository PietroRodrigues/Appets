import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/widgets/common/display/widget_display.dart';
import 'package:appets/widgets/common/feedback/widget_snack_bar.dart';
import 'package:appets/widgets/common/layout/widget_layout.dart';
import 'package:appets/widgets/main/widget_page_header.dart';

/// Tela de configurações do aplicativo.
///
/// Acessada a partir da tela de perfil, permite ao usuário
/// configurar opções gerais do app.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
  });


  // ACTIONS

  /// Exibe aviso de recurso em desenvolvimento.
  void _showDevelopmentMessage(BuildContext context, String feature) {
    AppSnackBar.development(context, feature);
  }


  // UI

  // Constrói a tela de configurações com as opções disponíveis.
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Column(
        children: [

          // CABEÇALHO
          AppPageHeader.title(
            title: AppStrings.settingsTitle,
            showSearchBar: false,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              child: Column(
                children: [

                  AppOptionTile(
                    icon: Icons.location_on_outlined,
                    title: AppStrings.shareLocationTitle,
                    subtitle: AppStrings.shareLocationSubtitle,
                    onTap: () => _showDevelopmentMessage(
                      context,
                      AppStrings.shareLocationFeature,
                    ),
                  ),

                  const SizedBox(height: 12),

                  AppOptionTile(
                    icon: Icons.info_outline,
                    title: AppStrings.appAboutTitle,
                    subtitle: AppStrings.appAboutSubtitle,
                    onTap: () => _showDevelopmentMessage(
                      context,
                      AppStrings.appAboutFeature,
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
