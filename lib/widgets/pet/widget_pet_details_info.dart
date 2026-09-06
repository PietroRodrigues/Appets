import 'package:appets/core/constants/constants_strings_pet_details.dart';
import 'package:appets/core/extensions/extension_pet_display.dart';
import 'package:appets/core/extensions/extension_pet_publication_type.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/widgets/display/widget_info_row.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
          backgroundColor: ThemeColors.primary,

          padding: const EdgeInsets.symmetric(vertical: 16),
        ),

        onPressed: () async {
          if (pet.ownerPhone.isEmpty) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(PetDetailsStrings.OWNER_PHONE_UNAVAILABLE),
                ),
              );
            }
            return;
          }

          final phone = pet.ownerPhone.replaceAll(RegExp(r'[^0-9]'), '');
          final message = Uri.encodeComponent(
            PetDetailsStrings.whatsAppMessage(pet.name),
          );
          final url = Uri.parse('https://wa.me/55$phone?text=$message');

          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(PetDetailsStrings.WHATSAPP_ERROR)),
              );
            }
          }
        },

        child: const Text(
          PetDetailsStrings.CONTACT_BUTTON,

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
          WGInfoRow(icon: Icons.cake_outlined, text: pet.ageLabel),

          const SizedBox(height: 14),

          WGInfoRow(icon: Icons.pets, text: pet.genderLabel),

          const SizedBox(height: 14),

          WGInfoRow(icon: Icons.pets_outlined, text: pet.species.label),

          if (pet.race.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            WGInfoRow(icon: Icons.label_outline, text: pet.race),
          ],

          const SizedBox(height: 14),

          WGInfoRow(icon: Icons.location_on_outlined, text: pet.address),

          const SizedBox(height: 14),

          // Tipo de publicação
          WGInfoRow(
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
          Text(
            PetDetailsStrings.ABOUT_SECTION,
            style: ThemeTextStyles.subtitle,
          ),

          const SizedBox(height: 10),

          Text(
            pet.description ?? PetDetailsStrings.DESCRIPTION_NOT_INFORMED,

            style: ThemeTextStyles.body,
          ),

          const SizedBox(height: 40),

          // CONTATO
          _buildContactButton(context),
        ],
      ),
    );
  }
}
