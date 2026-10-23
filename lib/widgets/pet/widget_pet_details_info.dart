import 'package:appets/core/constants/constants_strings_pet_details.dart';
import 'package:appets/core/extensions/extension_pet_display.dart';
import 'package:appets/core/extensions/extension_pet_publication_type.dart';
import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/core/utils/whatsapp_launcher.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/widgets/display/widget_info_row.dart';
import 'package:flutter/material.dart';

/// Painel de informações reutilizável da tela de detalhes do pet.
///
/// Exibe nome, dados básicos (idade, gênero, cidade e
/// tipo de publicação), a seção "Sobre" e o botão de contato.
class WGPetDetailsInfo extends StatelessWidget {
  const WGPetDetailsInfo({super.key, required this.pet});

  // PROPERTIES
  final Pet pet;

  // UI

  /// Botão de contato via WhatsApp.
  Widget _buildContactButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: context.appColors.primary,

          padding: const EdgeInsets.symmetric(vertical: 16),
        ),

        onPressed: () => openWhatsAppContact(
          context,
          ownerPhone: pet.ownerPhone,
          petName: pet.name,
        ),

        child: Text(
          PetDetailsStrings.CONTACT_BUTTON,

          style: TextStyle(color: context.appColors.onPrimary),
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
          Text(pet.name, style: ThemeTextStyles.heading(context.appColors)),

          const SizedBox(height: 20),

          // Informações
          WGInfoRow(icon: Icons.cake_outlined, text: pet.ageLabel),

          const SizedBox(height: 14),

          WGInfoRow(icon: Icons.pets_outlined, text: pet.species.label),

          const SizedBox(height: 14),

          // Gênero com ícone e cor coerentes ao gênero do pet.
          WGInfoRow(
            icon: pet.genderIcon,
            iconColor: pet.genderColor(context.appColors),
            text: pet.genderLabel,
          ),

          if (pet.race.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            WGInfoRow(icon: Icons.label_outline, text: pet.race),
          ],

          if (pet.weightLabel != null) ...[
            const SizedBox(height: 14),
            WGInfoRow(
              icon: Icons.monitor_weight_outlined,
              text: pet.weightLabel!,
            ),
          ],

          const SizedBox(height: 14),

          WGInfoRow(icon: Icons.location_on_outlined, text: pet.address),

          const SizedBox(height: 14),

          // Tipo de publicação
          WGInfoRow(
            icon: pet.publicationType.icon,
            iconColor: pet.publicationType.color(context.appColors),
            text: pet.publicationType.label,
            textStyle: ThemeTextStyles.body(context.appColors).copyWith(
              color: pet.publicationType.color(context.appColors),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 30),

          // Sobre
          Text(
            PetDetailsStrings.ABOUT_SECTION,
            style: ThemeTextStyles.subtitle(context.appColors),
          ),

          const SizedBox(height: 10),

          Text(
            pet.description ?? PetDetailsStrings.DESCRIPTION_NOT_INFORMED,

            style: ThemeTextStyles.body(context.appColors),
          ),

          const SizedBox(height: 40),

          // CONTATO
          _buildContactButton(context),
        ],
      ),
    );
  }
}
