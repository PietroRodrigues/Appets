import 'package:flutter/material.dart';

import 'package:appets/core/extensions/extension_pet_display.dart';
import 'package:appets/core/extensions/extension_pet_publication_type.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/widgets/common/display/widget_info_row.dart';

/// Painel de informações reutilizável da tela de detalhes do pet.
///
/// Exibe nome, dados básicos (idade, gênero, cidade e
/// tipo de publicação), a seção "Sobre" e o botão de contato.
class AppPetDetailsInfo extends StatelessWidget {
  const AppPetDetailsInfo({
    super.key,
    required this.pet,
  });

  // PROPERTIES
  final Pet pet;

  // UI

  /// Botão de contato via WhatsApp (em desenvolvimento).
  Widget _buildContactButton() {
    return SizedBox(
      width: double.infinity,

      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: ThemeColors.primary,

          padding: const EdgeInsets.symmetric(vertical: 16),
        ),

        onPressed: () { // Em desenvolvimento.
          // TODO:
          // Abrir conversa via WhatsApp.
        },

        child: const Text(
          'Entrar em contato',

          style: TextStyle(color: ThemeColors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // Nome
          Text(pet.name, style: ThemeTextStyles.heading),

          const SizedBox(height: 20),

          // Informações
          AppInfoRow(
            icon: Icons.cake_outlined,
            text: pet.ageLabel,
          ),

          const SizedBox(height: 12),

          AppInfoRow(
            icon: Icons.pets,
            text: pet.genderLabel,
          ),

          const SizedBox(height: 12),

          AppInfoRow(
            icon: Icons.location_on_outlined,
            text: pet.city,
          ),

          const SizedBox(height: 12),

          // Tipo de publicação
          AppInfoRow(
            icon: pet.publicationType.icon,
            iconColor: pet.publicationType.color,
            text: pet.publicationType.label,
            textStyle: ThemeTextStyles.body.copyWith(
              color: pet.publicationType.color,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 30),

          // Sobre
          Text('Sobre', style: ThemeTextStyles.subtitle),

          const SizedBox(height: 10),

          Text(
            'Este é um texto temporário apenas para montar a interface. ' // Em desenvolvimento.
            'Futuramente essa descrição será carregada do Firebase com '
            'as informações cadastradas pelo responsável pelo pet.',

            style: ThemeTextStyles.body,
          ),

          const SizedBox(height: 40),

          // CONTATO
          _buildContactButton(),
        ],
      ),
    );
  }
}
