import 'package:appets/core/constants/constants_strings_settings.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/core/utils/app_version.dart';
import 'package:appets/widgets/display/widget_info_row.dart';
import 'package:appets/widgets/display/widget_logo.dart';
import 'package:appets/widgets/headers/widget_page_header.dart';
import 'package:appets/widgets/layout/widget_layout.dart';
import 'package:flutter/material.dart';

/// Tela "Sobre o APPets": informações relevantes ao usuário sobre o app.
///
/// Acessada a partir das configurações, apresenta a identidade do app
/// (logo, slogan e versão), o propósito do APPets e suas funcionalidades
/// principais.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // UI

  // Constrói a identidade do app: logo, nome, slogan e versão.
  Widget _buildIdentity(AppColors colors) {
    return Column(
      children: [
        const WGLogo(width: 180),

        const SizedBox(height: 16),

        Text(
          SettingsStrings.ABOUT_APP_NAME,
          textAlign: TextAlign.center,
          style: ThemeTextStyles.title(colors),
        ),

        const SizedBox(height: 4),

        Text(
          SharedStrings.SLOGAN,
          textAlign: TextAlign.center,
          style: ThemeTextStyles.caption(colors),
        ),

        // Versão lida dinamicamente do pubspec.yaml.
        FutureBuilder<String>(
          future: readAppVersion(),
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${SettingsStrings.APP_ABOUT_SUBTITLE} ${snapshot.data ?? ''}',
                textAlign: TextAlign.center,
                style: ThemeTextStyles.caption(colors),
              ),
            );
          },
        ),
      ],
    );
  }

  // Constrói a lista de funcionalidades principais do app.
  Widget _buildFeatures() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WGInfoRow(
          icon: Icons.pets,
          text: SettingsStrings.ABOUT_FEATURE_PUBLISH,
        ),
        SizedBox(height: 10),
        WGInfoRow(
          icon: Icons.search,
          text: SettingsStrings.ABOUT_FEATURE_SEARCH,
        ),
        SizedBox(height: 10),
        WGInfoRow(
          icon: Icons.star_border,
          text: SettingsStrings.ABOUT_FEATURE_FAVORITES,
        ),
        SizedBox(height: 10),
        WGInfoRow(
          icon: Icons.chat_bubble_outline,
          text: SettingsStrings.ABOUT_FEATURE_CONTACT,
        ),
      ],
    );
  }

  // Constrói a tela "Sobre" com identidade, propósito e funcionalidades.
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return WGScaffold(
      child: Column(
        children: [
          // CABEÇALHO
          WGPageHeader.title(
            title: SettingsStrings.APP_ABOUT_TITLE,
            showSearchBar: false,
          ),

          // CONTEÚDO
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // IDENTIDADE: logo, nome, slogan e versão.
                  _buildIdentity(colors),

                  const SizedBox(height: 28),

                  // SEÇÃO: O QUE É O APPETS
                  const WGSectionTitle(
                    title: SettingsStrings.ABOUT_ABOUT_SECTION,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    SettingsStrings.ABOUT_DESCRIPTION,
                    style: ThemeTextStyles.body(colors),
                  ),

                  const SizedBox(height: 20),

                  // SEÇÃO: FUNCIONALIDADES
                  const WGSectionTitle(
                    title: SettingsStrings.ABOUT_FEATURES_SECTION,
                  ),

                  const SizedBox(height: 12),

                  _buildFeatures(),

                  const SizedBox(height: 24),

                  // NOTA DE RODAPÉ (projeto de estudo).
                  Text(
                    SettingsStrings.ABOUT_PROJECT_NOTE,
                    textAlign: TextAlign.center,
                    style: ThemeTextStyles.caption(colors),
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
