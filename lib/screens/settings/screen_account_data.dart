import 'package:flutter/material.dart';

import 'package:appets/widgets/common/display/widget_option_tile.dart';
import 'package:appets/widgets/common/layout/widget_scaffold.dart';
import 'package:appets/widgets/common/layout/widget_section_title.dart';
import 'package:appets/widgets/main/widget_page_header.dart';

/// Tela de dados da conta do usuário.
///
/// Acessada a partir da tela de perfil, permite ao usuário
/// visualizar e editar suas informações pessoais, endereço
/// e configurações de segurança da conta.
class AccountDataScreen extends StatelessWidget {
  const AccountDataScreen({
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
            title: 'Dados da conta',
            showSearchBar: false,
          ),

          // CONTEÚDO
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              child: Column(
                children: [

                  // SEÇÃO: INFORMAÇÕES PESSOAIS
                  const AppSectionTitle(title: 'Informações pessoais'),

                  const SizedBox(height: 12),

                  AppOptionTile(
                    icon: Icons.person_outline,
                    title: 'Nome',
                    subtitle: 'Pietro',
                    onTap: () => _showDevelopmentMessage(context, 'Edição de nome'),
                  ),

                  const SizedBox(height: 12),

                  AppOptionTile(
                    icon: Icons.email_outlined,
                    title: 'E-mail',
                    subtitle: 'pietro@email.com',
                    onTap: () => _showDevelopmentMessage(context, 'Edição de e-mail'),
                  ),

                  const SizedBox(height: 12),

                  AppOptionTile(
                    icon: Icons.phone_outlined,
                    title: 'Telefone',
                    subtitle: '(11) 99999-9999',
                    onTap: () => _showDevelopmentMessage(context, 'Edição de telefone'),
                  ),

                  const SizedBox(height: 20),


                  // SEÇÃO: ENDEREÇO
                  const AppSectionTitle(title: 'Endereço'),

                  const SizedBox(height: 12),

                  AppOptionTile(
                    icon: Icons.location_on_outlined,
                    title: 'Endereço',
                    subtitle: 'São Paulo, SP',
                    onTap: () => _showDevelopmentMessage(context, 'Edição de endereço'),
                  ),

                  const SizedBox(height: 20),


                  // SEÇÃO: SEGURANÇA
                  const AppSectionTitle(title: 'Segurança'),

                  const SizedBox(height: 12),

                  AppOptionTile(
                    icon: Icons.lock_outline,
                    title: 'Alterar senha',
                    onTap: () => _showDevelopmentMessage(context, 'Alteração de senha'),
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
